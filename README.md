# Yandex Checkout Payments SDK

[![Platform](https://img.shields.io/badge/Support-iOS%208%2B-brightgreen.svg)](https://img.shields.io/badge/Support-iOS%208%2B-brightgreen.svg)
[![GitHub tag](https://img.shields.io/github/tag/yandex-money/yandex-checkout-payments-swift.svg)](https://img.shields.io/github/tag/yandex-money/yandex-checkout-payments-swift.svg)
[![Documentation](docs/badge.svg)](docs/badge.svg)
[![license](https://img.shields.io/github/license/yandex-money/yandex-checkout-payments-swift.svg)](https://img.shields.io/github/license/yandex-money/yandex-checkout-payments-swift.svg)

Библиотека позволяет встроить прием платежей в мобильные приложения на iOS и работает как дополнение к API Яндекс.Кассы.\
В mSDK входят готовые платежные интерфейсы (форма оплаты и всё, что с ней связано).\
С помощью mSDK можно получать токены для проведения оплаты с банковской карты, Apple Pay, Сбербанка или из кошелька в Яндекс.Деньгах.

- [Код библиотеки](https://github.com/yandex-money/yandex-checkout-payments-swift/tree/master/YandexCheckoutPayments)
- [Код демо-приложения, которое интегрирует mSDK](https://github.com/yandex-money/yandex-checkout-payments-swift/tree/master/YandexCheckoutPaymentsExample)
- [Документация](https://yandex-money.github.io/yandex-checkout-payments-swift/)

## Содержание

* [Подключение зависимостей](#подключение-зависимостей)
  * [CocoaPods](#cocoapods)
  * [Carthage](#carthage)
  * [TrustDefender.framework](#trustdefender.framework)
* [Быстрая интеграция](#быстрая-интеграция)
* [Доступные способы оплаты](#доступные-способы-оплаты)
* [Настройка способов оплаты](#настройка-способов-оплаты)
  * [Яндекс.Деньги](#яндекс.деньги)
  * [Банковская карта](#банковская-карта)
  * [Сбербанк Онлайн](#сбербанк-онлайн)
  * [Apple Pay](#apple-pay)
* [Описание входных параметров](#описание-входных-параметров)
  * [TokenizationModuleInputData](#tokenizationModuleInputData)
  * [TokenizationSettings](#tokenizationSettings)
  * [TestModeSettings](#testModeSettings)
  * [Amount](#amount)
  * [Currency](#currency)
* [Сканирование банковских карт](#сканирование-банковских-карт)
* [Настройка 3D Secure](#настройка-3d-secure)
* [Логирование](#логирование)
* [Тестовый режим](#тестовый-режим)
* [Запуск Example](#запуск-example)

### Подключение зависимостей

#### CocoaPods

1. Установите CocoaPods

  ```shell
  gem install cocoapods
  ```

2. Добавьте зависимости в `Podfile`.\
  [Пример](https://github.com/yandex-money/yandex-checkout-payments-swift/tree/master/YandexCheckoutPaymentsExample/Podfile-example) `Podfile` из демо-приложения.

  ```shell
  source 'https://github.com/CocoaPods/Specs.git'
  platform :ios, '8.0'
  use_frameworks!

  target 'Your Target Name' do
    pod 'YandexCheckoutPayments',
      :git => 'https://github.com/yandex-money/yandex-checkout-payments-swift.git',
      :tag => 'tag'
  end
  ```

  > `Your Target Name` - название таргета в Xcode для вашего приложения.\
  > `tag` - версия mSDK. Актуальную версию можно узнать на github в разделе [releases](https://github.com/yandex-money/yandex-checkout-payments-swift/releases).

3. Добавьте библиотеку TrustDefender.framework в папку Frameworks.\
  Подробнее про TrustDefender [тут](#trustDefender.framework).

  ```txt
  App
  ├─ Pods
  └─ Frameworks
     └─ TrustDefender.framework
  ```

#### Carthage

На данный момент Carthage не поддерживается.

#### TrustDefender.framework

Файл `.framework` можно получить только после подключения [Яндекс.Кассы](https://kassa.yandex.ru/joinups).\
Необходимо сообщить вашему менеджеру по подключению что вы хотите подключить mSDK.

### Быстрая интеграция

1. Создайте `TokenizationModuleInputData`. Вам понадобится ключ для клиентских приложений из личного кабинета Яндекс.Кассы. В этой модели передаются параметры платежа (валюта и сумма), параметры платежной формы, которые увидит пользователь при оплате (способы оплаты, название магазина и описание заказа).

> Для работы с сущностями YandexCheckoutPayments необходимо импортировать зависимости в исходный файл.

  ```swift
  import YandexCheckoutPayments
  import YandexCheckoutPaymentsApi
  ```

Пример создания `TokenizationModuleInputData`:

  ```swift
  let clientApplicationKey = "<Ключ для клиентских приложений>"
  let amount = Amount(value: 999.99, currency: .rub)
  let inputData = TokenizationModuleInputData(clientApplicationKey: clientApplicationKey,
                                              shopName: "Космические объекты",
                                              purchaseDescription: """
                                                  Комета повышенной яркости, период обращения — 112 лет
                                                  """,
                                              amount: amount)
  ```

2. Создайте `ViewController` из `TokenizationAssembly` и выведите его на экран.

  ```swift
  let viewController = TokenizationAssembly.makeModule(inputData: inputData,
                                                       moduleOutput: self)
  present(viewController, animated: true, completion: nil)
  ```

В `moduleOutput` необходимо передать объект который реализует протокол `TokenizationModuleOutput`.

3. Реализуйте протокол `TokenizationModuleOutput`.

  ```swift
  extension ViewController: TokenizationModuleOutput {
    func tokenizationModule(_ module: TokenizationModuleInput,
                            didTokenize token: Tokens,
                            paymentMethodType: PaymentMethodType) {
      DispatchQueue.main.async { [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.dismiss(animated: true)
      }
      // Отправьте токен в вашу систему
    }

    func didFinish(on module: TokenizationModuleInput) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
        }
    }
  }
  ```

Закройте `ViewController` и отправьте токен в вашу систему. Затем [создайте платеж](https://kassa.yandex.ru/docs/guides/#custom) по API Яндекс.Кассы, в параметре `payment_token` передайте токен, полученный в SDK. Способ подтверждения при создании платежа зависит от способа оплаты, который выбрал пользователь. Он приходит вместе с токеном в `paymentMethodType`.

### Доступные способы оплаты

Сейчас в SDK для iOS доступны следующие способы оплаты:

`.yandexMoney` — Яндекс.Деньги (платежи из кошелька или привязанной картой)\
`.bankCard` — банковская карта (карты можно сканировать)\
`.sberbank` — Сбербанк Онлайн (с подтверждением по смс)\
`.applePay` — Apple Pay

### Настройка способов оплаты

У вас есть возможность сконфигурировать способы оплаты.\
Для этого необходимо при создании `TokenizationModuleInputData` в параметр `tokenizationSettings` передать модель типа `TokenizationSettings`.

> Для некоторых способ оплаты потребуется дополнительная настройка.\
> По каждому способу оплаты где необходима дополнительная настройка есть инструкция ниже.\
> По умолчанию используются все доступные способы оплаты.

```swift
// Создайте пустой OptionSet PaymentMethodTypes
var paymentMethodTypes: PaymentMethodTypes = []

if <Условие для банковской карты> {
    // Добавляем в paymentMethodTypes элемент `.bankCard`
    paymentMethodTypes.insert(.bankCard)
}

if <Условие для Сбербанка Онлайн> {
    // Добавляем в paymentMethodTypes элемент `.sberbank`
    paymentMethodTypes.insert(.sberbank)
}

if <Условие для Яндекс.Денег> {
    // Добавляем в paymentMethodTypes элемент `.yandexMoney`
    paymentMethodTypes.insert(.yandexMoney)
}

if <Условие для Apple Pay> {
    // Добавляем в paymentMethodTypes элемент `.applePay`
    paymentMethodTypes.insert(.applePay)
}

let tokenizationSettings = TokenizationSettings(paymentMethodTypes: paymentMethodTypes)
```

Теперь используйте `tokenizationSettings` при инициализации `TokenizationModuleInputData`.

#### Яндекс.Деньги

Чтобы принимать платежи из кошельков в Яндекс.Деньгах, необходима авторизация в Яндексе.

1. Зарегистрируйте свое приложение в [Яндекс.OAuth](https://oauth.yandex.ru/) и сохраните __ID__.
   - Введите название приложения.
   - В разделе __API Яндекс.Паспорта__ необходимо выбрать __Доступ к логину, имени и фамилии, полу__

2. Добавьте в Info.plist следующие строки:

  ```plistbase
  <key>LSApplicationQueriesSchemes</key>
  <array>
      <string>yandexauth</string>
      <string>yandexauth2</string>
  </array>
  <key>CFBundleURLTypes</key>
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

3. Настройте Entitlements

В своем проекте в разделе `Capabilities` включите `Associated Domains` и добавьте домен по шаблону:
>applinks:yx<ID из Яндекс.OAuth>.oauth.yandex.ru.

Например, если ваш ID из Яндекс.OAuth — `333`, домен будет таким:
>applinks:yx333.oauth.yandex.ru.

4. Добавьте код из примера в AppDelegate.

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

Чтобы провести платеж:

1. При создании `TokenizationModuleInputData` передайте значение `.yandexMoney` в `paymentMethodTypes.`
2. Получите токен.
3. [Создайте платеж](https://kassa.yandex.ru/docs/guides#custom) с токеном по API Яндекс.Кассы.

#### Банковская карта

1. При создании `TokenizationModuleInputData` передайте значение `.bankcard` в `paymentMethodTypes`.
2. Получите токен.
3. [Создайте платеж](https://kassa.yandex.ru/docs/guides#custom) с токеном по API Яндекс.Кассы.

#### Сбербанк Онлайн

С помощью SDK можно провести платеж через «Мобильный банк» Сбербанка — с подтверждением оплаты по смс:

1. При создании `TokenizationModuleInputData` передайте значение `.sberbank` в `paymentMethodTypes`.
2. Получите токен.
3. [Создайте платеж](https://kassa.yandex.ru/docs/guides#custom) с токеном по API Яндекс.Кассы.

#### Apple Pay

1. Чтобы подключить Apple Pay, нужно передать Яндекс.Кассе сертификат, с помощью которого Apple будет шифровать данные банковских карт.

Для этого:

- Напишите менеджеру и попросите создать для вас запрос на сертификат (`.csr`).
- Используйте `.csr` в панели разработчика Apple чтобы создать сертификат.
- Скачайте получившийся сертификат и пришлите менеджеру.

[Подробная инструкция](https://kassa.yandex.ru/files/manual_connection_Apple_Pay(website).pdf) (см. раздел 2 «Обмен сертификатами с Apple»)

2. Включите Apple Pay в Xcode.

Чтобы провести платеж:

1. При инициализации объекта `TokenizationModuleInputData` необходимо передать [apple pay identifier](https://help.apple.com/xcode/mac/current/#/deva43983eb7?sub=dev171483d6e) в параметр `applePayMerchantIdentifier`.

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applePayMerchantIdentifier: "<com.example...>")
```

2. Получите токен.
3. [Создайте платеж](https://kassa.yandex.ru/docs/guides#custom) с токеном по API Яндекс.Кассы.

### Описание входных параметров

#### TokenizationModuleInputData

>Обязательные:

| Параметр             | Тип    | Описание |
| -------------------- | ------ | -------- |
| clientApplicationKey | String | Ключ для клиентских приложений из личного кабинета Яндекс.Кассы. |
| shopName             | String | Название магазина в форме оплаты |
| purchaseDescription  | String | Описание заказа в форме оплаты |
| amount               | Amount | Объект, содержащий сумму заказа и валюту |

>Необязательные:

| Параметр                   | Тип                  | Описание |
| -------------------------- | -------------------- | -------- |
| gatewayId                  | String               | По умолчанию `nil`. Используется, если у вас несколько платежных шлюзов с разными идентификаторами. |
| tokenizationSettings       | TokenizationSettings | По умолчанию используется стандартный инициализатор со всеми способами оплаты. Параметр отвечает за настройку токенизации (способы оплаты и логотип Яндекс.Кассы). |
| testModeSettings           | TestModeSettings     | По умолчанию `nil`. Настройки тестового режима. |
| cardScanning               | CardScanning         | По умолчанию `nil`. Возможность сканировать банковские карты. |
| applePayMerchantIdentifier | String               | По умолчанию `nil`. Apple Pay merchant ID (обязательно для платежей через Apple Pay). |
| returnUrl                  | String               | По умолчанию `nil`. URL страницы (поддерживается только `https`), на которую надо вернуться после прохождения 3ds. Должен использоваться только при использовании своей реализации 3ds url. Если вы используете `start3dsProcess(requestUrl:)`, не задавайте этот параметр. |
| isLoggingEnabled           | Bool                 | По умолчанию `false`. Включает логирование сетевых запросов. |

#### TokenizationSettings

Можно настроить список способов оплаты и отображение логотипа Яндекс.Кассы в приложении.

| Параметр               | Тип                | Описание |
| ---------------------- | ------------------ | -------- |
| paymentMethodTypes     | PaymentMethodTypes | По умолчанию `.all` [Способы оплаты](#настройка-способов-оплаты), доступные пользователю в приложении. |
| showYandexCheckoutLogo | Bool               | По умолчанию `true` Отвечает за отображение логотипа Яндекс.Кассы. По умолчанию логотип отображается. |

#### TestModeSettings

| Параметр                   | Тип    | Описание |
| -------------------------- | ------ | -------- |
| paymentAuthorizationPassed | Bool   | Определяет пройдена ли платежная авторизация при платеже Яндекс.Деньгами. |
| cardsCount                 | Int    | Количество привязанные карт к Яндекс.Кошельку. |
| charge                     | Amount | Сумма и валюта платежа. |
| enablePaymentError         | Bool   | Определяет будет ли платеж завершен с ошибкой. |

#### Amount

| Параметр | Тип      | Описание |
| -------- | -------- | -------- |
| value    | Decimal  | Сумма платежа. |
| currency | Currency | Валюта платежа. |

#### Currency

| Параметр | Тип      | Описание |
| -------- | -------- | -------- |
| rub      | String   | ₽ - Российский рубль, |
| usd      | String   | $ - Американский доллар |
| eur      | String   | € - Евро |

### Сканирование банковских карт

Если хотите, чтобы пользователи смогли сканировать банковские карты при оплате необходимо:

1. Создать сущность и реализовать протокол `CardScanning`.

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

2. Настроить получение данных из вашего инструмента для сканирования банковской карты.\
На примере CardIO:

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

3. Передать экземпляр объекта `CardScannerProvider` в `TokenizationModuleInputData` в параметр `cardScanning:`.

```swift
let inputData = TokenizationModuleInputData(
    ...
    cardScanning: CardScannerProvider())
```

### Настройка 3D Secure

Если вы хотите использовать нашу реализацию 3D Secure, не закрывайте модуль mSDK после получения токена.\
Отправьте токен на ваш сервер и после успешной оплаты закройте модуль.\
Если ваш сервер сообщил о необходимости подтверждения платежа, вызоватие метод `start3dsProcess(requestUrl:)`

После успешного прохождения 3D secure будет вызван метод `didSuccessfullyPassedCardSec(on module:)` протокола `TokenizationModuleOutput`.

Примеры кода:

1. Сохраните tokenization модуль.

```swift
self.tokenizationViewController = TokenizationAssembly.makeModule(inputData: inputData,
                                                                 moduleOutput: self)
present(self.tokenizationViewController, animated: true, completion: nil)
```

2. Не закрывайте tokenization модуль после получения токена.

```swift
func tokenizationModule(_ module: TokenizationModuleInput,
                        didTokenize token: Tokens,
                        paymentMethodType: PaymentMethodType) {
    // Отправьте токен на ваш сервер.
}
```

3. Покажите 3D secure если необходимо подтвердить платеж.

```swift
func needsConfirmPayment(requestUrl: String) {
    self.tokenizationViewController.start3dsProcess(requestUrl: requestUrl)
}
```

4. После успешного прохождения 3D secure будет вызван метод.

```swift
func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        // Now close tokenization module
        self..dismiss(animated: true)
    }
}
```

### Логирование

У вас есть возможность включить логирование всех сетевых запросов.\
Для этого необходимо при создании `TokenizationModuleInputData` передать `isLoggingEnabled: true`

```swift
let moduleData = TokenizationModuleInputData(
    ...
    isLoggingEnabled: true)
```

### Тестовый режим

У вас есть возможность запустить mSDK в тестовом режиме.\
Тестовый режим не выполняет никаких сетевых запросов, и имитирует ответ от сервера.

Если вы хотите запустить mSDK в тестовом режиме необходимо:

1. Cконфигурировать объект с типом `TestModeSettings`.

```swift
let testModeSettings = TestModeSettings(paymentAuthorizationPassed: false,
                                        cardsCount: 2,
                                        charge: Amount(value: 999, currency: .rub),
                                        enablePaymentError: false)
```

2. Передать его в `TokenizationModuleInputData` в параметре `testModeSettings:`

```swift
let moduleData = TokenizationModuleInputData(
    ...
    testModeSettings: testModeSettings)
```

### Запуск Example

Для того чтобы запустить Example приложение необходимо:

1. Сделать `git clone` репозитория.

```shell
git clone https://github.com/yandex-money/yandex-checkout-payments-swift.git
```

2. Добавить [TrustDefender.framework](#trustDefender.framework) в папку `Frameworks`, которая находится на одном уровне с папкой `Pods`
3. Выполнить команды в консоли находясь в директории проекта.

```shell
gem install bundler
bundle
pod install
```

4. Открыть `YandexCheckoutPayments.xcworkspace`
5. Выбрать и запустить схему `ExamplePods`
