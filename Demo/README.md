# Demo

Sample project to try out iOS Drop-in and Components integrations.

![DropIn preview](Screenshots/dropin-ios.jpg)

---

## Configuration

### Setup using .xcconfig files

The demo app uses `.xcconfig` files for secret management and environment configuration.

**To set up your local environment:**

1. **Create environment-specific configuration files** in the `Demo` folder (these files are git-ignored) by copying `Demo/Secrets.template.xcconfig`:
   - `Secrets.test.xcconfig` – For the test environment  
   - `Secrets.beta.xcconfig` – For the beta environment  
   - `Secrets.live.xcconfig` – For the live environment

   > **⚠️ IMPORTANT:** Copy these files using Finder or terminal commands like `cp`. Do **not** copy them using Xcode's "Add Files" or drag-and-drop, as this will add project references to files that do not exist in CI environments.

2. **Fill in the configuration values** in each file:

   | Variable Name | Description |
   |---------------|-------------|
   | `MERCHANT_CLIENT_KEY` | Your Adyen client key. [How to obtain it →](https://docs.adyen.com/development-resources/client-side-authentication#get-your-client-key) |
   | `MERCHANT_SERVER_HOST` | Your backend server address (e.g., `your-server.com` or `checkout-test.adyen.com/{VERSION}`), without the `https://` scheme. |
   | `MERCHANT_ACCOUNT` | Your Adyen merchant account identifier. |
   | `ADYEN_SERVER_API_KEY` | API key used **only when connecting directly to Adyen for testing**. Leave empty when using your own backend. |
   | `APPLE_TEAM_IDENTIFIER` | Your Apple Developer Team Identifier. |
   | `APPLE_PAY_MERCHANT_IDENTIFIER` | Your Apple Pay merchant identifier. |

3. **Update the `Secrets.xcconfig` file** to import your chosen environment:
```xcconfig
   #include? "Secrets.test.xcconfig"   // or .beta.xcconfig / .live.xcconfig
```

---

### Recommended: Use your own server

For security reasons, your backend server should act as a proxy between the demo app and the Adyen Checkout API. Your server should expose the required endpoints:

**Sessions flow:**
- `/sessions`

**Advanced flow:**
- `/paymentMethods`
- `/payments`
- `/payments/details`

> **🔒 Security Note:** Your API key must be handled only on your backend. Never embed it in your client app.

---

### ⚠️ Direct Adyen API usage (testing only)

If you do not have your own server, you may configure the demo app to call the Adyen Checkout API directly **for testing purposes only**. This is **not allowed** for production because it exposes your API key.

To enable direct API usage, set the following in your `Secrets.test.xcconfig`:
```xcconfig
MERCHANT_SERVER_HOST = checkout-test.adyen.com/{VERSION}
ADYEN_SERVER_API_KEY = <YOUR_API_KEY>
```

You can find the latest API version here: https://docs.adyen.com/api-explorer/Checkout/latest/overview

> **Note:** `MERCHANT_CLIENT_KEY` and `MERCHANT_ACCOUNT` are still required. You should always switch to your own backend before integrating in a real app.

---

## Structure

### Shared code

The [`Common/`](Common/) folder contains all basic code necessary to handle UI, Adyen checkout's state, and network calls.

---

### Integration examples

#### Session Flow

##### Drop-in

[`Common/IntegrationExamples/Session/DropIn/DropInExample.swift`](Common/IntegrationExamples/Session/DropIn/DropInExample.swift)

Example setup for Drop-in integration with UI customization and component configurations.

##### Components

Located in [`Common/IntegrationExamples/Session/Components/`](Common/IntegrationExamples/Session/Components/):

- **[`CardComponentExample.swift`](Common/IntegrationExamples/Session/Components/CardComponentExample.swift)** – Card payments
- **[`ApplePayComponentExample.swift`](Common/IntegrationExamples/Session/Components/ApplePayComponentExample.swift)** – Apple Pay integration
- **[`GenericPaymentComponentExample.swift`](Common/IntegrationExamples/Session/Components/GenericPaymentComponentExample.swift)** – Generic payment methods
- **[`IssuerListComponentExample.swift`](Common/IntegrationExamples/Session/Components/IssuerListComponentExample.swift)** – Issuer list payments

---

#### Advanced Flow

##### Drop-in (with partial payments support)

[`Common/IntegrationExamples/AdvancedFlow/DropIn/DropInAdvancedFlowExample.swift`](Common/IntegrationExamples/AdvancedFlow/DropIn/DropInAdvancedFlowExample.swift)

Example setup for:
- Advanced Drop-in integration
- Partial payment integration (gift card flow)

##### Components

Located in [`Common/IntegrationExamples/AdvancedFlow/Components/`](Common/IntegrationExamples/AdvancedFlow/Components/):

- **[`CardComponentAdvancedFlowExample.swift`](Common/IntegrationExamples/AdvancedFlow/Components/CardComponentAdvancedFlowExample.swift)**
- **[`ApplePayComponentAdvancedFlowExample.swift`](Common/IntegrationExamples/AdvancedFlow/Components/ApplePayComponentAdvancedFlowExample.swift)**
- **[`GenericPaymentComponentAdvancedFlowExample.swift`](Common/IntegrationExamples/AdvancedFlow/Components/GenericPaymentComponentAdvancedFlowExample.swift)**
- **[`IssuerListComponentAdvancedFlowExample.swift`](Common/IntegrationExamples/AdvancedFlow/Components/IssuerListComponentAdvancedFlowExample.swift)**

---

## Running the Demo

### UIKit Demo

Basic UI for UIKit integration.

**Run the demo:** Select `AdyenUIHost` as the target in Xcode.

### SwiftUI Demo

Basic UI for SwiftUI integration.

**Run the demo:** Select `AdyenSwiftUIHost` as the target in Xcode.
