//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

@MainActor
internal struct StoredPaymentMethodManagementListView: View {

    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 16
        static let pageHeaderSpacing: CGFloat = 8
    }

    @ObservedObject private var viewModel: StoredPaymentMethodManagementViewModel
    private let theme: CheckoutTheme

    internal init(viewModel: StoredPaymentMethodManagementViewModel, theme: CheckoutTheme) {
        self.viewModel = viewModel
        self.theme = theme
    }

    internal var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                StoredPaymentMethodManagementHeader(
                    title: viewModel.title,
                    description: viewModel.description,
                    theme: theme
                )

                ForEach(viewModel.sections, id: \.kind) { section in
                    StoredPaymentMethodManagementSectionView(
                        title: viewModel.sectionTitle(for: section.kind),
                        section: section,
                        removeButtonTitle: viewModel.removeButtonTitle,
                        theme: theme,
                        onRemove: viewModel.requestRemoval
                    )
                }
            }
            .padding(Constants.horizontalPadding)
        }
    }
}

internal struct StoredPaymentMethodManagementHeader: View {

    private enum Constants {
        static let spacing: CGFloat = 8
    }

    internal let title: String
    internal let description: String
    internal let theme: CheckoutTheme

    internal var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            Text(title)
                .font(Font(theme.elements.labels.title.font))
                .foregroundStyle(Color(uiColor: theme.elements.labels.title.color))

            Text(description)
                .font(Font(theme.elements.labels.body.font))
                .foregroundStyle(Color(uiColor: theme.elements.labels.body.color))
        }
    }
}

private struct StoredPaymentMethodManagementLogoView: View {

    let url: URL

    internal var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Color.clear
        }
    }
}

private struct StoredPaymentMethodManagementSectionView: View {

    private enum Constants {
        static let headerSpacing: CGFloat = 8
        static let itemSpacing: CGFloat = 12
        static let headerVerticalPadding: CGFloat = 8
    }

    let title: String
    let section: StoredPaymentMethodManagementSection
    let removeButtonTitle: String
    let theme: CheckoutTheme
    let onRemove: (StoredPaymentMethodManagementItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.headerSpacing) {
            Text(title)
                .font(Font(theme.elements.labels.subheadlineEmphasized.font))
                .foregroundStyle(Color(uiColor: theme.elements.labels.subheadlineEmphasized.color))
                .padding(.vertical, Constants.headerVerticalPadding)

            VStack(spacing: Constants.itemSpacing) {
                ForEach(section.items, id: \.paymentMethod.identifier) { item in
                    StoredPaymentMethodManagementRow(
                        item: item,
                        removeButtonTitle: removeButtonTitle,
                        theme: theme,
                        onRemove: onRemove
                    )
                }
            }
        }
        .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.section(section.kind))
    }
}

private struct StoredPaymentMethodManagementRow: View {

    private enum Constants {
        static let itemSpacing: CGFloat = 16
        static let logoWidth: CGFloat = 40
        static let logoHeight: CGFloat = 26
        static let verticalPadding: CGFloat = 12
    }

    let item: StoredPaymentMethodManagementItem
    let removeButtonTitle: String
    let theme: CheckoutTheme
    let onRemove: (StoredPaymentMethodManagementItem) -> Void

    var body: some View {
        HStack(spacing: Constants.itemSpacing) {
            HStack(spacing: Constants.itemSpacing) {
                StoredPaymentMethodManagementLogoView(url: item.logoURL)
                    .frame(width: Constants.logoWidth, height: Constants.logoHeight)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(Font(theme.elements.labels.bodyEmphasized.font))
                        .foregroundStyle(Color(uiColor: theme.elements.labels.bodyEmphasized.color))

                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(Font(theme.elements.labels.subheadline.font))
                            .foregroundStyle(Color(uiColor: subtitleColor))
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(item.accessibilityLabel ?? [item.title, item.subtitle].compactMap { $0 }.joined(separator: ", "))

            Spacer(minLength: 0)

            Button(removeButtonTitle) {
                onRemove(item)
            }
            .font(Font(theme.elements.labels.subheadline.font))
            .foregroundStyle(Color(uiColor: theme.colors.destructive))
            .accessibilityLabel(item.removalActionTitle)
            .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.remove(item.paymentMethod.identifier))
        }
        .padding(.vertical, Constants.verticalPadding)
    }

    private var subtitleColor: UIColor {
        item.subtitleStatus == .warning ? theme.colors.warning : theme.colors.textSecondary
    }
}
