import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// Performs app launch setup and registers Flutter plugins.
  /// 
  /// This method is invoked when the application has finished launching and ensures Flutter plugins are registered before delegating to the superclass implementation.
  /// - Returns: `true` if the application finished launching successfully, `false` otherwise.
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}