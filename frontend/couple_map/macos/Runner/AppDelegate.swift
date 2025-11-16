import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// Allow the application to quit when the last window is closed.
  /// - Returns: `true` to terminate the app after the last window closes, `false` otherwise.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  /// Indicates that the application supports secure state restoration.
  /// - Returns: `true` if the application supports secure restorable state, `false` otherwise.
  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}