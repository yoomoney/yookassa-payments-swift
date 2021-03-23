# Migration guide

- [Migration guide](#migration-guide)
  - [5.\*.\* -> 6.\*.\*](#5---6)
    - [Изменить код интеграции](#изменить-код-интеграции)
    - [Конфигурация проекта](#конфигурация-проекта)
    - [Изменить код подтверждения платежа](#изменить-код-подтверждения-платежа)
  - [4.\*.\* -> 5.\*.\*](#4---5)
    - [Изменить Podfile](#изменить-podfile)
    - [Изменить код интеграции](#изменить-код-интеграции)
  - [\*.\*.\* -> 4.\*.\*](#---4)
    - [Удалить `YandexLoginSDK`](#удалить-yandexloginsdk)
    - [Добавить новые зависимости](#добавить-новые-зависимости)
    - [Если вы используете метод оплаты "Яндекс.Деньги"](#если-вы-используете-метод-оплаты-яндексденьги)
  - [2.\*.\* -> 3.\*.\*](#2---3)
  - [2.1.0 -> 2.2.0](#210---220)

## 5.\*.\* -> 6.\*.\*

В версии 6.0.0 была добавлена поддержка `Sberpay`.

Для корректной работы сценария `Sberpay`, нужно изменить некоторые параметры.

### Изменить код интеграции

1. В `TokenizationModuleInputData` необходимо передавать `applicationScheme` – схема для возврата в приложение, после успешной оплаты с помощью `Sberpay` в приложении СберБанк Онлайн открытого через deeplink.  

Пример `applicationScheme`:

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applicationScheme: "sberpayexample://"
```

2. В `AppDelegate` импортировать зависимость `YooKassaPayments`:

   ```swift
   import YooKassaPayments
   ```

3. Добавить обработку ссылок через `ConfirmationService` в `AppDelegate`:

```swift
func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?, 
    annotation: Any
) -> Bool {
    return YKSdk.shared.hanleOpen(
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
    return YKSdk.shared.hanleOpen(
        url: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
    )
}
```

4. Реализовать метод  `didSuccessfullyConfirmation(paymentMethodType:)` протокола `TokenizationModuleOutput`, который будет вызван после успешного подтверждения платежа. 

### Конфигурация проекта

В `Info.plist` добавить:

по ключу `LSApplicationQueriesSchemes` параметр:

```plistbase
<array>
<string>sberpay</string>
</array>
```

по ключу `CFBundleURLTypes` параметры:

```plistbase
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>${BUNDLE_ID}</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>sberpayexample</string>
		</array>
	</dict>
</array>
```

где `sberpayexample` - схема для открытия вашего приложения после успешной оплаты с помощью `Sberpay`.

### Изменить код подтверждения платежа

Для подтверждения платежа необходимо вызвать метод `startConfirmationProcess(confirmationUrl:paymentMethodType:)`.

После успешного прохождения подтверждения будет вызван метод `didSuccessfullyConfirmation(paymentMethodType:)` протокола `TokenizationModuleOutput`. 

> Обратите внимание, что методы `start3dsProcess(requestUrl:)` и `didSuccessfullyPassedCardSec(on module:)` помечены как `deprecated` - используйте `startConfirmationProcess(confirmationUrl:paymentMethodType:)` и `didSuccessfullyConfirmation(paymentMethodType:)` вместо них.

## 4.\*.\* -> 5.\*.\*

В версии 5.\*.\* был переименован модуль SDK и некоторые зависимости.

Для корректной интеграции SDK, нужно изменить некоторые параметры.

### Изменить Podfile

- pod `'YandexCheckoutPayments'` -> pod `'YooKassaPayments'`
- :git => 'https://github.com/yoomoney/yookassa-payments-swift.git'

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

### Изменить код интеграции

Поменять названия библиотек при импорте:

- `YandexCheckoutPayments` -> `YooKassaPayments`
- `YandexCheckoutPaymentsApi` -> `YooKassaPaymentsApi`

В методе `didFinish(on module:error:)` протокола `TokenizationModuleOutput` изменить тип ошибки:

- `YandexCheckoutPaymentsError` -> `YooKassaPaymentsError`

Если вы передаете `TokenizationSettings` в `TokenizationModuleInputData`, необходимо изменить:

- элемент `PaymentMethodTypes` - `yandexMoney` -> `yooMoney`
- название параметра `showYandexCheckoutLogo` -> `showYooKassaLogo`

## \*.\*.\* -> 4.\*.\*

### Удалить `YandexLoginSDK`

В версии 4.\*.\* удалена зависимость `YandexLoginSDK`.

> Если вы используете эту библиотеку для своих целей, то нужно удалить только:
> - из `Info.plist` по ключу `CFBundleURLSchemes` ID из Яндекс.OAuth который передавался в `YandexLoginService`
> - из файлов `Entitlements` ID из Яндекс.OAuth который передавался в `YandexLoginService`
> - код связанный с `YandexLoginService` из AppDelegate

> Если вы не использовали платежный метод "Яндекс.Деньги", и не подключали `YandexLoginSDK`, то этот блок можно пропустить.

Необходимо удалить интеграцию `YandexLoginSDK` из вашего проекта.

1. Удалить из `Info.plist`:

по ключу `LSApplicationQueriesSchemes` параметры:

```plistbase
<array>
  <string>yandexauth</string>
  <string>yandexauth2</string>
</array>
```

по ключу `CFBundleURLTypes` параметры:

```plistbase
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>YandexLoginSDK</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>yx<ID из Яндекс.OAuth></string>
    </array>
  </dict>
</array>
```

2. Удалить из файлов `Entitlements`:

>applinks:yx<ID из Яндекс.OAuth>.oauth.yandex.ru

3. Удалить код из AppDelegate:

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try YandexLoginService.activate(withAppId: /* ID из Яндекс.OAuth */)
    } catch {
        // process error
    }
    return true
}

func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    YandexLoginService.processUserActivity(userActivity)
    return true
}

func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    return YandexLoginService.handleOpen(url, sourceApplication: options[.sourceApplication] as? String)
}
```

### Добавить новые зависимости

В версии 4.\*.\* мы добавили зависимости из своего CocoaPods pod repo.\
Чтобы они корректно работали, необходимо:

1. В `Podfile` вашего проекто добавить ссылку вида:

```ruby
source 'https://github.com/yoomoney-tech/cocoa-pod-specs.git'
```

или

```ruby
source 'git@github.com:yoomoney-tech/cocoa-pod-specs.git'
```

в зависимости от вашего подключения к github.com через CLI.

[Пример готового Podfile](https://github.com/yoomoney/yookassa-payments-swift/tree/master/YooKassaPaymentsExample/Podfile-example)

2. Зависимость `MoneyAuth` подключается в виде `.xcframework`, и к сожалению версия CocoaPods 1.9.3 [не умеет корректно с ними работать](https://github.com/CocoaPods/CocoaPods/issues?q=is%3Aissue+xcframework).\
Необходимо обновить версию `CocoaPods` выше 1.9.3\
Для этого в консоли в директории с проектом выполните команду:

```zsh
gem install cocoapods
```

[Официальная документация по установке CocoaPods](https://guides.cocoapods.org/using/getting-started.html#updating-cocoapods).\
[Какие версии CocoaPods есть](https://github.com/CocoaPods/CocoaPods/releases).

> Если вы используете `Bundler` для контроля зависимостей `RubyGems`, то необходимо внести изменения в `Gemfile`.

### Если вы используете метод оплаты "ЮMoney"

В модели `TokenizationModuleInputData` появился новый необязательный параметр, `moneyAuthClientId`, который необходимо передавать.\
[Подробнее тут](https://github.com/yoomoney/yookassa-payments-swift#юmoney).

## 2.\*.\* -> 3.\*.\*

В `TokenizationModuleInputData` появился новый обязательный параметр - `savePaymentMethod`

Если способ оплаты сохранен, магазин может совершать регулярные платежи с помощью токена.

Для этой настройки существует три варианта:

`SavePaymentMethod.on` - Сохранить платёжный метод для проведения рекуррентных платежей.\
Пользователю будут доступны только способы оплаты, поддерживающие сохранение.\
На экране контракта будет отображено сообщение о том, что платёжный метод будет сохранён.

`SavePaymentMethod.off` - Не дает пользователю выбрать, сохранять способ оплаты или нет.

`SavePaymentMethod.userSelects` - Пользователь выбирает, сохранять платёжный метод или нет. Если метод можно сохранить, на экране контракта появится переключатель.

## 2.1.0 -> 2.2.0

- `TokenizationAssembly.makeModule` now takes `TokenizationFlow` model.

So, all what you need that's change:

```swift
let inputData = TokenizationModuleInputData( ... )

let viewController = TokenizationAssembly.makeModule(
    inputData: inputData,
    moduleOutput: self
)
```

to

```swift
let tokenizationModuleInputData = TokenizationModuleInputData( ... )

let inputData: TokenizationFlow = .tokenization(tokenizationModuleInputData)

let viewController = TokenizationAssembly.makeModule(
    inputData: inputData,
    moduleOutput: self
)
```

- `TokenizationModuleOutput` was changed.

A method signature

```swift
func didFinish(on module: TokenizationModuleInput)
```

was changed to

```swift
func didFinish(on module: TokenizationModuleInput,
               with error: YandexCheckoutPaymentsError?)
```

 Подробнее про проведения рекуррентных платежей можно [прочитать тут](https://yookassa.ru/developers/payments/recurring-payments).
