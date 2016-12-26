import UIKit

class StationViewCell: UICollectionViewCell {

  static let REUSE_NAME = "StationViewCell"

  @IBOutlet var nameView: UILabel!
  @IBOutlet var bikesView: UILabel!

  var station: Station? {
    didSet {
      guard let station = station else { return }
      nameView.text = station.name
      bikesView.text = String(describing: station.bikes)
    }
  }
}
