import RxSwift
import CoreLocation.CLLocation
import GoogleMaps

protocol Stations {
  func near() -> Observable<(CLLocation, [PolylineStation])>
}

class DefaultStations: Stations {

  private static let LIMIT = 3
  let locationRepo: Location
  let routesRepo: Route
  let stationsApiRepo: StationsAPI

  init(locationRepo: Location, routesRepo: Route,
    stationsApiRepo: StationsAPI) {
    self.locationRepo = locationRepo
    self.routesRepo = routesRepo
    self.stationsApiRepo = stationsApiRepo
  }

  internal func near() -> Observable<(CLLocation, [PolylineStation])> {
    return self.locationRepo
      .locate()
      .flatMap {
        location in
        self.stationsApiRepo
          .stations()
          .flatMap({
            stations in
            self.sorted(location: location, stations: stations)
          })
          .take(DefaultStations.LIMIT)
          .flatMap {
            station in
            self.routeFor(location: location, station: station)
          }
          .toArray()
          .flatMap {
            stations in
            Observable.just((location, stations))
          }
      }
  }

  private func routeFor(location: CLLocation,
    station: Station) -> Observable<PolylineStation> {
    return self.routesRepo
      .calculate(from: location,
        to: CLLocation(latitude: station.lat, longitude: station.lon))
      .flatMap({
        route in
        return Observable.just(PolylineStation(name: station.name,
          lat: station.lat,
          lon: station.lon,
          bikes: station.bikes,
          polyline: route))
      })
  }

  private func sorted(location: CLLocation,
    stations: [Station]) -> Observable<Station> {
    return Observable.from(Array(stations.sorted {
      $0.distance(location: location) < $1.distance(location: location)
    }))
  }
}

struct Station {
  let name: String
  let lat: Double
  let lon: Double
  let bikes: Int

  func distance(location: CLLocation) -> Double {
    return CLLocation(latitude: lat, longitude: lon)
      .distance(from: location)
  }
}

struct PolylineStation {
  let name: String
  let lat: Double
  let lon: Double
  let bikes: Int
  let polyline: GMSPolyline

  func distance(location: CLLocation) -> Double {
    return CLLocation(latitude: lat, longitude: lon)
      .distance(from: location)
  }
}



