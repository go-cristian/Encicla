import UIKit
import RxSwift
import CoreLocation
import GoogleMaps

class StationViewController: UIViewController, StationsViewDelegate {

  @IBOutlet var stationsView: StationsView!
  @IBOutlet var mapView: StationsMapView!
  var disposable: Disposable?

  override func viewDidLoad() {
    super.viewDidLoad()
    stationsView.onClickDelegate = self
    let location = DefaultLocation()
    let api = DefaultStationsAPI()
    disposable = DefaultStations(location: location, api: api).near()
      .subscribe(onNext: {
        response in
        self.disposable?.dispose()
        let stations = response.0
        let location = response.1
        self.stationsView.add(stations: stations)
        self.mapView.updateMap(location: location)
        self.mapView.updateMap(station: stations.first!)
      })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  internal func stationSelected(station: Station) {
    mapView.updateMap(station: station)
  }
}

