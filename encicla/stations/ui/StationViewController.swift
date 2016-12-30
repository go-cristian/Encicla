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

    let locationRepo = DefaultLocation()
    let routesRepo = DefaultRoute()
    let stationsApiRepo = DefaultStationsAPI()
    let stationsRepo = DefaultStations(locationRepo: locationRepo,
      routesRepo: routesRepo,
      stationsApiRepo: stationsApiRepo)

    stationsRepo.near().subscribeOn(MainScheduler.instance).subscribe(onNext: {
        response in
        print(response)

        self.disposable?.dispose()
        self.mapView.isHidden = false
        self.stationsView.isHidden = false
        self.loadingView.isHidden = true
        self.stationsView.add(stations: response.1)
        self.mapView.updateMap(location: response.0)
        self.mapView.updateMap(station: response.1.first!)
      }, onError: {
        (error) -> Void in
        //TODO: show error
        print(error)
      })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  internal func stationSelected(station: PolylineStation) {
    mapView.updateMap(station: station)
  }
}

