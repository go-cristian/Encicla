import UIKit
import QuartzCore
class LoadingView: UIView {

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    guard let shape = CAShapeLayer(coder: decoder) else { return }
    shape.frame = CGRect(origin: CGPoint(x: 0, y: 0),
      size: CGSize(width: 20, height: self.frame.size.height))
    shape.backgroundColor = UIColor.black.cgColor
    layer.addSublayer(shape)

    let widthAnimation = CABasicAnimation(keyPath: "bounds.size.width")
    widthAnimation.fromValue = shape.frame.width / 5
    widthAnimation.toValue = shape.frame.width
    widthAnimation.timingFunction = timingFunction()
    widthAnimation.autoreverses = true
    widthAnimation.duration = 0.75
    widthAnimation.repeatCount = MAXFLOAT

    let xAnimation = CABasicAnimation(keyPath: "position.x")
    xAnimation.fromValue = 0
    xAnimation.toValue = frame.width
    xAnimation.timingFunction = timingFunction()
    xAnimation.autoreverses = true
    xAnimation.duration = widthAnimation.duration * 2
    xAnimation.repeatCount = MAXFLOAT

    shape.add(widthAnimation, forKey: "bounds")
    shape.add(xAnimation, forKey: "x")
  }

  private func timingFunction() -> CAMediaTimingFunction {
    return CAMediaTimingFunction(controlPoints: 0.0, 0.25, 0.75, 1.0)
  }
}
