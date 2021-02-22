//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension DokuVoucherView {

    internal struct VoucherField {

        internal var identifier: String

        internal var title: String

        internal var value: String
    }

    internal struct Model {

        internal struct Instruction {

            internal let title: String

            internal let url: URL?

            internal var style: Style

            internal struct Style {

                internal lazy var button: ButtonStyle = {
                    var style = ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 9),
                                                             color: UIColor.Adyen.defaultBlue),
                                            cornerRounding: .percent(0.5))
                    style.borderColor = UIColor.Adyen.defaultBlue
                    style.borderWidth = 1
                    style.backgroundColor = .clear
                    return style
                }()
            }
        }

        internal let text: String

        internal let amount: String?

        internal var instruction: Instruction

        internal let code: String

        internal let fields: [VoucherField]

        internal let logoUrl: URL

        internal var style: Style

        internal struct Style {

            internal var text = TextStyle(font: .systemFont(ofSize: 13),
                                          color: UIColor.Adyen.componentLabel,
                                          textAlignment: .center)

            internal var amount = TextStyle(font: .boldSystemFont(ofSize: 16),
                                            color: UIColor.Adyen.componentLabel,
                                            textAlignment: .center)

            internal var codeText = TextStyle(font: .boldSystemFont(ofSize: 24),
                                              color: UIColor.Adyen.componentLabel,
                                              textAlignment: .center)

            internal var fieldValueText = TextStyle(font: .boldSystemFont(ofSize: 13),
                                                    color: UIColor.Adyen.componentLabel,
                                                    textAlignment: .center)

            internal var mainButton: ButtonStyle

            internal var secondaryButton: ButtonStyle

            internal var backgroundColor: UIColor
        }

        internal var baseViewModel: AbstractVoucherView.Model
    }
}
