import UIKit

class StationsView: UITableView, UITableViewDelegate, UITableViewDataSource {

  var onClickDelegate: StationsViewDelegate?
  private var stations: [Station] = []

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    delegate = self
    dataSource = self
  }

  func add(stations: [Station]) {
    self.stations.removeAll()
    self.stations.append(contentsOf: stations)
    self.reloadData()
  }

  internal func tableView(_ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath) {
    onClickDelegate?.stationSelected(station: self.stations[indexPath.row])
  }

  internal func tableView(_ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return self.stations.count
  }

  internal func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StationViewCell.REUSE_NAME,
                                             for: indexPath) as! StationViewCell
    cell.station = self.stations[indexPath.row]
    return cell
  }
}

protocol StationsViewDelegate {
  func stationSelected(station: Station)
}
