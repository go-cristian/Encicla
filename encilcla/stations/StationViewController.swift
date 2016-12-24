import UIKit
import ObjectMapper
import AlamofireObjectMapper
import Alamofire
import CoreLocation
import GoogleMaps

class StationViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, UITableViewDelegate {

  @IBOutlet var stationsView: UITableView!
  @IBOutlet var mapView: GMSMapView!

  var bikeResults: [BikeResponseItem] = []
  var locManager = CLLocationManager()
  var currentLocation: CLLocation!
  var stationMarker: GMSMarker?

  override func viewDidLoad() {
    super.viewDidLoad()
    locManager.delegate = self
    locManager.requestWhenInUseAuthorization()
    stationMarker = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    title = "Estaciones"
    self.stationsView.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func locationManager(_ manager: CLLocationManager,
    didUpdateLocations locations: Array<CLLocation>) {
    locManager.stopUpdatingLocation()
    getBikes(current: locations.first!)
  }

  func getBikes(current: CLLocation) {
    self.currentLocation = current
    let URL = "http://www.encicla.gov.co/status/"

    let locationMarker: GMSMarker = GMSMarker(position: current.coordinate)
    locationMarker.map = mapView
    locationMarker.title = "Me"

    Alamofire.request(URL).responseObject {
        (response: DataResponse<BikeServerResponse>) in
        self.bikeResults = (response.result.value?.stations!.flatMap { $0.items!.flatMap { $0 } })!
          .sorted {
            self.distance(bikeItem: $0, location: current) < self.distance(
              bikeItem: $1,
              location: current)
          }.filter { $0.bikes! > 0 }
        self.stationsView.reloadData()

        self.updateMap(station: self.bikeResults.first!)
      }
  }

  func updateMap(station: BikeResponseItem) {
    let camera = GMSCameraPosition.camera(withLatitude: Double(station.lat!)!,
                                          longitude: Double(station.lon!)!,
                                          zoom: Float(zoom(distance: self.distance(
                                            bikeItem: station,
                                            location: currentLocation))))
    self.stationMarker?.title = self.bikeResults.first?.name;
    self.stationMarker?.position = CLLocationCoordinate2DMake(Double(station.lat!)!,
                                                              Double(station.lon!)!)
    self.stationMarker?.map = self.mapView
    self.mapView.camera = camera
    self.mapView.updateFocusIfNeeded()
  }

  func tableView(_ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath) {
    self.updateMap(station: self.bikeResults[indexPath.row])
  }

  func zoom(distance: Double) -> Double {
    //magic numbers everywhere
    let scale = (distance / 500) + 0.01;
    return 16 - log2(scale) / log2(2);
  }

  func distance(bikeItem: BikeResponseItem, location: CLLocation) -> Double {
    let bikeDistance = CLLocation(latitude: Double(bikeItem.lat!)!,
                                  longitude: Double(bikeItem.lon!)!)
    return bikeDistance.distance(from: location)
  }

  func tableView(_ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return bikeResults.count
  }

  func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StationViewCell.REUSE_NAME,
                                             for: indexPath) as! StationViewCell
    cell.station = bikeResults[indexPath.row]
    return cell
  }

  func locationManager(_ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      manager.startUpdatingLocation()
    }
  }
}

class BikeServerResponse: Mappable {
  var stations: [BikeResponseStation]?

  required init?(map: Map) {}

  func mapping(map: Map) {
    stations <- map["stations"]
  }
}

class BikeResponseStation: Mappable {
  var items: [BikeResponseItem]?

  required init?(map: Map) {}

  func mapping(map: Map) {
    items <- map["items"]
  }
}

class BikeResponseItem: Mappable {
  var lat: String?
  var lon: String?
  var name: String?
  var capacity: Int?
  var bikes: Int?

  required init?(map: Map) {}

  func mapping(map: Map) {
    lat <- map["lat"]
    lon <- map["lon"]
    name <- map["name"]
    capacity <- map["capacity"]
    bikes <- map["bikes"]
  }
}


