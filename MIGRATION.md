#  Migration Notes

## 5.0.0

- `AffirmComponent.style`, `AffirmComponent.shopperInformation` and `AffirmComponent.localizationParameters` moved into new `configuration` property `AffirmComponent.Configuration`
- `DokuComponent.style`, `DokuComponent.shopperInformation` and `DokuComponent.localizationParameters` moved into new `configuration` property `DokuComponent.Configuration`
- `MBWayComponent.style`, `MBWayComponent.shopperInformation` and `MBWayComponent.localizationParameters` moved into new `configuration` property `MBWayComponent.Configuration`
- `QiwiWalletComponent.style` and `QiwiWalletComponent.localizationParameters` moved into new `configuration` property `QiwiWalletComponent.Configuration`
- `BasicPersonalInfoFormComponent.style` and `BasicPersonalInfoFormComponent.localizationParameters` moved into new `configuration` property `BasicPersonalInfoFormComponent.Configuration`
- `ACHDirectDebitComponent.style`, `ACHDirectDebitComponent.shopperInformation` and `ACHDirectDebitComponent.localizationParameters` moved into the `configuration` property `ACHDirectDebitComponent.Configuration`
- `BACSDirectDebitComponent.style`, `BACSDirectDebitComponent.shopperInformation` and `BACSDirectDebitComponent.localizationParameters` moved into the `configuration` property `BACSDirectDebitComponent.Configuration`
- `BLIKComponent.style` and `BLIKComponent.localizationParameters` moved into new `configuration` property `BLIKComponent.Configuration`
- `BoletoComponent.style`, `BoletoComponent.shopperInformation` and `BoletoComponent.localizationParameters` moved into the `configuration` property `BoletoComponent.Configuration`
- `IssuerListComponent.style` and `IssuerListComponent.localizationParameters` moved into new `configuration` property `IssuerListComponent.Configuration`
- `SEPADirectDebitComponent.style` and `SEPADirectDebitComponent.localizationParameters` moved into new `configuration` property `SEPADirectDebitComponent.Configuration`
- `ThreeDS2Component.appearanceConfiguration` and `ThreeDS2Component.redirectComponentStyle` moved to `ThreeDS2Component.configuration`
- `AwaitComponent.style` and `AwaitComponent.localizationParameters` moved to `AwaitComponent.configuration`
- `QRCodeComponent.style` and `QRCodeComponent.localizationParameters` moved to `QRCodeComponent.configuration`
- `VoucherComponent.style` and `VoucherComponent.localizationParameters` moved to `VoucherComponent.configuration`
- `RedirectComponent.style` moved to `RedirectComponent.configuration`
- `DocumentComponent.style` and `DocumentComponent.localizationParameters` moved to `DocumentComponent.configuration`
- `DropInComponentDelegate` has been refactored to be more transparent about which action component or payment component caused the call back.
