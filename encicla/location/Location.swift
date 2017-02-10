import CoreLocation
import RxSwift

protocol GPS {
  func locate() -> Observable<CLLocation>
}

class DefaultGPS: NSObject, GPS, CLLocationManagerDelegate {

  private var observer: AnyObserver<CLLocation>?

  internal func locate() -> Observable<CLLocation> {
    return Observable.create {
      observer in
      self.observer = observer
      let locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      return Disposables.create { locationManager.delegate = nil }
    }
  }

  internal func locationManager(_ manager: CLLocationManager,
    didUpdateLocations locations: Array<CLLocation>) {
    observer?.on(.next(locations.first!))
    observer?.on(.completed)
  }

  internal func locationManager(_ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      manager.startUpdatingLocation()
    } else if status == .denied {
      observer?.on(.error(CLError(.denied)))
    }
  }
}
