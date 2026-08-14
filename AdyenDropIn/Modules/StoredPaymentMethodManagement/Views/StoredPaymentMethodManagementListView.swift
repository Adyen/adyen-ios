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
                Text(viewModel.description)
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: theme.colors.textSecondary))

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
        static let itemSpacing: CGFloat = 8
    }

    let title: String
    let section: StoredPaymentMethodManagementSection
    let removeButtonTitle: String
    let theme: CheckoutTheme
    let onRemove: (StoredPaymentMethodManagementItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.itemSpacing) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(uiColor: theme.colors.textSecondary))

            ForEach(section.items, id: \.paymentMethod.identifier) { item in
                StoredPaymentMethodManagementRow(
                    item: item,
                    removeButtonTitle: removeButtonTitle,
                    theme: theme,
                    onRemove: onRemove
                )
            }
        }
        .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.section(section.kind))
    }
}

private struct StoredPaymentMethodManagementRow: View {

    private enum Constants {
        static let itemSpacing: CGFloat = 12
        static let logoSize: CGFloat = 24
        static let verticalPadding: CGFloat = 4
    }

    let item: StoredPaymentMethodManagementItem
    let removeButtonTitle: String
    let theme: CheckoutTheme
    let onRemove: (StoredPaymentMethodManagementItem) -> Void

    var body: some View {
        HStack(spacing: Constants.itemSpacing) {
            HStack(spacing: Constants.itemSpacing) {
                StoredPaymentMethodManagementLogoView(url: item.logoURL)
                    .frame(width: Constants.logoSize, height: Constants.logoSize)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(uiColor: theme.colors.text))

                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color(uiColor: theme.colors.textSecondary))
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(item.accessibilityLabel ?? [item.title, item.subtitle].compactMap { $0 }.joined(separator: ", "))

            Spacer(minLength: 0)

            Button(removeButtonTitle) {
                onRemove(item)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color(uiColor: theme.colors.destructive))
            .accessibilityLabel(item.removalActionTitle)
            .accessibilityIdentifier(StoredPaymentMethodManagementAccessibilityIdentifier.remove(item.paymentMethod.identifier))
        }
        .padding(.vertical, Constants.verticalPadding)
    }
}
