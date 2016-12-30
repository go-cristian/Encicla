import GoogleMaps

class StationsMapView: GMSMapView {

  var location: CLLocation?
  var marker: GMSMarker = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    marker.map = self
    if let styleURL = Bundle.main.url(forResource: "style",
      withExtension: "json") {
      mapStyle = try! GMSMapStyle(contentsOfFileURL: styleURL)
    }
  }

  func updateMap(location: CLLocation) {
    self.location = location
  }

  func updateMap(station: PolylineStation) {
    guard let location = self.location else { return }

    clear()
    camera = buildCamera(location: location, station: station)

    let marker = GMSMarker(position: location.coordinate)
    marker.title = "Me"
    marker.map = self

    self.marker.title = station.name;
    self.marker.position = CLLocationCoordinate2DMake(station.lat, station.lon)

    station.polyline.map = self

    updateFocusIfNeeded()
  }

  private func buildCamera(location: CLLocation,
    station: PolylineStation) -> GMSCameraPosition {
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
