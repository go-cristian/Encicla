import Foundation
import UIKit

class Snackbar: UIView {

  private static let HEIGHT = CGFloat(50)
  private static let BUTTON_WIDTH = CGFloat(100)

  private var label: UILabel?
  private var button: UIButton?
  private var action: ((Snackbar) -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }

  private func setupView() {
    let label = UILabel(frame: CGRect(x: 0,
      y: 0,
      width: frame.size.width,
      height: frame.size.height))
    label.textAlignment = .left
    label.textColor = UIColor.white
    self.label = label

    let button = UIButton(type: .system)
    button.frame = CGRect(x: frame.width - Snackbar.BUTTON_WIDTH,
      y: 0,
      width: Snackbar.BUTTON_WIDTH,
      height: frame.size.height)
    button.addTarget(self,
      action: #selector(pressButton(button:)),
      for: .touchUpInside)
    self.button = button

    addSubview(label)
    addSubview(button)

    backgroundColor = UIColor.init(hex: "#9E9E9E")
    backgroundColor = UIColor.red
  }

  func pressButton(button: UIButton) {
    action?(self)
  }

  var message: String = "" {
    didSet {
      label?.text = message
    }
  }

  var buttonText: String = "" {
    didSet {
      button?.setTitle(buttonText, for: .normal)
    }
  }

  static func show(view: UIView, message: String, buttonText: String,
    action: @escaping (Snackbar) -> Void) {
    let origin = CGPoint(x: 0, y: view.frame.size.height - HEIGHT)
    let size = CGSize(width: view.frame.width, height: HEIGHT)
    let frame = CGRect(origin: origin, size: size)
    let snackbar = Snackbar(frame: frame)
    view.addSubview(snackbar)
    snackbar.message = message
    snackbar.buttonText = buttonText
    snackbar.action = action
  }
}

extension UIColor {
  convenience init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt32()
    Scanner(string: hex)
      .scanHexInt32(&int)
    let a, r, g, b: UInt32
    switch hex.characters.count {
      case 3: // RGB (12-bit)
        (a, r, g, b) = (255,
          (int >> 8) * 17,
          (int >> 4 & 0xF) * 17,
          (int & 0xF) * 17)
      case 6: // RGB (24-bit)
        (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
      case 8: // ARGB (32-bit)
        (a, r, g, b) = (int >> 24,
          int >> 16 & 0xFF,
          int >> 8 & 0xFF,
          int & 0xFF)
      default:
        (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(red: CGFloat(r) / 255,
      green: CGFloat(g) / 255,
      blue: CGFloat(b) / 255,
      alpha: CGFloat(a) / 255)
  }
}
