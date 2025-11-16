import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// Initializes the window to host a Flutter UI by installing a `FlutterViewController` as the window's content, restoring the original window frame, and registering generated Flutter plugins.
  /// 
  /// This method replaces the window's content view controller with a new `FlutterViewController`, reapplies the window frame to preserve size and position, registers platform plugins with the Flutter controller, and then invokes the superclass `awakeFromNib()`.
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}