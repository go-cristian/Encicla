import GoogleMaps

class StationsMapView: GMSMapView {

  var location: CLLocation?

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    if let styleURL = Bundle.main.url(forResource: "style",
      withExtension: "json") {
      mapStyle = try! GMSMapStyle(contentsOfFileURL: styleURL)
      isUserInteractionEnabled = false
    }
  }

  func updateMap(location: CLLocation) {
    self.location = location
    isUserInteractionEnabled = true
  }

  func updateMap(station: PolylineStation) {
    guard let location = self.location else { return }

    clear()
    camera = buildCamera(location: location, station: station)

    let markerLocation = GMSMarker(position: location.coordinate)
    markerLocation.title = "Me"
    markerLocation.map = self

    let markerStation = GMSMarker(position: CLLocationCoordinate2DMake(station.lat,
      station.lon))
    markerStation.title = station.name;
    markerStation.map = self

    station.polyline.map = self
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
