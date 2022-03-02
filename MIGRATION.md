#  Migration Notes

## 5.0.0

- `AffirmComponent.style`, `AffirmComponent.shopperInformation` and `AffirmComponent.localizationParameters` moved into new `configuration` property `AffirmComponentConfiguration`
- `DokuComponent.style`, `DokuComponent.shopperInformation` and `DokuComponent.localizationParameters` moved into new `configuration` property `DokuComponentConfiguration`
- `MBWayComponent.style`, `MBWayComponent.shopperInformation` and `MBWayComponent.localizationParameters` moved into new `configuration` property `MBWayComponentConfiguration`
- `QiwiWalletComponent.style` and `QiwiWalletComponent.localizationParameters` moved into new `configuration` property `QiwiWalletComponentConfiguration`
- `BasicPersonalInfoFormComponent.style` and `BasicPersonalInfoFormComponent.localizationParameters` moved into new `configuration` property `BasicPersonalInfoComponentConfiguration`
- `AdyenActionComponent.localizationParameters`, and `AdyenActionComponent.style` moved to `AdyenActionComponent.configuration`
- `ThreeDS2Component.appearanceConfiguration` and `ThreeDS2Component.redirectComponentStyle` moved to `ThreeDS2Component.configuration`
- `AwaitComponent.style` and `AwaitComponent.localizationParameters` moved to `AwaitComponent.configuration`
- `QRCodeComponent.style` and `QRCodeComponent.localizationParameters` moved to `QRCodeComponent.configuration`
- `VoucherComponent.style` and `VoucherComponent.localizationParameters` moved to `VoucherComponent.configuration`
- `RedirectComponent.style` moved to `RedirectComponent.configuration`
- `DocumentComponent.style` and `DocumentComponent.localizationParameters` moved to `DocumentComponent.configuration`
- `DropInComponentDelegate` has been refactored to be more transparent about which action component or payment component caused the call back.
