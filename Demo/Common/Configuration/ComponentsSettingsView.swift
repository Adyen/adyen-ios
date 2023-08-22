import Adyen
import AdyenCard
import SwiftUI

@available(iOS 13.0.0, *)
internal struct ComponentsSettingsView: View {
    @ObservedObject internal var viewModel: ConfigurationViewModel

    private enum ConfigurationSection: String, CaseIterable {
        case cardComponent = "Card Component"
        case applePay = "ApplePay"
    }

    internal var body: some View {
        Form {
            wrapInSection(view: cardComponentSection, section: .cardComponent)
            wrapInSection(view: applePaySection, section: .applePay)
        }
    }

    internal var cardComponentSection: some View {
        NavigationLink(destination: CardComponentSettingsView(viewModel: viewModel)) {
            HStack {
                Text("Card Component")
            }
        }
    }

    private var applePaySection: some View {
        NavigationLink(destination: ApplePaySettingsView(viewModel: viewModel)) {
            HStack {
                Text("Apple Pay")
            }
        }
    }

    private func wrapInSection<T: View>(
        view: T,
        section: ConfigurationSection
    ) -> some View {
        Section(header: Text(section.rawValue.uppercased())) { view }
    }

}
