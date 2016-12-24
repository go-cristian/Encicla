import UIKit

class StationViewCell: UITableViewCell {

  static let REUSE_NAME = "StationViewCell"

  @IBOutlet var nameView: UILabel!
  @IBOutlet var bikesView: UILabel!

  var station: BikeResponseItem? {
    didSet {
      nameView.text = station?.name
      if let bikes = station?.bikes { bikesView.text = String(describing: bikes) }
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
