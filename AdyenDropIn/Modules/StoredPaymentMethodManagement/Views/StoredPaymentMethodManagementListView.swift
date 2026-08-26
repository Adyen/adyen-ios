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
        static let topPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 16
        static let animationDuration = 0.2
    }

    @ObservedObject private var viewModel: StoredPaymentMethodManagementViewModel
    private let theme: CheckoutTheme

    internal init(viewModel: StoredPaymentMethodManagementViewModel, theme: CheckoutTheme) {
        self.viewModel = viewModel
        self.theme = theme
    }

    internal var body: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            if viewModel.removalError != nil {
                RemovalErrorView(message: viewModel.removalErrorMessage, theme: theme)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            ForEach(viewModel.sections, id: \.kind) { section in
                SectionView(
                    title: viewModel.sectionTitle(for: section),
                    section: section,
                    removeButtonTitle: viewModel.removeButtonTitle,
                    theme: theme,
                    onRemove: viewModel.requestRemoval
                )
            }
        }
        .padding(.top, Constants.topPadding)
        .animation(
            .easeInOut(duration: Constants.animationDuration),
            value: viewModel.removalError != nil
        )
        .animation(
            .easeInOut(duration: Constants.animationDuration),
            value: paymentMethodIdentifiers
        )
    }

    private var paymentMethodIdentifiers: [String] {
        viewModel.sections.flatMap { section in
            section.items.map(\.paymentMethod.identifier)
        }
    }
}

private extension StoredPaymentMethodManagementListView {

    struct RemovalErrorView: View {

        private enum Constants {
            static let iconSystemName = "exclamationmark.triangle"
            static let spacing: CGFloat = 16
            static let iconSize: CGFloat = 16
        }

        let message: String
        let theme: CheckoutTheme

        var body: some View {
            HStack(spacing: Constants.spacing) {
                Image(systemName: Constants.iconSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .accessibilityHidden(true)

                Text(message)
                    .font(Font(theme.elements.labels.body.font))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(Color(uiColor: theme.colors.destructive))
        }
    }

    struct LogoView: View {

        let url: URL

        var body: some View {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.clear
            }
        }
    }

    struct SectionView: View {

        private enum Constants {
            static let headerSpacing: CGFloat = 8
            static let itemSpacing: CGFloat = 12
            static let headerVerticalPadding: CGFloat = 8
        }

        let title: String?
        let section: StoredPaymentMethodManagementSection
        let removeButtonTitle: String
        let theme: CheckoutTheme
        let onRemove: (StoredPaymentMethodManagementItem) -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: Constants.headerSpacing) {
                if let title {
                    Text(title)
                        .font(Font(theme.elements.labels.subheadlineEmphasized.font))
                        .foregroundStyle(Color(uiColor: theme.elements.labels.subheadlineEmphasized.color))
                        .padding(.vertical, Constants.headerVerticalPadding)
                }

                VStack(spacing: Constants.itemSpacing) {
                    ForEach(section.items, id: \.paymentMethod.identifier) { item in
                        RowView(
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

    struct RowView: View {

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
                    LogoView(url: item.logoURL)
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
            item.subtitleStatus == .warning ? theme.colors.destructive : theme.colors.textSecondary
        }
    }
}
