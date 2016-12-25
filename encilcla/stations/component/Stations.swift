import RxSwift
import CoreLocation.CLLocation

protocol Stations {
  func near() -> Observable<([Station], CLLocation)>
}

class DefaultStations: Stations {

  private static let LIMIT = 5
  private let gps: GPS
  private let api: StationsAPI

  static func build() -> Stations {
    return DefaultStations(gps: DefaultGPS(), api: DefaultStationsAPI())
  }

  init(gps: GPS, api: StationsAPI) {
    self.gps = gps
    self.api = api
  }

  internal func near() -> Observable<([Station], CLLocation)> {
    return Observable.zip(gps.locate(), api.stations()) {
      location, response throws -> ([Station], CLLocation) in
      return (self.sort(location: location, response: response), location)
    }
  }

  func sort(location: CLLocation, response: [Station]) -> [Station] {
    return Array(response.sorted {
      $0.distance(location: location) < $1.distance(location: location)
    }[0 ... DefaultStations.LIMIT])
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



