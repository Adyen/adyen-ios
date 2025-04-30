# AdyenCardScanner SDK

The **CardScanner SDK** allows you to quickly integrate card scanning functionality into your iOS app using a simple, customizable interface.

## Technical Requirements

- iOS 13.0 or later
- Swift 5.0 or later
- Camera access (requires `NSCameraUsageDescription` in `Info.plist`)
- A `Bundle` containing localized strings (optional but recommended)

### Info.plist Configuration

To access the camera, add the following key to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to scan your card.</string>
```

### Integration

```swift
import CardScanner

class CheckoutViewController: UIViewController {

    func presentCardScanner() {
        // Check if card scanning is supported on this device
        guard CardScanner.isAvailable else {
            print("Card scanning is not available on this device.")
            return
        }

        // Create the card scanner view controller
        let scannerVC = CardScanner.createCardScanner(localizationBundle: .main) { result in
            switch result {
            case .success(let details):
                print("Scanned card number: \(details.cardNumber)")
                print("Expiry: \(details.expiryMonth ?? 0)/\(details.expiryYear ?? 0)")
            case .failure(let error):
                print("Scanning failed: \(error)")
            }
        }

        // Present the scanner if creation was successful
        if let scannerVC = scannerVC {
            present(scannerVC, animated: true)
        }
    }
}
```
