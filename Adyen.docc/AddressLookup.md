#  Address Lookup

Address Lookup allows using your own or a 3rd party service (e.g. Google Maps, MapKit, ...) to lookup an address based on a search term.

You can use Address Lookup by specifying the ``BillingAddressConfiguration/mode``

### Card Component
```swift
let cardConfiguration = CardComponent.Configuration()
// Setting the billing address mode to lookup by providing 
// your own lookup provider conforming to "AddressLookupProvider"
cardConfiguration.billingAddress.mode = .lookup(MyAddressLookupProvider())

let cardComponent = CardComponent(paymentMethod: paymentMethod,
                                  context: context,
                                  configuration: cardConfiguration)
```

### Drop-In
```swift
let dropInConfiguration = DropInComponent.Configuration()
// Setting the billing address mode to lookup by providing 
// your own lookup provider conforming to "AddressLookupProvider"
dropInConfiguration.card.billingAddress.mode = .lookup(MyAddressLookupProvider())

let dropInComponent = DropInComponent(paymentMethods: paymentMethods,
                                      context: context,
                                      configuration: dropInConfiguration)
```

For example implementations of the ``AddressLookupProvider`` check the ``DemoAddressLookupProvider`` or ``MapkitAddressLookupProvider``
