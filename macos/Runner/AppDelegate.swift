import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    // http://cjycode.com/flutter_rust_bridge/integrate/ios_headers.html
    dummy_method_to_enforce_bundling()
    return true
  }
}
