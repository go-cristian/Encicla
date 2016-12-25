import UIKit

class StationViewCell: UITableViewCell {

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

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
