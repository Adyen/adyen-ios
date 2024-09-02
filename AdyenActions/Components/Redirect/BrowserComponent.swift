//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AuthenticationServices
import SafariServices
import UIKit

internal protocol BrowserComponentDelegate: AnyObject {
    func didFail(error: Error)
    func didOpenExternalApplication()
}

internal final class ASWebComponent: NSObject, ASWebAuthenticationPresentationContextProviding {

    private enum Constants {
        static var customScheme = "adyen-sdk"
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.keyWindow!
    }

    internal weak var delegate: BrowserComponentDelegate?
    private var session: ASWebAuthenticationSession?

    internal init(url: URL) {
        self.url = url
    }

    private let url: URL

    func start() {
        let session: ASWebAuthenticationSession?
        if #available(iOS 17.4, *) {
            let callback = ASWebAuthenticationSession.Callback.customScheme(Constants.customScheme)
            session = ASWebAuthenticationSession(url: url,
                                                 callback: callback,
                                                 completionHandler: handle)
        } else {
            session = ASWebAuthenticationSession(url: url,
                                                 callbackURLScheme: Constants.customScheme,
                                                 completionHandler: handle)
        }

        if #available(iOS 13.0, *) {
            session?.presentationContextProvider = self
            session?.prefersEphemeralWebBrowserSession = true
        }
        session?.start()
    }

    func handle(url: URL?, error: Error?) {
        if let url {
            RedirectComponent.applicationDidOpen(from: url)
        } else {
            delegate?.didFail(error: error ?? ComponentError.cancelled)
        }
    }

}
