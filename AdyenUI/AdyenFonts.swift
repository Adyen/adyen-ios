//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public enum FontSize: CGFloat {
    case title = 34.0
    case subtitle = 20.0
    case body = 17.0
    case subheadline = 15.0
    case footnote = 13.0
}

public struct AdyenFonts {

    public var title: UIFont
    public var subtitle: UIFont
    public var body: UIFont
    public var bodyEmphasized: UIFont
    public var subHeadline: UIFont
    public var subHeadlineEmphasized: UIFont
    public var footnote: UIFont
    public var footnoteEmphasized: UIFont
    
    public init(
        title: UIFont = UIFont.systemFont(ofSize: FontSize.title.rawValue, weight: .bold),
        subtitle: UIFont = UIFont.systemFont(ofSize: FontSize.subtitle.rawValue, weight: .semibold),
        body: UIFont = UIFont.systemFont(ofSize: FontSize.body.rawValue, weight: .regular),
        bodyEmphasized: UIFont = UIFont.systemFont(ofSize: FontSize.body.rawValue, weight: .semibold),
        subHeadline: UIFont = UIFont.systemFont(ofSize: FontSize.subheadline.rawValue, weight: .regular),
        subHeadlineEmphasized: UIFont = UIFont.systemFont(ofSize: FontSize.subheadline.rawValue, weight: .semibold),
        footnote: UIFont = UIFont.systemFont(ofSize: FontSize.footnote.rawValue, weight: .regular),
        footnoteEmphasized: UIFont = UIFont.systemFont(ofSize: FontSize.footnote.rawValue, weight: .semibold)
    ) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.bodyEmphasized = bodyEmphasized
        self.subHeadline = subHeadline
        self.subHeadlineEmphasized = subHeadlineEmphasized
        self.footnote = footnote
        self.footnoteEmphasized = footnoteEmphasized
    }
    
    // A static default AdyenFonts.
    public static var `default`: AdyenFonts = .init()
}

extension AdyenFonts: Equatable {
    // MARK: - Equatable Conformance
    
    public static func == (lhs: AdyenFonts, rhs: AdyenFonts) -> Bool {
        lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.body == rhs.body &&
            lhs.bodyEmphasized == rhs.bodyEmphasized &&
            lhs.subHeadline == rhs.subHeadline &&
            lhs.subHeadlineEmphasized == rhs.subHeadlineEmphasized &&
            lhs.footnote == rhs.footnote &&
            lhs.footnoteEmphasized == rhs.footnoteEmphasized
    }
}
