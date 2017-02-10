import RxSwift
import CoreLocation.CLLocation
import GoogleMaps

protocol Stations {
  func near() -> Observable<(CLLocation, [PolylineStation])>
}

class DefaultStations: Stations {

  private static let LIMIT = 3
  let gps: GPS
  let routesApi: RouteApi
  let stationsApi: StationsAPI

  init(locationRepo: GPS, routesRepo: RouteApi, stationsApiRepo: StationsAPI) {
    self.gps = locationRepo
    self.routesApi = routesRepo
    self.stationsApi = stationsApiRepo
  }

  internal func near() -> Observable<(CLLocation, [PolylineStation])> {
    return self.gps
      .locate()
      .flatMap {
        location in
        self.stationsApi
          .stations()
          .flatMap {
            stations in
            self.sort(location: location, stations: stations)
          }
          .take(3)
          .flatMap {
            station in
            self.route(location: location, station: station)
          }
          .toArray()
          .flatMap {
            stations in
            Observable.just((location, stations))
          }
      }
  }

  private func route(location: CLLocation,
    station: Station) -> Observable<PolylineStation> {
    let locationTo = CLLocation(latitude: station.lat, longitude: station.lon)
    return self.routesApi
      .calculate(from: location, to: locationTo)
      .flatMap({
        route in
        return Observable.just(PolylineStation(name: station.name,
          lat: station.lat,
          lon: station.lon,
          bikes: station.bikes,
          polyline: route))
      })
  }

  private func sort(location: CLLocation,
    stations: [Station]) -> Observable<Station> {
    return Observable.from(stations.sorted {
      $0.distance(location: location) < $1.distance(location: location)
    })
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



