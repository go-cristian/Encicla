import UIKit

class StationsView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  var onClickDelegate: StationsViewDelegate?
  private var stations: [Station] = []

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    delegate = self
    dataSource = self
    collectionViewLayout = UICollectionViewFlowLayout()
  }

  func add(stations: [Station]) {
    self.stations.removeAll()
    self.stations.append(contentsOf: stations)
    self.reloadData()
  }

  func collectionView(_ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
    return self.stations.count
  }

  func collectionView(_ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StationViewCell.REUSE_NAME,
      for: indexPath) as! StationViewCell
    cell.station = self.stations[indexPath.row]
    return cell
  }

  func collectionView(_ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath) {
    onClickDelegate?.stationSelected(station: self.stations[indexPath.row])
  }

  func collectionView(_ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: frame.width, height: frame.width / 6)
  }
}

protocol StationsViewDelegate {
  func stationSelected(station: Station)
}
