# Adyen CardScanner iOS SDK

The **CardScanner SDK** allows you to quickly integrate card scanning functionality into your iOS app.

## Overview

TBD

## Requirements

- iOS 13.0 or higher
- Swift 5.0 or higher
- Xcode 15 or higher


## Installation

TBD

## Integration

1. Set up camera permission

    To access the camera, add the following key to your `Info.plist`. 
    You can also edit your Into.plist file andd add it directly.

    ```xml
    <key>NSCameraUsageDescription</key>
    <string>We need access to your camera to scan your card.</string>
    ```

    ![Info.plist camera permission](Images/plist-file-demo.png)


2. Create a card scanner view controller and present it where you want to start the scan flow.
    - Create the card scanner view controller.
    - Add your specific business logic to the card scan completion block.
    - Present the view controler.
    - After a successful card scan, the card scanner view controller will be dismissed and the completion block will be executed.

### Example integration

```swift

import UIKit
import AdyenCardScanner

class ViewController: UIViewController {

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
                // The scanned card by the user. The result of the scan are in details.
                print("Scanned card number: \(details.cardNumber)")
            case .failure(let error):
                // The card scan failed.
                print("Scanning failed: \(error.localizedDescription)")
            }
        }

        // Present the scanner if creation was successful
        if let scannerVC = scannerVC {
            present(scannerVC, animated: true)
        }
    }
}
```
