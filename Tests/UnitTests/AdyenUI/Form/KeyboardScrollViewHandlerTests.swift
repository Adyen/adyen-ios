//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenUI
import Testing

@MainActor
struct KeyboardScrollViewHandlerTests {

    @Test
    func viewIsReset_whenKeyboardIsShownAndHidden() async {
        let sut = makeSUT()

        await sut.load()

        await sut.showKeyboard()
        sut.checkIfViewIsAdjustedForKeyboardShown()

        await sut.hideKeyboard()
        sut.checkIfViewIsAdjustedForKeyboardHidden()
    }

    func makeSUT() -> SampleViewControllerProxy {
        SampleViewControllerProxy()
    }

    @MainActor
    struct SampleViewControllerProxy {

        private enum Constants {
            static let keyboardHeight: CGFloat = 300
        }

        let viewController: SampleViewController = .init()
        private let window = UIWindow(frame: UIScreen.main.bounds)
        private let rootController = UIViewController()

        func load() async {
            window.rootViewController = rootController
            window.makeKeyAndVisible()
            await withCheckedContinuation { continuation in
                rootController.present(viewController, animated: false) {
                    viewController.loadViewIfNeeded()
                    viewController.view.layoutIfNeeded()
                    continuation.resume()
                }
            }
        }

        func showKeyboard() async {
            let screenBounds = UIScreen.main.bounds
            let keyboardRect = CGRect(
                x: 0,
                y: screenBounds.height - Constants.keyboardHeight,
                width: screenBounds.width,
                height: Constants.keyboardHeight
            )
            NotificationCenter.default.post(
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                userInfo: [
                    UIResponder.keyboardFrameEndUserInfoKey: keyboardRect,
                    UIResponder.keyboardAnimationDurationUserInfoKey: 0.25,
                    UIResponder.keyboardAnimationCurveUserInfoKey: UIView.AnimationCurve.easeInOut.rawValue
                ]
            )
            try? await Task.sleep(for: .milliseconds(300))
        }

        func hideKeyboard() async {

            NotificationCenter.default.post(
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                userInfo: [
                    UIResponder.keyboardFrameEndUserInfoKey: CGRect.zero,
                    UIResponder.keyboardAnimationDurationUserInfoKey: 0.25,
                    UIResponder.keyboardAnimationCurveUserInfoKey: UIView.AnimationCurve.easeInOut.rawValue
                ]
            )
            try? await Task.sleep(for: .milliseconds(300))
        }

        func checkIfViewIsAdjustedForKeyboardShown() {
            #expect(viewController.scrollView.contentInset.bottom == Constants.keyboardHeight)
            #expect(viewController.scrollView.verticalScrollIndicatorInsets.bottom == Constants.keyboardHeight)
        }

        func checkIfViewIsAdjustedForKeyboardHidden() {
            #expect(viewController.scrollView.contentInset.bottom == 0)
            #expect(viewController.scrollView.verticalScrollIndicatorInsets.bottom == 0)
        }
    }

    class SampleViewController: UIViewController {
        lazy var scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.showsVerticalScrollIndicator = true
            scrollView.showsHorizontalScrollIndicator = false
            return scrollView
        }()

        private var keyboardHandler: KeyboardScrollViewHandler?

        lazy var contentView: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addArrangedSubview(UIButton())
            view.addArrangedSubview(UIButton())
            return view
        }()

        init() {
            super.init(nibName: nil, bundle: nil)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            keyboardHandler = KeyboardScrollViewHandler(scrollView: scrollView, view: view)
            keyboardHandler?.startObserving()
        }
    }
}
