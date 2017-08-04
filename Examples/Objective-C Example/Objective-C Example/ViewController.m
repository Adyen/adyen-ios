//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "ViewController.h"
#import "Objective_C_Example-Swift.h"

@interface ViewController () <PaymentManagerDelegate>

@property (nonatomic, strong) PaymentManager *paymentManager;

@end

@implementation ViewController

- (IBAction)didSelectCheckoutButton:(id)sender {
    [[self paymentManager] beginPaymentWithHostViewController:self];
}

- (void)applicationDidOpenURL:(NSURL *)URL {
    [[self paymentManager] applicationDidOpenURL:URL];
}

#pragma mark -
#pragma mark Payment Manager

- (PaymentManager *)paymentManager {
    if (_paymentManager) {
        return _paymentManager;
    }
    
    PaymentManager *paymentManager = [[PaymentManager alloc] init];
    [paymentManager setDelegate:self];
    _paymentManager = paymentManager;
    
    return paymentManager;
}

- (void)paymentManager:(PaymentManager *)paymentManager didFinishWithResult:(PaymentManagerResult *)result {
    NSString *alertTitle = [self alertTitleForPaymentManagerResult:result];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)alertTitleForPaymentManagerResult:(PaymentManagerResult *)result {
    switch ([result status]) {
        case PaymentManagerResultStatusReceived:
            return @"Payment received";
        case PaymentManagerResultStatusAuthorised:
            return @"Payment authorised";
        case PaymentManagerResultStatusRefused:
            return @"Payment refused";
        case PaymentManagerResultStatusCancelled:
            return @"Payment canceled";
        case PaymentManagerResultStatusError:
            return [NSString stringWithFormat:@"Payment failed with error (%@)", [result error]];
    }
}

@end
