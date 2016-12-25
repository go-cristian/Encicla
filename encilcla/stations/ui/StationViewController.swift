import UIKit
import RxSwift
import CoreLocation
import GoogleMaps

class StationViewController: UIViewController {

  @IBOutlet var stationsView: StationsView!
  @IBOutlet var mapView: StationsMapView!
  var disposable: Disposable?

  override func viewDidLoad() {
    super.viewDidLoad()
    let gps = DefaultGPS()
    let api = DefaultStationsAPI()
    disposable = DefaultStations(gps: gps, api: api).near().subscribe(onNext: {
      response in
      self.disposable?.dispose()
      let stations = response.0
      let location = response.1
      self.stationsView.add(stations: stations)
      self.mapView.updateMap(location: location, station: stations.first!)
    })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

