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
    let ORIGIN = "origin=\(from.coordinate.latitude),\(from.coordinate.latitude)&"
    let DESTINATION = "destination=\(to.coordinate.latitude),\(to.coordinate.latitude)&"
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

  private var route: RouteResponse?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    route <- map["route"]
  }

  func valid() -> Bool {
    return route != nil && route!.overview_polyline != nil
  }

  func value() -> GMSPolyline {
    return GMSPolyline(path: GMSMutablePath(fromEncodedPath: (route?.overview_polyline?.points!)!))
  }
}

private class RouteResponse: Mappable {
  private var legs: [LegsResponse]?
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
  private var steps: StepResponse?

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
  private var start_location: PositionResponse?
  private var end_location: PositionResponse?
  private var polyline: OverviewPolyline?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    start_location <- map["start_location"]
    end_location <- map["end_location"]
    polyline <- map["polyline"]
  }
}

private class PositionResponse: Mappable {
  private var lat: Double?
  private var lon: Double?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    lat <- map["lat"]
    lon <- map["lon"]
  }
}
