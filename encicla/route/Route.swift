import CoreLocation
import RxSwift
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import GoogleMaps

protocol Route {
  func calculate(from: CLLocation, to: CLLocation) -> Observable<GMSPolyline>
}

class DefaultRoute: Route {

  internal func calculate(from: CLLocation,
    to: CLLocation) -> Observable<GMSPolyline> {

    let BASE_URL = "https://maps.googleapis.com/maps/api/directions/json?"
    let ORIGIN = "origin=\(from.coordinate.latitude),\(from.coordinate.longitude)&"
    let DESTINATION = "destination=\(to.coordinate.latitude),\(to.coordinate.longitude)&"
    let MODE = "mode=walking&"
    let KEY = "key=AIzaSyC8bcA21C-TrIu-lGQlS7K5dozkO0En-tM"
    let URL = BASE_URL + ORIGIN + DESTINATION + MODE + KEY

    return Observable.create {
      observer in
      let request = Alamofire.request(URL);
      request.responseObject {
        (response: DataResponse<RouteServerResponse>) in

        if response.result.isFailure {
          observer.on(.error(response.result.error!))
        } else {
          if let response = response.result.value {
            if response.valid() {
              observer.on(.next(response.value()))
            } else {
              let path = GMSMutablePath()
              path.add(CLLocationCoordinate2DMake(from.coordinate.latitude,
                from.coordinate.longitude))
              path.add(CLLocationCoordinate2DMake(to.coordinate.latitude,
                to.coordinate.longitude))
              let polyline = GMSPolyline(path: path)
              observer.on(.next(polyline))
            }
            observer.on(.completed)
          } else {
            observer.on(.error(response.result.error!))
          }
        }
      }
      return Disposables.create(with: { request.cancel() })
    }
  }
}

private class RouteServerResponse: Mappable {

  private var routes: [RouteResponse]?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    routes <- map["routes"]
  }

  func valid() -> Bool {
    return routes != nil
  }

  func value() -> GMSPolyline {
    let path = GMSMutablePath()
    routes?.first?.legs?.first?.steps?.map {
      path.add(CLLocationCoordinate2DMake(($0.start_location?.lat)!,
        ($0.start_location?.lng)!))
      path.add(CLLocationCoordinate2DMake(($0.end_location?.lat)!,
        ($0.end_location?.lng)!))
    }
    return GMSPolyline(path: path)
  }
}

private class RouteResponse: Mappable {
  var legs: [LegsResponse]?
  var overview_polyline: OverviewPolyline?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    legs <- map["legs"]
    overview_polyline <- map["overview_polyline"]
  }
}

private class LegsResponse: Mappable {
  private var start_location: PositionResponse?
  private var end_location: PositionResponse?
  var steps: [StepResponse]?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    start_location <- map["start_location"]
    end_location <- map["end_location"]
    steps <- map["steps"]
  }
}

private class OverviewPolyline: Mappable {
  var points: String?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    points <- map["points"]
  }
}

private class StepResponse: Mappable {
  var start_location: PositionResponse?
  var end_location: PositionResponse?
  var polyline: OverviewPolyline?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    start_location <- map["start_location"]
    end_location <- map["end_location"]
    polyline <- map["polyline"]
  }
}

private class PositionResponse: Mappable {
  var lat: Double?
  var lng: Double?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    lat <- map["lat"]
    lng <- map["lng"]
  }
}
