import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let phoneSizedContent = NSSize(width: 393, height: 852)
    let frame = self.frame
    let resizedFrame = NSRect(
      x: frame.midX - (phoneSizedContent.width / 2),
      y: frame.midY - (phoneSizedContent.height / 2),
      width: phoneSizedContent.width,
      height: phoneSizedContent.height
    )

    self.contentViewController = flutterViewController
    self.setContentSize(phoneSizedContent)
    self.setFrame(resizedFrame, display: true)
    self.minSize = NSSize(width: 420, height: 640)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
