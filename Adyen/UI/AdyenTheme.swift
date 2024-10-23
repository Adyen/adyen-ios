//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

struct AdyenTheme {
    
    var fonts: Fonts
}

// MARK: - Fonts

extension AdyenTheme {
    
    struct Fonts {
        
        /// Large title
        var titleLarge: UIFont = .systemFont(ofSize: 24, weight: .bold)
        
        var title: UIFont = .systemFont(ofSize: 20, weight: .bold)
        
        var body: UIFont = .systemFont(ofSize: 17, weight: .regular)
        
        /// Bold version of `body`
        var bodyStrong: UIFont {
            body.bold()
        }
        
        var caption: UIFont = .systemFont(ofSize: 15, weight: .regular)
        
        /// Bold version of `caption`
        var captionStrong: UIFont {
            caption.bold()
        }
    }
}

private extension UIFont {
    
    func bold() -> UIFont {
        UIFont.init(
            descriptor: fontDescriptor.withSymbolicTraits(.traitBold) ?? fontDescriptor,
            size: pointSize
        )
    }
}
