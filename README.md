# Yandex Checkout Payments SDK

[![GitHub tag](https://img.shields.io/github/tag/yandex-money/yandex-checkout-payments-swift.svg)](https://img.shields.io/github/tag/yandex-money/yandex-checkout-payments-swift.svg)
[![license](https://img.shields.io/github/license/yandex-money/yandex-checkout-payments-swift.svg)](https://img.shields.io/github/license/yandex-money/yandex-checkout-payments-swift.svg)

## Overview

This library allows you to make payments via Yandex.Money APIv3 easily with our incredible UI.

## Usage

### Setup Yandex.Login

- Register your App at [OAuth Yandex](https://oauth.yandex.ru/) and save your __ID__.
- Add to yor __info.plist__:

```plistbase
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>yandexauth</string>
	<string>yandexauth2</string>
</array>
```

- In _Capabilities_ section of you Project enable _Associated Domains_ and add domain: `applinks:yx<ID>.oauth.yandex.ru` where `<ID>` is __ID__ from first step. For instance if your App __ID__ is 333, the domain is `applinks:yx333.oauth.yandex.ru`
- Add into _AppDelegate_:

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    do {
        try YandexLoginService.activate(withAppId: /* Your App ID */)
    } catch {
        // process error
    }
}

func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    YandexLoginService.processUserActivity(userActivity)
    return true
}

func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
    return YandexLoginService.handleOpen(url, sourceApplication: options[.sourceApplication] as? String)
}
```

### Payments

First you need to get [client application key](https://money.yandex.ru/my/tunes) and create `TokenizationModuleInputData`.

```swift
import YandexCheckoutPayments

// Your clientId and clientSecret
let clientApplicationKey = "<Past your client application key here>"
let amount = Amount(value: <Past price of purchase>, currency: <Past currency>),

let inputData = TokenizationModuleInputData(clientApplicationKey: clientApplicationKey,
                                            shopName: "<Past your shop name here>",
                                            purchaseDescription: """
                                                    <Past description of purchase here>
                                                    """,
                                            amount: amount)
```

To start tokenization process you need to create Tokenization View controller from Tokenization assembly and present
received view controller.

```swift
let viewController = TokenizationAssembly.makeModule(inputData: inputData,
                                                     moduleOutput: self)
present(viewController, animated: true, completion: nil)
```

When the payment process is complete you should dismiss received view controller and send token to your back-end:

```swift
func tokenizationModule(_ module: TokenizationModuleInput,
                        didTokenize token: Tokens,
                        paymentMethodType: PaymentMethodType) {
    DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else { return }
        strongSelf.dismiss(animated: true)
    }
    // Send token to your back-end
}

func didFinish(on module: TokenizationModuleInput) {
    DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else { return }
        strongSelf.dismiss(animated: true)
    }
}
```

### CardScanning

If you want to use a scan card, you must implement the protocol CardScanning and pass this object to 
TokenizationModuleInputData. 

```swift
class CardScannerProvider: CardScanning {
    weak var cardScanningDelegate: CardScanningDelegate?

    var cardScanningViewController: UIViewController? {

        // Create and return scanner view controller
        
        viewController.delegate = self
        
        return viewController
    }
}
```

Next, implement you scanner delegate for `CardScanerProvider` (for example, CardIO):

```swift
// MARK: - CardIOPaymentViewControllerDelegate

extension CardScannerProvider: CardIOPaymentViewControllerDelegate {
    public func userDidProvide(_ cardInfo: CardIOCreditCardInfo!,
                               in paymentViewController: CardIOPaymentViewController!) {
        let scannedCardInfo = ScannedCardInfo(number: cardInfo.cardNumber,
                                              expiryMonth: "\(cardInfo.expiryMonth)",
                                              expiryYear: "\(cardInfo.expiryYear)")
        cardScanningDelegate?.cardScannerDidFinish(scannedCardInfo)
    }

    public func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        cardScanningDelegate?.cardScannerDidFinish(nil)
    }
}
```

Then when initialize input data pass `CardScannerProvider` to `cardScanning:` argument.

```swift
let inputData = TokenizationModuleInputData(clientApplicationKey: clientApplicationKey,
                                            shopName: "<Past your shop name here>",
                                            purchaseDescription: """
                                                    <Past description of purchase here>
                                                    """,
                                            amount: amount,
                                            cardScanning: CardScannerProvider())
```

### 3DSecure

If you want to use our implementation of 3D Secure, you don't have to dismiss our UIViewController after 
receiving the token. Send the token to your server and after successful payment dismiss UIViewController.
If your server has reported the need to confirm the payment, call the method 
`start3dsProcess(requestUrl:redirectUrl:)`

After successful completion of the 3D secure process, the method will be called
`didSuccessfullyPassedCardSec(on module:)` which is specified in the protocol `TokenizationModuleOutput`

* Store tokenization module

```swift
self.tokenizationViewController = TokenizationAssembly.makeModule(inputData: inputData,
                                                                 moduleOutput: self)
present(self.tokenizationViewController, animated: true, completion: nil)
```

* Doesn't hide tokenization after receive the token

```swift
func tokenizationModule(_ module: TokenizationModuleInput,
                        didTokenize token: Tokens,
                        paymentMethodType: PaymentMethodType) {
    // Send token to your back-end
}
```

* Show 3DSecure if need to confirm payment

```swift
func needConfirmPayment(requestUrl: String, redirectUrl: String) {
    self.tokenizationViewController.start3dsProcess(requestUrl: requestUrl, redirectUrl: redirectUrl)
}
```

* After success 3DSecure process will be called

```swift
func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {
    DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else { return }
        
        // Now close tokenization module
        strongSelf.dismiss(animated: true)
    }
}
```

### Apple Pay

Follow the steps described in the official 
[documentation](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay_requirements) 
from Apple.

Send merchant 
[apple pay identifier](https://help.apple.com/xcode/mac/current/#/deva43983eb7?sub=dev171483d6e) 
to msdk.

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applePayMerchantIdentifier: "<com.example...>")
```
