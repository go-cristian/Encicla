import UIKit
import RxSwift
import CoreLocation
import GoogleMaps

class StationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet var stationsView: UITableView!
  @IBOutlet var mapView: GMSMapView!
  var stationMarker: GMSMarker?
  var stations: [Station]? = []
  var disposable: Disposable?

  override func viewDidLoad() {
    super.viewDidLoad()
    stationMarker = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    title = "Estaciones"
    self.stationsView.delegate = self
    disposable = DefaultStations.build().near().subscribe(onNext: {
      response in
      self.stations = response.0;
      self.stationsView.reloadData()
      self.updateMap(location: response.1, station: (self.stations?.first!)!)
      self.disposable?.dispose()
    })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func updateMap(location: CLLocation, station: Station) {
    let camera = GMSCameraPosition.camera(withLatitude: station.lat,
                                          longitude: station.lon,
                                          zoom: Float(zoom(distance: station.distance(
                                            location: location))))
    self.mapView.camera = camera
    updateMap(station: station)
  }

  func updateMap(station: Station) {
    self.stationMarker?.title = station.name;
    self.stationMarker?.position = CLLocationCoordinate2DMake(station.lat,
                                                              station.lon)
    self.stationMarker?.map = self.mapView
    self.mapView.updateFocusIfNeeded()
  }

  func tableView(_ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath) {
    self.updateMap(station: (self.stations?[indexPath.row])!)
  }

  func zoom(distance: Double) -> Double {
    //magic numbers everywhere
    //FIXME: find a better way to calculate the zoom
    let scale = (distance / 500) + 0.01;
    return 16 - log2(scale) / log2(2);
  }

  func tableView(_ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return (self.stations?.count)!
  }

  func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StationViewCell.REUSE_NAME,
                                             for: indexPath) as! StationViewCell
    cell.station = self.stations?[indexPath.row]
    return cell
  }
}

