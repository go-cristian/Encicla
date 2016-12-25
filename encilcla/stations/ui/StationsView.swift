import UIKit

class StationsView: UITableView, UITableViewDelegate, UITableViewDataSource {

  var stations: [Station] = []

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

  func tableView(_ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath) {
    //self.updateMap(station: (self.stations?[indexPath.row])!)
  }

  func tableView(_ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return self.stations.count
  }

  func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StationViewCell.REUSE_NAME,
                                             for: indexPath) as! StationViewCell
    cell.station = self.stations[indexPath.row]
    return cell
  }
}
