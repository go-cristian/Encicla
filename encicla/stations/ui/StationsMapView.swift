import GoogleMaps

class StationsMapView: GMSMapView {

  var location: CLLocation?
  var stationMarker: GMSMarker = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    stationMarker.map = self
  }

  func updateMap(location: CLLocation) {
    self.location = location
    let marker = GMSMarker(position: location.coordinate)
    marker.title = "Me"
    marker.map = self
    updateFocusIfNeeded()
  }

  func updateMap(station: Station) {
    camera = buildCamera(location: location!, station: station)
    self.stationMarker.title = station.name;
    self.stationMarker.position = CLLocationCoordinate2DMake(station.lat,
      station.lon)
    updateFocusIfNeeded()
  }

  private func buildCamera(location: CLLocation,
    station: Station) -> GMSCameraPosition {
    return GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude),
      longitude: location.coordinate.longitude,
      zoom: zoom(distance: station.distance(location: location)))
  }

  private func zoom(distance: Double) -> Float {
    //FIXME: find a better way to calculate the zoom (magic numbers everywhere)
    let scale = (distance / 600);
    return Float(16 - log2(scale) / log2(2));
  }
}
