# YooMoney for Business Payments SDK (YooKassaPayments)

[![Platform](https://img.shields.io/badge/Support-iOS%2010.0+-brightgreen.svg)](https://img.shields.io/badge/Support-iOS%2010.3+-brightgreen.svg)
[![GitHub tag](https://img.shields.io/github/tag/yoomoney/yookassa-payments-swift.svg)](https://img.shields.io/github/tag/yoomoney/yookassa-payments-swift.svg)
[![Documentation](docs/badge.svg)](docs/badge.svg)
[![License](https://img.shields.io/github/license/yoomoney/yookassa-payments-swift.svg)](https://img.shields.io/github/license/yoomoney/yookassa-payments-swift.svg)

This library allows implementing payment acceptance into mobile apps on iOS and works as an extension to the YooMoney API.\
The mobile SDK contains ready-made payment interfaces (the payment form and everything related to it).\
Using the SDK, you can receive tokens for processing payments via bank cards, Apple Pay, Sberbank Online, or YooMoney wallets.

- [Library code](https://github.com/yoomoney/yookassa-payments-swift/tree/master/YooKassaPayments)
- [Code of the demo app which integrates the SDK](https://github.com/yoomoney/yookassa-payments-swift/tree/master/YooKassaPaymentsExample)
- [Documentation](https://yoomoney.github.io/yookassa-payments-swift/)

---

- [YooMoney for Business Payments SDK (YooKassaPayments)](#yookassa-payments-sdk-yookassapayments)
  - [Changelog](#changelog)
  - [Migration guide](#migration-guide)
  - [Adding dependencies](#adding-dependencies)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
  - [Implementing TMXProfiling and TMXProfilingConnections](#implementing-tmxprofiling-and-tmxprofilingconnections)
  - [Quick integration](#quick-integration)
  - [Available payment methods](#available-payment-methods)
  - [Setting up payment methods](#setting-up-payment-methods)
    - [YooMoney](#yoomoney)
      - [How to get `client id` of the YooMoney authorization center](#how-to-get-client-id-of-the-yoomoney-authorization-center)
      - [Entering `client id` in the `moneyAuthClientId` parameter](#entering-client-id-in-the-moneyauthclientid-parameter)
      - [Support of authorization via the mobile app](#support-of-the-authorization-via-the-mobile-app)
    - [Bank cards](#bank-cards)
    - [SberPay](#sberpay)
    - [Apple Pay](#apple-pay)
  - [Description of public parameters](#description-of-public-parameters)
    - [TokenizationFlow](#tokenizationflow)
    - [YooKassaPaymentsError](#yookassapaymentserror)
    - [TokenizationModuleInputData](#tokenizationmoduleinputdata)
    - [BankCardRepeatModuleInputData](#bankcardrepeatmoduleinputdata)
    - [TokenizationSettings](#tokenizationsettings)
    - [TestModeSettings](#testmodesettings)
    - [Amount](#amount)
    - [Currency](#currency)
    - [CustomizationSettings](#customizationsettings)
    - [SavePaymentMethod](#savepaymentmethod)
  - [Scanning bank cards](#scanning-bank-cards)
  - [Setting up payment confirmation](#setting-up-payment-confirmation)
  - [Logging](#logging)
  - [Test mode](#test-mode)
  - [Launching Example](#launching-example)
  - [Interface customization](#interface-customization)
  - [Payments via bank cards linked to the store with an additional CVC/CVV request](#payments-via-bank-cards-linked-to-the-store-with-an-additional-cvccvv-request)
  - [License](#license)

## Changelog

[Link to the Changelog](https://github.com/yoomoney/yookassa-payments-swift/blob/master/CHANGELOG.md)

## Migration guide

[Link to the Migration guide](https://github.com/yoomoney/yookassa-payments-swift/blob/master/MIGRATION.md)

## Adding dependencies

### CocoaPods

1. Install CocoaPods version 1.10.0 or higher.

```zsh
gem install cocoapods
```

[Official documentation for installing CocoaPods](https://guides.cocoapods.org/using/getting-started.html#updating-cocoapods).\
[Available CocoaPods versions](https://github.com/CocoaPods/CocoaPods/releases).

1. Create Podfile

> CocoaPods provides the `pod init` command for creating Podfile with default settings.

2. Add dependencies to `Podfile`.\
  [Example](https://github.com/yoomoney/yookassa-payments-swift/tree/master/YooKassaPaymentsExample/Podfile-example) of `Podfile` from the demo app.

```shell
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/yoomoney-tech/cocoa-pod-specs.git'

platform :ios, '10.0'
use_frameworks!

target 'Your Target Name' do
  pod 'YooKassaPayments',
    :git => 'https://github.com/yoomoney/yookassa-payments-swift.git',
    :tag => 'tag'
end
```

> `Your Target Name`: name of the target in Xcode for your app.\
> `tag`: SDK version. You can find information about the latest version in the [releases](https://github.com/yoomoney/yookassa-payments-swift/releases) section on github.

> If you use static linkage, you need to activate the `cocoapods-user-defined-build-types` plugin:

```shell
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/yoomoney-tech/cocoa-pod-specs.git'

plugin 'cocoapods-user-defined-build-types'
enable_user_defined_build_types!

platform :ios, '10.0'

target 'Your Target Name' do
  pod 'YooKassaPayments',
    :build_type => :dynamic_framework,
    :git => 'https://github.com/yoomoney/yookassa-payments-swift.git',
    :tag => 'tag'
end
```

3. Run the `pod install` command

### Carthage

At the moment, Carthage is not supported.

## Implementing TMXProfiling and TMXProfilingConnections

To get the `.xcframework` file, [sign up for YooMoney](https://yookassa.ru/joinups)
and tell your manager that you'd like to implement the mobile SDK.

1. Using Finder or a different file manager, add the `TMXProfiling.xcframework` and `TMXProfilingConnections.xcframework` libraries to the project folder.

2. Add `TMXProfiling.xcframework` and `TMXProfilingConnections.xcframework` in `Frameworks, Libraries, and Embedded Content` for the main target of the project under the `General` section.

3. `TMXProfiling.xcframework` and `TMXProfilingConnections.xcframework` must be added with `Embed & Sign`

## Quick integration

1. Create `TokenizationModuleInputData` (you'll need a [key for client apps](https://yookassa.ru/my/tunes) from the YooMoney Merchant Profile). Payment parameters (currency and amount) and payment form parameters which users will see during the payment (payment methods, store name, and order description) are specified in this model.

> To work with YooKassaPayments entities, import dependencies to the original file

```swift
import YooKassaPayments
```

Example for creating `TokenizationModuleInputData`:

```swift
let clientApplicationKey = "<Key for client apps>"
let amount = Amount(value: 999.99, currency: .rub)
let tokenizationModuleInputData =
          TokenizationModuleInputData(clientApplicationKey: clientApplicationKey,
                                      shopName: "Space objects",
                                      purchaseDescription: """
                                                            An extra bright comet, rotation period: 112 years
                                                            """,
                                      amount: amount,
                                      savePaymentMethod: .on)
```

2. Create `TokenizationFlow` with the `.tokenization` case and enter `TokenizationModuleInputData`.

Example of creating `TokenizationFlow`:

```swift
let inputData: TokenizationFlow = .tokenization(tokenizationModuleInputData)
```

3. Create `ViewController` from `TokenizationAssembly` and put it on the screen.

```swift
let viewController = TokenizationAssembly.makeModule(inputData: inputData,
                                                       moduleOutput: self)
present(viewController, animated: true, completion: nil)
```

You need to specify the object which implements the `TokenizationModuleOutput` in `moduleOutput`.

4. Implement the `TokenizationModuleOutput` protocol.

```swift
extension ViewController: TokenizationModuleOutput {
    func tokenizationModule(
        _ module: TokenizationModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        // Send the token to your system
    }

    func didFinish(
        on module: TokenizationModuleInput,
        with error: YooKassaPaymentsError?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }

    func didSuccessfullyConfirmation(
        paymentMethodType: PaymentMethodType
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Create a success screen after confirmation is completed (3DS or SberPay)
            self.dismiss(animated: true)
            // Display the success screen
        }
    }
}
```

Close the SDK module and send the token to your system. After that, [create a payment](https://yookassa.ru/developers/api#create_payment) via the YooMoney API, enter the token you received in the SDK in the `payment_token` parameter. When a payment is created, the confirmation method depends on the payment method selected by the user. It's sent with the token in `paymentMethodType`.

## Available payment methods

The following payment methods are currently supported in SDK for iOS:

`.yooMoney`: YooMoney (payments via the wallet or linked cards)\
`.bankCard`: bank cards (cards can be scanned)\
`.sberbank`: SberPay (with confirmation via the Sberbank Online mobile app if it's installed; otherwise, payments will be confirmed via text messages)\
`.applePay`: Apple Pay

## Setting up payment methods

You can configure payment methods.\
To do that, you need to enter a model of the `TokenizationSettings` type in the `tokenizationSettings` parameter when creating `TokenizationModuleInputData`.

> Additional configuration is required for some payment methods (see below).\
> By default, all available payment methods are used.

```swift
// Create empty OptionSet PaymentMethodTypes
var paymentMethodTypes: PaymentMethodTypes = []

if <Condition for bank cards> {
    // Adding the `.bankCard` element to paymentMethodTypes
    paymentMethodTypes.insert(.bankCard)
}

if <Condition for Sberbank Online> {
    // Adding the `.sberbank` element to paymentMethodTypes
    paymentMethodTypes.insert(.sberbank)
}

if <Condition for YooMoney> {
    // Adding the `.yooMoney` element to paymentMethodTypes
    paymentMethodTypes.insert(.yooMoney)
}

if <Condition for Apple Pay> {
    // Adding the `.applePay` element to paymentMethodTypes
    paymentMethodTypes.insert(.applePay)
}

let tokenizationSettings = TokenizationSettings(paymentMethodTypes: paymentMethodTypes)
```

Now use `tokenizationSettings` when initializing `TokenizationModuleInputData`.

### YooMoney

To add `YooMoney` as a payment method, you need to:

1. Receive `client id` of the `YooMoney` authorization center.
2. Enter `client id` in the `moneyAuthClientId` parameter when creating `TokenizationModuleInputData`

#### How to get `client id` of the `YooMoney` authorization center

1. Sign in at [yookassa.ru](https://yookassa.ru)
2. Go to the page for signing up in the authorization center: [yookassa.ru/oauth/v2/client](https://yookassa.ru/oauth/v2/client)
3. Click [Sign up](https://yookassa.ru/oauth/v2/client/create)
4. Fill in the following fields:\
4.1. "Name": a `required` field, it's displayed in the list of apps and when rights are provided.\
4.2. "Description": an `optional` field, it's displayed to the user in the list of apps.\
4.3. "Link to app's website": an `optional` field, it's displayed to the user in the list of apps.\
4.4. "Confirmation code": select `Specify in Callback URL`, you can enter any value, for example, a link to a website.
5. Select accesses:\
5.1. `YooMoney wallet` -> `View`\
5.2. `YooMoney account` -> `View`
6. Click `Sign up`

#### Entering `client id` in the `moneyAuthClientId` parameter

Enter `client id` in the `moneyAuthClientId` parameter when creating `TokenizationModuleInputData`

```swift
let moduleData = TokenizationModuleInputData(
    ...
    moneyAuthClientId: "client_id")
```

To process a payment:

1. Enter `.yooMoney` as the value in `paymentMethodTypes.` when creating `TokenizationModuleInputData`
2. Receive a token.
3. [Create a payment](https://yookassa.ru/developers/api#create_payment) with the token via the YooMoney API.

#### Support of authorization via the mobile app

1. You need to specify `applicationScheme`, the scheme for returning to the app after a successful sign-in to `YooMoney` via the mobile app, in `TokenizationModuleInputData`.

Example of `applicationScheme`:

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applicationScheme: "examplescheme://"
```

2. Import the `YooKassaPayments` dependency in `AppDelegate`:

   ```swift
   import YooKassaPayments
   ```

3. Add processing links via `YKSdk` in `AppDelegate`:

```swift
func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: sourceApplication
    )
}

@available(iOS 9.0, *)
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
    )
}
```

4. Add the following rows to `Info.plist`:

```plistbase
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>yoomoneyauth</string>
</array>
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>${BUNDLE_ID}</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>examplescheme</string>
		</array>
	</dict>
</array>
```

where `examplescheme` is the scheme for opening your app that you specified in `applicationScheme` when creating `TokenizationModuleInputData`. This scheme will be used to open you app after a successful sign-in to `YooMoney` via the mobile app.

### Bank cards

1. Enter `.bankcard` as the value in `paymentMethodTypes` when creating `TokenizationModuleInputData`.
2. Receive a token.
3. [Create a payment](https://yookassa.ru/developers/api#create_payment) with the token via the YooMoney API.

### SberPay

Using the SDK, you can process payments via Sberbank's "Mobile banking". Payments are confirmed via the Sberbank Online app if it's installed or otherwise via text messages.

You need to specify `applicationScheme`, the scheme for returning to the app after a successful payment via `SberPay` in the Sberbank Online app, in `TokenizationModuleInputData`.

Example of `applicationScheme`:

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applicationScheme: "examplescheme://"
```

To process a payment:

1. Enter `.sberbank` as the value in `paymentMethodTypes` when creating `TokenizationModuleInputData`.
2. Receive a token.
3. [Create a payment](https://yookassa.ru/developers/api#create_payment) with the token via the YooMoney API.

Payment confirmation via the Sberbank Online app:

1. Import the `YooKassaPayments` dependency in `AppDelegate`:

   ```swift
   import YooKassaPayments
   ```

2. Add processing link via `YKSdk` in `AppDelegate`:

```swift
func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: sourceApplication
    )
}

@available(iOS 9.0, *)
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
    )
}
```

3. Add the following rows to `Info.plist`:

```plistbase
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>sberpay</string>
</array>
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>${BUNDLE_ID}</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>examplescheme</string>
		</array>
	</dict>
</array>
```

where `examplescheme` is the scheme for opening your app that you specified in `applicationScheme` when creating `TokenizationModuleInputData`. This scheme will be used to open you app after a successful payment via `SberPay`.

4. Implement the `didSuccessfullyConfirmation(paymentMethodType:)` method of the `TokenizationModuleOutput` protocol which will be called after a successful payment confirmation (see [Setting up payment confirmation](#setting-up-payment-confirmation)).

### Apple Pay

1. To implement Apple Pay, you need to provide a certificate, using which Apple will encrypt bank card details, to YooMoney.

In order to do it:

- Contact your manager and ask them to create a request for a certificate (`.csr`) for you.
- Create a certificate in Apple Developer Tools (use `.csr`).
- Download the certificate you created and send it to your manager.

[Full manual](https://yookassa.ru/files/manual_connection_Apple_Pay(website).pdf) (see Section 2. Exchanging certificates with Apple)

2. Enable Apple Pay in Xcode.

To process a payment:

1. You need to enter the [apple pay identifier](https://help.apple.com/xcode/mac/current/#/deva43983eb7?sub=dev171483d6e) in the `applePayMerchantIdentifier` parameter when initializing the `TokenizationModuleInputData` object.

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applePayMerchantIdentifier: "com.example.identifier"
```
2. Receive a token.
3. [Create a payment](https://yookassa.ru/developers/api#create_payment) with the token via the YooMoney API.

## Description of public parameters

### TokenizationFlow

`Enum` which determines the logic of how the SDK operates.

| Case           | Type              | Description |
| -------------- | ---------------- | -------- |
| tokenization   | TokenizationFlow | Receives the `TokenizationModuleInputData` model as input. Logic for tokenizing multiple payment method options: Bank card, YooMoney, Sberbank Online, or Apple Pay |
| bankCardRepeat | TokenizationFlow | Receives the `BankCardRepeatModuleInputData`model as input. Logic for tokenizing saved payment methods using the payment method ID |

### YooKassaPaymentsError

`Enum` with possible errors which can be processed in the  `func didFinish(on module:, with error:)` method

| Case                  | Type   | Description |
| --------------------- | ----- | -------- |
| paymentMethodNotFound | Error | No saved payment methods were found using paymentMethodId. |

### TokenizationModuleInputData

>Required parameters:

| Parameter             | Type    | Description |
| -------------------- | ------ | -------- |
| clientApplicationKey | String            | Key for client apps from the YooMoney Merchant Profile |
| shopName             | String            | Store name in the payment form |
| purchaseDescription  | String            | Order description in the payment form |
| amount               | Amount            | Object containing the order amount and currency |
| savePaymentMethod    | SavePaymentMethod | Object containing the logic for determining if it's going to be a recurring payment |

>Optional parameters:

| Parameter                   | Type                   | Description                                                     |
| -------------------------- | --------------------- | ------------------------------------------------------------ |
| gatewayId                  | String                | By default: `nil`. Used if you have multiple payment gateways with different IDs. |
| tokenizationSettings       | TokenizationSettings  | The standard initializer with all the payment methods is used by default. This parameter is used for setting up tokenization (payment methods and the YooMoney logo). |
| testModeSettings           | TestModeSettings      | By default: `nil`. Test mode settings.              |
| cardScanning               | CardScanning          | By default: `nil`. Feature of scanning bank cards. |
| applePayMerchantIdentifier | String                | By default: `nil`. Apple Pay merchant ID (required for payments via Apple Pay). |
| returnUrl                  | String                | By default: `nil`. URL of the page (only `https` supported) where you need to return after completing 3-D Secure. Only required for custom implementation of 3-D Secure. If you use `startConfirmationProcess(confirmationUrl:paymentMethodType:)`, don't specify this parameter. |
| isLoggingEnabled           | Bool                  | By default: `false`. Enables logging of network requests. |
| userPhoneNumber            | String                | By default: `nil`. User's phone number.           |
| customizationSettings      | CustomizationSettings | The blueRibbon color is used by default. Color of the main elements, button, switches, and input fields. |
| moneyAuthClientId          | String                | By default: `nil`. ID for the center of authorizationin the YooMoney system |
| applicationScheme          | String                | By default: `nil`. Scheme for returning to the app after a successful payment via `Sberpay` in the Sberbank Online app or after a successful sign-in to `YooMoney` via the mobile app. |
### BankCardRepeatModuleInputData

>Required parameters:

| Parameter             | Type    | Description |
| -------------------- | ------ | -------- |
| clientApplicationKey | String | Key for client apps from the YooMoney Merchant Profile |
| shopName             | String | Store name in the payment form |
| purchaseDescription  | String | Order description in the payment form |
| paymentMethodId      | String | ID of the saved payment method |
| amount               | Amount | Object containing the order amount and currency |
| savePaymentMethod | SavePaymentMethod | Object containing the logic for determining if it's going to be a recurring payment |

>Optional parameters:

| Parameter              | Type                   | Description                                                     |
| --------------------- | --------------------- | ------------------------------------------------------------ |
| testModeSettings      | TestModeSettings      | By default: `nil`. Test mode settings.              |
| returnUrl             | String                | By default: `nil`. URL of the page (only `https` supported) where you need to return after completing 3-D Secure. Only required for custom implementation of 3-D Secure. If you use `startConfirmationProcess(confirmationUrl:paymentMethodType:)`, don't specify this parameter. |
| isLoggingEnabled      | Bool                  | By default: `false`. Enables logging of network requests. |
| customizationSettings | CustomizationSettings | The blueRibbon color is used by default. Color of the main elements, button, switches, and input fields. |
| gatewayId             | String                | By default: `nil`. Used if you have multiple payment gateways with different IDs. |

### TokenizationSettings

You can configure the list of payment methods and how the YooMoney logo is displayed in the app.

| Parameter               | Type                | Description |
| ---------------------- | ------------------ | -------- |
| paymentMethodTypes     | PaymentMethodTypes | By default: `.all`. [Payment methods](#setting-up-payment-methods) available to the user in the app. |
| showYooKassaLogo       | Bool               | By default: `true`. It determines if the YooMoney logo is displayed. By default, the logo is displayed. |

### TestModeSettings

| Parameter                   | Type    | Description |
| -------------------------- | ------ | -------- |
| paymentAuthorizationPassed | Bool   | It determines if the payment authorization has been completed for payments via YooMoney. |
| cardsCount                 | Int    | Number of cards linked to the YooMoney wallet. |
| charge                     | Amount | Payment amount and currency. |
| enablePaymentError         | Bool   | It determines if the payment is completed with an error. |

### Amount

| Parameter | Type      | Description |
| -------- | -------- | -------- |
| value    | Decimal  | Payment amount |
| currency | Currency | Payment currency |

### Currency

| Parameter | Type      | Description |
| -------- | -------- | -------- |
| rub      | String   | ₽ - Russian ruble |
| usd      | String   | $ - U.S. dollar |
| eur      | String   | € - Euro |
| custom   | String   | The value you entered will be displayed |

### CustomizationSettings

| Parameter   | Type     | Description |
| ---------- | ------- | -------- |
| mainScheme | UIColor | The blueRibbon color is used by default. Color of the main elements, button, switches, and input fields. |

### SavePaymentMethod

| Parameter    | Type               | Description |
| ----------- | ----------------- | -------- |
| on          | SavePaymentMethod | Save the payment method for processing recurring payments. Only payment methods which support saving will be available to the user. A notification that the payment method will be saved will be displayed on the contract screen. |
| off         | SavePaymentMethod | It doesn't allow the user to choose if the payment method should be saved or not. |
| userSelects | SavePaymentMethod | User chooses if the payment method should be saved or not. If the payment method can be saved, a switch will appear on the contract screen. |

## Scanning bank cards

If you want users to be able to scan bank cards when making payments, you need to:

1. Create an entity and implement the `CardScanning` protocol.

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

2. Set up receiving data from your tool for scanning bank cards.\
Example for CardIO:

```swift
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

3. Enter an instance of the `CardScannerProvider` object in `TokenizationModuleInputData` in the `cardScanning:` parameter.

```swift
let inputData = TokenizationModuleInputData(
    ...
    cardScanning: CardScannerProvider())
```

## Setting up payment confirmation

If you'd like to use our implementation of payment confirmation, don't close the SDK module after receiving the token.\
Send the token to your server and close the module after a successful payment.\
If your server stated that the payment needs to be confirmed (i.e. the payment with the `pending` was received), call the `startConfirmationProcess(confirmationUrl:paymentMethodType:)` method.

After the payment confirmation is completed successfully, the `didSuccessfullyConfirmation(paymentMethodType:)` method of the `TokenizationModuleOutput` protocol will be called.

Code examples:

1. Save the tokenization module.

```swift
self.tokenizationViewController = TokenizationAssembly.makeModule(inputData: inputData,
                                                                 moduleOutput: self)
present(self.tokenizationViewController, animated: true, completion: nil)
```

2. Don't close the tokenization module after receiving the token.

```swift
func tokenizationModule(_ module: TokenizationModuleInput,
                        didTokenize token: Tokens,
                        paymentMethodType: PaymentMethodType) {
    // Send the token to your server.
}
```

3. Call payment confirmation if necessary.

```swift
self.tokenizationViewController.startConfirmationProcess(
    confirmationUrl: confirmationUrl,
    paymentMethodType: paymentMethodType
)
```

4. After the payment is confirmed successfully, the method will be called.

```swift
func didSuccessfullyConfirmation(paymentMethodType: PaymentMethodType) {
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        // Now close tokenization module
        self.dismiss(animated: true)
    }
}
```

## Logging

You can enable logging of all network requests.\
To do that, you need to enter `isLoggingEnabled: true` when creating `TokenizationModuleInputData`

```swift
let moduleData = TokenizationModuleInputData(
    ...
    isLoggingEnabled: true)
```

## Test mode

You can launch the mobile SDK in test mode.\
In test mode, no network requests are made and response from the server is emulated.

If you'd like to run the SDK in test mode, you need to:

1. Configure an object with the `TestModeSettings` type.

```swift
let testModeSettings = TestModeSettings(paymentAuthorizationPassed: false,
                                        cardsCount: 2,
                                        charge: Amount(value: 999, currency: .rub),
                                        enablePaymentError: false)
```

2. Enter it in `TokenizationModuleInputData` in the `testModeSettings:` parameter

```swift
let moduleData = TokenizationModuleInputData(
    ...
    testModeSettings: testModeSettings)
```

## Launching Example

To launch the Example app, you need to:

1. Make a `git clone` of the repository.

```shell
git clone https://github.com/yoomoney/yookassa-payments-swift.git
```

2. Create a `Frameworks` folder in the project root directory.
3. Add `TMXProfiling.xcframework` and `TMXProfilingConnections.xcframework` to the `Frameworks` folder
4. Go to the project folder and run the following commands in console:

```shell
gem install bundler
bundle
pod install
```

4. Open `YooKassaPayments.xcworkspace`.
5. Select and launch the `ExamplePods` scheme.

## Interface customization

The blueRibbon color is used by default. Color of the main elements, button, switches, and input fields.

1. Configure an `CustomizationSettings` object and enter it in the `customizationSettings` parameter of the `TokenizationModuleInputData` object.

```swift
let moduleData = TokenizationModuleInputData(
    ...
    customizationSettings: CustomizationSettings(mainScheme: /* UIColor */ ))
```

## Payments via bank cards linked to the store with an additional CVC/CVV request

1. Create `BankCardRepeatModuleInputData`.

```swift
let bankCardRepeatModuleInputData = BankCardRepeatModuleInputData(
            clientApplicationKey: oauthToken,
            shopName: translate(Localized.name),
            purchaseDescription: translate(Localized.description),
            paymentMethodId: "24e4eca6-000f-5000-9000-10a7bb3cfdb2",
            amount: amount,
            testModeSettings: testSettings,
            isLoggingEnabled: true,
            customizationSettings: CustomizationSettings(mainScheme: .blueRibbon)
        )
```

2. Create `TokenizationFlow` with the `.bankCardRepeat` case and enter `BankCardRepeatModuleInputData`.

```swift
let inputData: TokenizationFlow = .bankCardRepeat(bankCardRepeatModuleInputData)
```

3. Create `ViewController` from `TokenizationAssembly` and put it on the screen.

```swift
let viewController = TokenizationAssembly.makeModule(
    inputData: inputData,
    moduleOutput: self
)
present(viewController, animated: true, completion: nil)
```

## License

YooMoney for Business Payments SDK (YooKassaPayments) is available under the MIT license. See the [LICENSE](https://github.com/yoomoney/yookassa-payments-swift/blob/master/LICENSE) file for additional information.
