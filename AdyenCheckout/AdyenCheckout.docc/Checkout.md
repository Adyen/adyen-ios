# ``Checkout``

A checkout that creates payment components and handles payment actions.

## Overview

Use ``Checkout`` to set up and retain a checkout instance. Pass `CheckoutCallbacks` and a session response to create a `Checkout`, or `ActionOnlyCheckoutCallbacks` to create an `ActionOnlyCheckout`. The two types expose the operations for their integration and own their core directly.

## Topics

### Setting up a checkout

- ``setup(with:configuration:callbacks:)``
- ``setup(configuration:callbacks:)``
- ``ActionOnlyCheckout``

### Callbacks

- ``CheckoutCallbacks``
- ``ActionOnlyCheckoutCallbacks``

### Configuration

- ``CheckoutConfiguration``
- ``CheckoutConfigurationBuilder``

### Components

- ``CheckoutPaymentComponent``
