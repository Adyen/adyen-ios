//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public class DynamicTypeController {
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFonts), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public
    
    public func observeDynamicType(for label: UILabel, withTextAttributes attributes: [NSAttributedString.Key: Any], textStyle: UIFont.TextStyle) {
        guard let font = attributes[.font] as? UIFont else {
            return
        }
        
        if #available(iOS 11.0, *) {
            label.adjustsFontForContentSizeCategory = true
            label.font = UIFontMetrics.default.scaledFont(for: font)
        } else {
            addObserver(label, preferredFont: font, textStyle: textStyle)
        }
    }
    
    public func observeDynamicType(for textField: UITextField, withTextAttributes attributes: [NSAttributedString.Key: Any], textStyle: UIFont.TextStyle) {
        guard let font = attributes[.font] as? UIFont else {
            return
        }
        
        if #available(iOS 11.0, *) {
            textField.adjustsFontForContentSizeCategory = true
            textField.font = UIFontMetrics.default.scaledFont(for: font)
        } else {
            addObserver(textField, preferredFont: font, textStyle: textStyle)
        }
    }
    
    /// Do not call from setAttributedTitle: method on UIButton.
    public func observeDynamicType(for button: UIButton, withTextAttributes attributes: [NSAttributedString.Key: Any], textStyle: UIFont.TextStyle) {
        guard let font = attributes[.font] as? UIFont else {
            return
        }
        
        if #available(iOS 11.0, *) {
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.titleLabel?.font = UIFontMetrics.default.scaledFont(for: font)
        }
        
        // For iOS 11 we need to observe the button so we can update its layout.
        addObserver(button, preferredFont: font, textStyle: textStyle)
    }
    
    // MARK: - Private
    
    private struct DynamicTypeObserver {
        var view: UIView
        var preferredFont: UIFont
        var textStyle: UIFont.TextStyle
    }
    
    private var observers: [DynamicTypeObserver] = []
    
    private func addObserver(_ view: UIView, preferredFont: UIFont, textStyle: UIFont.TextStyle) {
        if var existing = observerFor(view: view) {
            existing.preferredFont = preferredFont
            existing.textStyle = textStyle
            updateFont(for: existing)
        } else {
            let observer = DynamicTypeObserver(view: view, preferredFont: preferredFont, textStyle: textStyle)
            addObserver(observer)
        }
    }
    
    private func observerFor(view: UIView) -> DynamicTypeObserver? {
        return observers.first(where: { $0.view == view })
    }
    
    private func addObserver(_ observer: DynamicTypeObserver) {
        observers.append(observer)
        updateFont(for: observer)
    }
    
    @objc private func updateFonts() {
        for observer in observers {
            updateFont(for: observer)
        }
        
        return
    }
    
    private func updateFont(for observer: DynamicTypeObserver) {
        guard let font = observer.preferredFont.scaledFont(forTextStyle: observer.textStyle) else {
            return
        }
        if let label = observer.view as? UILabel {
            label.font = font
        } else if let textField = observer.view as? UITextField {
            textField.font = font
        } else if let button = observer.view as? UIButton {
            if let attributedTitle = button.attributedTitle(for: .normal) {
                var range = NSRange()
                var attributes = attributedTitle.attributes(at: 0, effectiveRange: &range)
                attributes[.font] = font
                let newAttributedTitle = NSAttributedString(string: attributedTitle.string, attributes: attributes)
                button.setAttributedTitle(newAttributedTitle, for: [])
            } else {
                button.titleLabel?.font = font
            }
            
            button.setNeedsLayout()
        }
    }
}
