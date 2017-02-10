import UIKit
import QuartzCore
class LoadingView: UIView {

  var shape: CAShapeLayer? = nil
  let widthAnimation = CABasicAnimation(keyPath: "bounds.size.width")
  let xAnimation = CABasicAnimation(keyPath: "position.x")

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    guard let shape = CAShapeLayer(coder: decoder) else { return }
    self.shape = shape
    shape.frame = CGRect(origin: CGPoint(x: 0, y: 0),
      size: CGSize(width: 20, height: self.frame.size.height))
    shape.backgroundColor = UIColor.black.cgColor
    layer.addSublayer(shape)


    widthAnimation.fromValue = shape.frame.width / 5
    widthAnimation.toValue = shape.frame.width
    widthAnimation.timingFunction = timingFunction()
    widthAnimation.autoreverses = true
    widthAnimation.duration = 0.75
    widthAnimation.repeatCount = MAXFLOAT


    xAnimation.fromValue = 0
    xAnimation.toValue = frame.width
    xAnimation.timingFunction = timingFunction()
    xAnimation.autoreverses = true
    xAnimation.duration = widthAnimation.duration * 2
    xAnimation.repeatCount = MAXFLOAT
  }

  private func timingFunction() -> CAMediaTimingFunction {
    return CAMediaTimingFunction(controlPoints: 0.0, 0.25, 0.75, 1.0)
  }

  func start() {
    isHidden = false
    shape?.add(widthAnimation, forKey: "bounds")
    shape?.add(xAnimation, forKey: "x")
  }

  func stop() {
    shape?.removeAllAnimations()
    isHidden = true
  }
}
