import RxSwift
import CoreLocation.CLLocation

protocol Stations {
  func near() -> Observable<([Station], CLLocation)>
}

class DefaultStations: Stations {

  private static let LIMIT = 3
  private let location: Location
  private let api: StationsAPI

  init(location: Location, api: StationsAPI) {
    self.location = location
    self.api = api
  }

  internal func near() -> Observable<([Station], CLLocation)> {
    return Observable.zip(self.location.locate(), api.stations()) {
      location, response throws -> ([Station], CLLocation) in
      return (Array(response.sorted {
        $0.distance(location: location) < $1.distance(location: location)
      }[0 ... DefaultStations.LIMIT - 1]), location)
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



