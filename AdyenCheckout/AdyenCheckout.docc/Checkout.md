# ``Checkout``

The entry point for setting up an Adyen Checkout flow.

## Overview

Use ``Checkout`` to set up a checkout for the session flow or for action handling only. Pass the flow's callbacks value to `setup`: `CheckoutCallbacks` for a session or `ActionOnlyCheckoutCallbacks` for action handling. Session setup returns `PaymentCheckout`; action-only setup returns `ActionOnlyCheckout`.

## Topics

### Setting up a checkout

- ``PaymentCheckout``
- ``ActionOnlyCheckout``
- ``BaseCheckout``

### Callbacks

- ``CheckoutCallbacks``
- ``ActionOnlyCheckoutCallbacks``

### Configuration

- ``CheckoutConfiguration``
- ``CheckoutConfigurationBuilder``

### Components

- ``CheckoutPaymentComponent``
