import RxSwift
import CoreLocation.CLLocation

protocol Stations {
  func near() -> Observable<([Station], CLLocation)>
}

class DefaultStations: Stations {

  let gps: GPS
  let api: StationsAPI

  static func build() -> Stations {
    return DefaultStations(gps: DefaultGPS(), api: DefaultStationsAPI())
  }

  init(gps: GPS, api: StationsAPI) {
    self.gps = gps
    self.api = api
  }

  internal func near() -> Observable<([Station], CLLocation)> {
    return gps.locate().flatMap {
      location in
      self.api.stations().map {
          response throws -> ([Station], CLLocation) in
          return (self.stations(location: location, response: response),
            location)
        }
    }
  }

  func stations(location: CLLocation, response: [Station]) -> [Station] {
    return response.sorted {
      $0.distance(location: location) < $1.distance(location: location)
    }
  }
}

struct Station {
  let name: String
  let lat: Double
  let lon: Double
  let bikes: Int

  func distance(location: CLLocation) -> Double {
    return CLLocation(latitude: lat, longitude: lon).distance(from: location)
  }
}



