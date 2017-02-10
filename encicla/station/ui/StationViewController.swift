import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import GoogleMaps

class StationViewController: BaseViewController, StationsViewDelegate {

  @IBOutlet var stationsView: StationsView!
  @IBOutlet var mapView: StationsMapView!
  @IBOutlet var loadingView: LoadingView!
  private let disposable = CompositeDisposable()

  private let stationsRepo = DefaultStations(locationRepo: DefaultGPS(),
    routesRepo: DefaultRoute(),
    stationsApiRepo: DefaultStationsAPI())
    .near()

  override func viewDidLoad() {
    super.viewDidLoad()
    stationsView.onClickDelegate = self
    self.request()
  }

  override func onResume() {
    if disposable.count > 0 { loadingView.start() }
  }

  override func onPause() {
    loadingView.stop()
  }

  private func request() {
    loadingView.start()
    let subscription = stationsRepo
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
    disposable.insert(subscription)
  }

  private func updateUI(location: CLLocation, stations: [PolylineStation]) {
    stationsView.add(stations: stations)
    mapView.updateMap(location: location)
    mapView.updateMap(station: stations.first!)
  }

  private func showError() {
    loadingView.stop()
    Snackbar.show(view: self.view,
      message: "There is an error getting the results",
      buttonText: "Retry") {
      snackbar in
      self.request()
      snackbar.removeFromSuperview()
    }
  }

  private func settings() {
    loadingView.stop()
    Snackbar.show(view: self.view,
      message: "Please approve Location permission",
      buttonText: "Retry") {
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
