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
    mapView.isHidden = true
    stationsView.isHidden = true

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
        //TODO: show error
        print(error)
      })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  private func updateUI(location: CLLocation, stations: [PolylineStation]) {
    self.disposable?.dispose()
    self.mapView.isHidden = false
    self.stationsView.isHidden = false
    self.loadingView.isHidden = true
    self.stationsView.add(stations: stations)
    self.mapView.updateMap(location: location)
    self.mapView.updateMap(station: stations.first!)
  }

  internal func stationSelected(station: PolylineStation) {
    mapView.updateMap(station: station)
  }
}

