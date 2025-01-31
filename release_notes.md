# Changes since last release


## new
    
    
    - Added support for distinguishing between regular and native redirects
    to improve handling of failed native redirect flows.
    
    

## changed
    
    
    - For [native 3D Secure
    2](https://docs.adyen.com/online-payments/3d-secure/native-3ds2/?platform=iOS&integration=Drop-in&version=5.0.0+and+later),
    when a shopper cancels the payment during the payment flow, the
    `didProvide(...`) delegate method is now triggered. What this means for
    your integration depends on whether you already make a
    `/payments/details` call to handle 3D Secure 2 errors:
    
       - If yes, you do not need to make any changes to your integration.
    - If not, update your integration to make a `/payments/details` request
    to get the details of the canceled transaction.
    
    
    
    You can now highlight a list item by changing its background color when
    the shopper selects it. To do this, use the new optional
    `ListItemStyle.highlightedBackgroundColor` property.
    
     This is a changed text wrapped in XML tag 

## fixed
    
    For Drop-in, some components that are used in the same Drop-in session no longer have stale parts such as the following:
    - For gift cards, error messages.
    - For cards, brand logos.
    
# Changes since last release


## fixed
    
    -  Fixed Action jobs.
    
