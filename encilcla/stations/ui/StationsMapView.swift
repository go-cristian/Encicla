import GoogleMaps

class StationsMapView: GMSMapView {

  var stationMarker: GMSMarker = GMSMarker(position: CLLocationCoordinate2DMake(
    0,
    0))

  func updateMap(location: CLLocation, station: Station) {
    let z = zoom(distance: station.distance(location: location))
    camera = GMSCameraPosition.camera(withLatitude: station.lat,
                                      longitude: station.lon,
                                      zoom: z)
    updateMap(station: station)
  }

  func updateMap(station: Station) {
    self.stationMarker.title = station.name;
    self.stationMarker.position = CLLocationCoordinate2DMake(station.lat,
                                                             station.lon)
    self.stationMarker.map = self
    self.updateFocusIfNeeded()
  }

  func zoom(distance: Double) -> Float {
    //magic numbers everywhere
    //FIXME: find a better way to calculate the zoom
    let scale = (distance / 500) + 0.01;
    return Float(16 - log2(scale) / log2(2));
  }
}
