import GoogleMaps

class StationsMapView: GMSMapView {

  var location: CLLocation?
  var stationMarker: GMSMarker = GMSMarker(position: CLLocationCoordinate2DMake(
    0,
    0))

  func updateMap(location: CLLocation) {
    self.location = location
    let marker = GMSMarker(position: location.coordinate)
    marker.title = "Me"
    marker.map = self
  }

  func updateMap(station: Station) {
    let z = zoom(distance: station.distance(location: location!))
    camera = GMSCameraPosition.camera(withLatitude: station.lat,
                                      longitude: station.lon,
                                      zoom: z)
    self.stationMarker.title = station.name;
    self.stationMarker.position = CLLocationCoordinate2DMake(station.lat,
                                                             station.lon)
    self.stationMarker.map = self
    self.updateFocusIfNeeded()
  }

  private func zoom(distance: Double) -> Float {
    //magic numbers everywhere
    //FIXME: find a better way to calculate the zoom
    let scale = (distance / 500) + 0.01;
    return Float(16 - log2(scale) / log2(2));
  }
}
