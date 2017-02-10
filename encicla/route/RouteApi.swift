import CoreLocation
import RxSwift
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import GoogleMaps

protocol RouteApi {
  func calculate(from: CLLocation, to: CLLocation) -> Observable<GMSPolyline>
}

class DefaultRoute: RouteApi {

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

        if let error = response.result.error {
          observer.on(.error(error))
          return
        }

        if let response = response.result.value {
          observer.on(.next(response.route()))
        } else {
          observer.on(.next(self.linearRoute(from: from, to: to)))
        }
        observer.on(.completed)
      }
      return Disposables.create(with: { request.cancel() })
    }
  }

  private func linearRoute(from: CLLocation, to: CLLocation) -> GMSPolyline {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2DMake(from.coordinate.latitude,
      from.coordinate.longitude))
    path.add(CLLocationCoordinate2DMake(to.coordinate.latitude,
      to.coordinate.longitude))
    return GMSPolyline(path: path)
  }
}

private class RouteServerResponse: Mappable {

  var routes: [RouteResponse]?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    routes <- map["routes"]
  }

  func valid() -> Bool {
    return routes != nil
  }

  func route() -> GMSPolyline {
    let path = GMSMutablePath()
    _ = routes?.first?.legs?.first?.steps?.map {
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

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    legs <- map["legs"]
  }
}

private class LegsResponse: Mappable {
  var start_location: PositionResponse?
  var end_location: PositionResponse?
  var steps: [StepResponse]?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    start_location <- map["start_location"]
    end_location <- map["end_location"]
    steps <- map["steps"]
  }
}

private class StepResponse: Mappable {
  var start_location: PositionResponse?
  var end_location: PositionResponse?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    start_location <- map["start_location"]
    end_location <- map["end_location"]
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
