import UIKit

open class BaseViewController: UIViewController {

  override open func viewDidLoad() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self,
      selector: #selector(onPause),
      name: Notification.Name.UIApplicationWillResignActive,
      object: nil)

    notificationCenter.addObserver(self,
      selector: #selector(onResume),
      name: Notification.Name.UIApplicationWillEnterForeground,
      object: nil)
  }

  override open func viewWillAppear(_ animated: Bool) {
    onResume()
  }

  override open func viewWillDisappear(_ animated: Bool) {
    onPause()
  }

  open func onResume() {
  }

  open func onPause() {
  }
}