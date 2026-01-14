# Customization

Both the Drop-in and the Components offer a number of customization options to allow you to match the appearance of your app.

## Localization

To customize strings, see: <doc:Localization>.

## Styling

For example, to change the section header titles and form field titles in the Drop-in to red, and turn the submit button's background to black with white foreground:

@TabNavigator {
    @Tab(Drop-in) { 
        ```swift
        var style = DropInComponent.Style()
        style.listComponent.sectionHeader.title.color = .red
        style.formComponent.textField.title.color = .red
        style.formComponent.mainButtonItem.button.backgroundColor = .black
        style.formComponent.mainButtonItem.button.title.color = .white

        let configuration = DropInComponent.Configuration(style: style)
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        context: context,
                                        configuration: configuration)
        ```
    }
    
    @Tab(Components) { 
        ```swift
        var style = FormComponentStyle()
        style.backgroundColor = .black
        style.header.title.color = .white
        style.textField.title.color = .white
        style.textField.text.color = .white
        style.switch.title.color = .white

        let config = CardComponent.Configuration(style: style)
        let component = CardComponent(paymentMethod: paymentMethod,
                                      context: context,
                                      configuration: config)
        ```
    }
}

## Custom Payment Method Display Information

The following examples provide custom information to show for a specific payment method

@TabNavigator {
    @Tab(Drop-in) {  
        
        
        ```swift
        // Override the (regular) payment method of type `.scheme` with custom display information
        paymentMethods.overrideDisplayInformation(
            ofRegularPaymentMethod: .scheme,
            with: .init(
                title: "Custom Cards title",
                subtitle: "Custom Cards description"
            )
        )
        ```
        
        ```swift
        // Override the (regular) `.giftcard` payment method if the brand is "genericgiftcard"
        paymentMethods.overrideDisplayInformation(
            ofRegularPaymentMethod: .giftcard,
            with: .init(
                title: "Custom Giftcard title",
                subtitle: "Custom Giftcard subtitle"
                ),
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "genericgiftcard"
            }
        )
        ```
        
        To override the display information for stored payment methods use:
        
        ```swift
        paymentMethods.overrideDisplayInformation(
            ofStoredPaymentMethod: ...
        )
        ```
    }
    
    @Tab(Components) {
        For components you can either set the `merchantProvidedDisplayInformation` directly before creating the component or use the same approach as with **Drop-In**.
        ```swift
        cardPaymentMethod.merchantProvidedDisplayInformation = .init(
            title: "Custom Card Title"
        )
        
        let component = CardComponent(
            paymentMethod: cardPaymentMethod,
            context: context,
            configuration: config
        )
        ```
    }
}

For a full list of customization options can be found in the <doc:API-Reference>.
