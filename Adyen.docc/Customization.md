# Customization

Both the Drop-in and the Components offer a number of customization options to allow you to match the appearance of your app.

## Drop-in

For example, to change the section header titles and form field titles in the Drop-in to red, and turn the submit button's background to black with white foreground:
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

## Components

To create a black Card Component with white text:
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

For a full list of customization options can be found in the API Reference.
