import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import GoogleMaps

class StationViewController: UIViewController, StationsViewDelegate {

  @IBOutlet var stationsView: StationsView!
  @IBOutlet var mapView: StationsMapView!
  @IBOutlet var loadingView: LoadingView!
  var disposable: Disposable?

  override func viewDidLoad() {
    super.viewDidLoad()
    stationsView.onClickDelegate = self
    mapView.isUserInteractionEnabled = false
    stationsView.isHidden = true
    self.request()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  private func request() {
    //TODO: find a way to use a dependency injection container
    let locationRepo = DefaultLocation()
    let routesRepo = DefaultRoute()
    let stationsApiRepo = DefaultStationsAPI()
    let stationsRepo = DefaultStations(locationRepo: locationRepo,
      routesRepo: routesRepo,
      stationsApiRepo: stationsApiRepo)
    disposable = stationsRepo
      .near()
      .subscribeOn(MainScheduler.instance)
      .subscribe(onNext: {
        response in
        self.updateUI(location: response.0, stations: response.1);
      }, onError: {
        (error) -> Void in
        if error._code == CLError.denied.rawValue {
          self.settings()
        } else {
          self.showError()
        }
      })
  }

  private func updateUI(location: CLLocation, stations: [PolylineStation]) {
    disposable?.dispose()
    mapView.isUserInteractionEnabled = true
    stationsView.isHidden = false
    loadingView.isHidden = true
    stationsView.add(stations: stations)
    mapView.updateMap(location: location)
    mapView.updateMap(station: stations.first!)
  }

  private func showError() {
    loadingView.isHidden = true
    Snackbar.show(view: self.view, message: "There is an error") {
      snackbar in
      self.request()
      snackbar.removeFromSuperview()
    }
  }

  private func settings() {
    Snackbar.show(view: self.view, message: "Please approve permission") {
      snackbar in
      let url = URL(string: UIApplicationOpenSettingsURLString)
      UIApplication.shared.openURL(url!)
      snackbar.removeFromSuperview()
    }
  }

  internal func stationSelected(station: PolylineStation) {
    mapView.updateMap(station: station)
  }
}

