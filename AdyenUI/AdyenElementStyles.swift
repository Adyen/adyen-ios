//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

public struct AdyenElementStyles {
    
    public var button: AdyenButtonTypes
    public var label: LabelStyle
    
    // Initialize with a default ButtonTypes if none is provided
    public init(
        button: AdyenButtonTypes = AdyenButtonTypes(),
        label: LabelStyle = LabelStyle()
    ) {
        self.button = button
        self.label = label
    }
}

extension AdyenElementStyles: Equatable {
    // MARK: - Equatable Conformance
    
    public static func == (lhs: AdyenElementStyles, rhs: AdyenElementStyles) -> Bool {
        lhs.button == rhs.button &&
            lhs.label == rhs.label
    }
    
}
