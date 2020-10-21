# Yandex Checkout Payments SDK

[![Platform](https://img.shields.io/badge/Support-iOS%2010.0+-brightgreen.svg)](https://img.shields.io/badge/Support-iOS%2010.3+-brightgreen.svg)
[![GitHub tag](https://img.shields.io/github/tag/yandex-money/yandex-checkout-payments-swift.svg)](https://img.shields.io/github/tag/yandex-money/yandex-checkout-payments-swift.svg)
[![Documentation](docs/badge.svg)](docs/badge.svg)
[![license](https://img.shields.io/github/license/yandex-money/yandex-checkout-payments-swift.svg)](https://img.shields.io/github/license/yandex-money/yandex-checkout-payments-swift.svg)

Библиотека позволяет встроить прием платежей в мобильные приложения на iOS и работает как дополнение к API Яндекс.Кассы.\
В мобильный SDK входят готовые платежные интерфейсы (форма оплаты и всё, что с ней связано).\
С помощью SDK можно получать токены для проведения оплаты с банковской карты, через Apple Pay, Сбербанк Онлайн или из кошелька в Яндекс.Деньгах.

- [Код библиотеки](https://github.com/yandex-money/yandex-checkout-payments-swift/tree/master/YandexCheckoutPayments)
- [Код демо-приложения, которое интегрирует SDK](https://github.com/yandex-money/yandex-checkout-payments-swift/tree/master/YandexCheckoutPaymentsExample)
- [Документация](https://yandex-money.github.io/yandex-checkout-payments-swift/)

---

- [Yandex Checkout Payments SDK](#yandex-checkout-payments-sdk)
  - [Changelog](#changelog)
  - [Migration guide](#migration-guide)
  - [Подключение зависимостей](#подключение-зависимостей)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
  - [Подключение TMXProfiling и TMXProfilingConnections](#подключение-tmxprofiling-и-tmxprofilingconnections)
  - [Быстрая интеграция](#быстрая-интеграция)
  - [Доступные способы оплаты](#доступные-способы-оплаты)
  - [Настройка способов оплаты](#настройка-способов-оплаты)
    - [Яндекс Деньги](#яндекс-деньги)
    - [Банковская карта](#банковская-карта)
    - [Сбербанк Онлайн](#сбербанк-онлайн)
    - [Apple Pay](#apple-pay)
  - [Описание публичных параметров](#описание-публичных-параметров)
    - [TokenizationFlow](#tokenizationflow)
    - [YandexCheckoutPaymentsError](#yandexcheckoutpaymentserror)
    - [TokenizationModuleInputData](#tokenizationmoduleinputdata)
    - [BankCardRepeatModuleInputData](#bankcardrepeatmoduleinputdata)
    - [TokenizationSettings](#tokenizationsettings)
    - [TestModeSettings](#testmodesettings)
    - [Amount](#amount)
    - [Currency](#currency)
    - [CustomizationSettings](#customizationsettings)
    - [SavePaymentMethod](#savepaymentmethod)
  - [Сканирование банковских карт](#сканирование-банковских-карт)
  - [Настройка 3D Secure](#настройка-3d-secure)
  - [Логирование](#логирование)
  - [Тестовый режим](#тестовый-режим)
  - [Запуск Example](#запуск-example)
  - [Кастомизация интерфейса](#кастомизация-интерфейса)
  - [Платёж привязанной к магазину картой с дозапросом CVC/CVV](#платёж-привязанной-к-магазину-картой-с-дозапросом-cvccvv)
  - [Лицензия](#лицензия)

## Changelog

[Ссылка на Changelog](https://github.com/yandex-money/yandex-checkout-payments-swift/blob/master/CHANGELOG.md)

## Migration guide

[Ссылка на Migration guide](https://github.com/yandex-money/yandex-checkout-payments-swift/blob/master/MIGRATION.md)

## Подключение зависимостей

### CocoaPods

1. Установите CocoaPods версии 1.10.0 или выше.

```zsh
gem install cocoapods
```

[Официальная документация по установке CocoaPods](https://guides.cocoapods.org/using/getting-started.html#updating-cocoapods).\
[Какие версии CocoaPods есть](https://github.com/CocoaPods/CocoaPods/releases).

1. Создайте файл Podfile

> CocoaPods предоставляет команду ```pod init``` для создания Podfile с настройками по умолчанию.

2. Добавьте зависимости в `Podfile`.\
  [Пример](https://github.com/yandex-money/yandex-checkout-payments-swift/tree/master/YandexCheckoutPaymentsExample/Podfile-example) `Podfile` из демо-приложения.

```shell
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/yandex-money-tech/cocoa-pod-specs.git'

platform :ios, '10.0'
use_frameworks!

target 'Your Target Name' do
  pod 'YandexCheckoutPayments',
    :git => 'https://github.com/yandex-money/yandex-checkout-payments-swift.git',
    :tag => 'tag'
end
```

> `Your Target Name` - название таргета в Xcode для вашего приложения.\
> `tag` - версия SDK. Актуальную версию можно узнать на github в разделе [releases](https://github.com/yandex-money/yandex-checkout-payments-swift/releases).

3. Выполните команду `pod install`

### Carthage

На текущий момент Carthage не поддерживается.

## Подключение TMXProfiling и TMXProfilingConnections

Чтобы получить файл `.framework`,  [зарегистрируйтесь в Яндекс.Кассе](https://kassa.yandex.ru/joinups)
и сообщите вашему менеджеру, что хотите подключить мобильный SDK.

1. Используя Finder или другой файловый менеджер добавьте библиотеки `TMXProfiling.framework` и `TMXProfilingConnections.framework` в папку `Frameworks`.

> Если в папке с проектом отсутствует папка `Frameworks` создайте её вручную.\
> Папка `Frameworks` должна быть на уровне файловой системы, не используйте папку `Frameworks` в Xcode.

```txt
App
├─ Pods
└─ Frameworks
    └─ TMXProfiling.framework
    └─ TMXProfilingConnections.framework
```

2. В разделе `General` у основного таргета проекта добавьте `TMXProfiling.framework` и `TMXProfilingConnections.framework` в `Embedded Binaries`(в Xcode 10.3 или меньше), или в `Frameworks, Libraries, and Embedded Content`(в Xcode 11)

3. `TMXProfiling.framework` и `TMXProfilingConnections.framework` должны быть добавлены как `Embed & Sign`

4. Добавьте в `Build Phases` -> `New Run Script Phase`, и добавьте скрипт из файла `strip_framework.sh`

## Быстрая интеграция

1. Создайте `TokenizationModuleInputData` (понадобится [ключ для клиентских приложений](https://kassa.yandex.ru/my/tunes) из личного кабинета Яндекс.Кассы). В этой модели передаются параметры платежа (валюта и сумма) и параметры платежной формы, которые увидит пользователь при оплате (способы оплаты, название магазина и описание заказа).

> Для работы с сущностями YandexCheckoutPayments импортируйте зависимости в исходный файл

```swift
import YandexCheckoutPayments
import YandexCheckoutPaymentsApi
```

Пример создания `TokenizationModuleInputData`:

```swift
let clientApplicationKey = "<Ключ для клиентских приложений>"
let amount = Amount(value: 999.99, currency: .rub)
let tokenizationModuleInputData =
          TokenizationModuleInputData(clientApplicationKey: clientApplicationKey,
                                      shopName: "Космические объекты",
                                      purchaseDescription: """
                                                            Комета повышенной яркости, период обращения — 112 лет
                                                            """,
                                      amount: amount,
                                      savePaymentMethod: .on)
```

2. Создайте `TokenizationFlow` с кейсом `.tokenization` и передайте `TokenizationModuleInputData`.

Пример создания `TokenizationFlow`:

```swift
let inputData: TokenizationFlow = .tokenization(tokenizationModuleInputData)
```

3. Создайте `ViewController` из `TokenizationAssembly` и выведите его на экран.

```swift
let viewController = TokenizationAssembly.makeModule(inputData: inputData,
                                                       moduleOutput: self)
present(viewController, animated: true, completion: nil)
```

В `moduleOutput` необходимо передать объект, который реализует протокол `TokenizationModuleOutput`.

4. Реализуйте протокол `TokenizationModuleOutput`.

```swift
extension ViewController: TokenizationModuleOutput {
    func tokenizationModule(_ module: TokenizationModuleInput,
                            didTokenize token: Tokens,
                            paymentMethodType: PaymentMethodType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        // Отправьте токен в вашу систему
    }

    func didFinish(on module: TokenizationModuleInput,
                   with error: YandexCheckoutPaymentsError?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }

    func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Создать экран успеха после прохождения 3DS
            self.dismiss(animated: true)
            // Показать экран успеха
        }
    }
}
```

Закройте модуль SDK и отправьте токен в вашу систему. Затем [создайте платеж](https://kassa.yandex.ru/docs/guides/#custom) по API Яндекс.Кассы, в параметре `payment_token` передайте токен, полученный в SDK. Способ подтверждения при создании платежа зависит от способа оплаты, который выбрал пользователь. Он приходит вместе с токеном в `paymentMethodType`.

## Доступные способы оплаты

Сейчас в SDK для iOS доступны следующие способы оплаты:

`.yandexMoney` — Яндекс.Деньги (платежи из кошелька или привязанной картой)\
`.bankCard` — банковская карта (карты можно сканировать)\
`.sberbank` — Сбербанк Онлайн (с подтверждением по смс)\
`.applePay` — Apple Pay

## Настройка способов оплаты

У вас есть возможность сконфигурировать способы оплаты.\
Для этого необходимо при создании `TokenizationModuleInputData` в параметре `tokenizationSettings` передать модель типа `TokenizationSettings`.

> Для некоторых способов оплаты нужна дополнительная настройка (см. ниже).\
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

### Яндекс Деньги

1. Запросить у менеджера по подключению `client id` для центра авторизации в системе `YooMoney`.
2. При создании `TokenizationModuleInputData` передать `client id` в параметре `moneyAuthClientId`

```swift
let moduleData = TokenizationModuleInputData(
    ...
    moneyAuthClientId: "client_id")
```

Чтобы провести платеж:

1. При создании `TokenizationModuleInputData` передайте значение `.yandexMoney` в `paymentMethodTypes.`
2. Получите токен.
3. [Создайте платеж](https://kassa.yandex.ru/docs/guides#custom) с токеном по API Яндекс.Кассы.

### Банковская карта

1. При создании `TokenizationModuleInputData` передайте значение `.bankcard` в `paymentMethodTypes`.
2. Получите токен.
3. [Создайте платеж](https://kassa.yandex.ru/docs/guides#custom) с токеном по API Яндекс.Кассы.

### Сбербанк Онлайн

С помощью SDK можно провести платеж через «Мобильный банк» Сбербанка — с подтверждением оплаты по смс:

1. При создании `TokenizationModuleInputData` передайте значение `.sberbank` в `paymentMethodTypes`.
2. Получите токен.
3. [Создайте платеж](https://kassa.yandex.ru/docs/guides#custom) с токеном по API Яндекс.Кассы.

### Apple Pay

1. Чтобы подключить Apple Pay, нужно передать Яндекс.Кассе сертификат, с помощью которого Apple будет шифровать данные банковских карт.

Для этого:

- Напишите менеджеру и попросите создать для вас запрос на сертификат (`.csr`).
- Создайте сертификат в панели разработчика Apple (используйте `.csr`).
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
Например, если ваш apple pay identifier — `com.example.identifier`, то код будет следующим:
  >  
```swift
let moduleData = TokenizationModuleInputData(
    ...
    applePayMerchantIdentifier: "com.example.identifier")
```

2. Получите токен.
3. [Создайте платеж](https://kassa.yandex.ru/docs/guides#custom) с токеном по API Яндекс.Кассы.

## Описание публичных параметров

### TokenizationFlow

`Enum`, который определяет логику работы SDK.

| Case           | Тип              | Описание |
| -------------- | ---------------- | -------- |
| tokenization   | TokenizationFlow | Принимает на вход модель `TokenizationModuleInputData`. Логика для токенизации несколько способов оплаты на выбор: Банковская карта, Яндекс Деньги, Сбербанк-Онлайн, Apple Pay |
| bankCardRepeat | TokenizationFlow | Принимает на вход модель `BankCardRepeatModuleInputData`. Логика для токенизации сохраненных способов оплаты по идентификатору способа оплаты |

### YandexCheckoutPaymentsError

`Enum` с возможными ошибками, которые можно обработать в методе `func didFinish(on module:, with error:)`

| Case                  | Тип   | Описание |
| --------------------- | ----- | -------- |
| paymentMethodNotFound | Error | По paymentMethodId не было найдено ни одного сохраненного способа оплаты. |

### TokenizationModuleInputData

>Обязательные:

| Параметр             | Тип    | Описание |
| -------------------- | ------ | -------- |
| clientApplicationKey | String            | Ключ для клиентских приложений из личного кабинета Яндекс.Кассы |
| shopName             | String            | Название магазина в форме оплаты |
| purchaseDescription  | String            | Описание заказа в форме оплаты |
| amount               | Amount            | Объект, содержащий сумму заказа и валюту |
| savePaymentMethod    | SavePaymentMethod | Объект, описывающий логику того, будет ли платеж рекуррентным |

>Необязательные:

| Параметр                   | Тип                   | Описание |
| -------------------------- | --------------------- | -------- |
| gatewayId                  | String                | По умолчанию `nil`. Используется, если у вас несколько платежных шлюзов с разными идентификаторами. |
| tokenizationSettings       | TokenizationSettings  | По умолчанию используется стандартный инициализатор со всеми способами оплаты. Параметр отвечает за настройку токенизации (способы оплаты и логотип Яндекс.Кассы). |
| testModeSettings           | TestModeSettings      | По умолчанию `nil`. Настройки тестового режима. |
| cardScanning               | CardScanning          | По умолчанию `nil`. Возможность сканировать банковские карты. |
| applePayMerchantIdentifier | String                | По умолчанию `nil`. Apple Pay merchant ID (обязательно для платежей через Apple Pay). |
| returnUrl                  | String                | По умолчанию `nil`. URL страницы (поддерживается только `https`), на которую надо вернуться после прохождения 3-D Secure. Необходим только при кастомной реализации 3-D Secure. Если вы используете `start3dsProcess(requestUrl:)`, не задавайте этот параметр. |
| isLoggingEnabled           | Bool                  | По умолчанию `false`. Включает логирование сетевых запросов. |
| userPhoneNumber            | String                | По умолчанию `nil`. Телефонный номер пользователя. |
| customizationSettings      | CustomizationSettings | По умолчанию используется цвет blueRibbon. Цвет основных элементов, кнопки, переключатели, поля ввода. |
| moneyAuthClientId          | String                | По умолчанию `nil`. Идентификатор для центра авторизации в системе YooMoney.

### BankCardRepeatModuleInputData

>Обязательные:

| Параметр             | Тип    | Описание |
| -------------------- | ------ | -------- |
| clientApplicationKey | String | Ключ для клиентских приложений из личного кабинета Яндекс.Кассы |
| shopName             | String | Название магазина в форме оплаты |
| purchaseDescription  | String | Описание заказа в форме оплаты |
| paymentMethodId      | String | Идентификатор сохраненного способа оплаты |
| amount               | Amount | Объект, содержащий сумму заказа и валюту |

>Необязательные:

| Параметр                   | Тип                   | Описание |
| -------------------------- | --------------------- | -------- |
| testModeSettings           | TestModeSettings      | По умолчанию `nil`. Настройки тестового режима. |
| returnUrl                  | String                | По умолчанию `nil`. URL страницы (поддерживается только `https`), на которую надо вернуться после прохождения 3-D Secure. Необходим только при кастомной реализации 3-D Secure. Если вы используете `start3dsProcess(requestUrl:)`, не задавайте этот параметр. |
| isLoggingEnabled           | Bool                  | По умолчанию `false`. Включает логирование сетевых запросов. |
| customizationSettings      | CustomizationSettings | По умолчанию используется цвет blueRibbon. Цвет основных элементов, кнопки, переключатели, поля ввода. |

### TokenizationSettings

Можно настроить список способов оплаты и отображение логотипа Яндекс.Кассы в приложении.

| Параметр               | Тип                | Описание |
| ---------------------- | ------------------ | -------- |
| paymentMethodTypes     | PaymentMethodTypes | По умолчанию `.all`. [Способы оплаты](#настройка-способов-оплаты), доступные пользователю в приложении. |
| showYandexCheckoutLogo | Bool               | По умолчанию `true`. Отвечает за отображение логотипа Яндекс.Кассы. По умолчанию логотип отображается. |

### TestModeSettings

| Параметр                   | Тип    | Описание |
| -------------------------- | ------ | -------- |
| paymentAuthorizationPassed | Bool   | Определяет, пройдена ли платежная авторизация при оплате Яндекс.Деньгами. |
| cardsCount                 | Int    | Количество привязанные карт к кошельку в Яндекс.Деньгах. |
| charge                     | Amount | Сумма и валюта платежа. |
| enablePaymentError         | Bool   | Определяет, будет ли платеж завершен с ошибкой. |

### Amount

| Параметр | Тип      | Описание |
| -------- | -------- | -------- |
| value    | Decimal  | Сумма платежа |
| currency | Currency | Валюта платежа |

### Currency

| Параметр | Тип      | Описание |
| -------- | -------- | -------- |
| rub      | String   | ₽ - Российский рубль |
| usd      | String   | $ - Американский доллар |
| eur      | String   | € - Евро |
| custom   | String   | Будет отображаться значение, которое передали |

### CustomizationSettings

| Параметр   | Тип     | Описание |
| ---------- | ------- | -------- |
| mainScheme | UIColor | По умолчанию используется цвет blueRibbon. Цвет основных элементов, кнопки, переключатели, поля ввода. |

### SavePaymentMethod

| Параметр    | Тип               | Описание |
| ----------- | ----------------- | -------- |
| on          | SavePaymentMethod | Сохранить платёжный метод для проведения рекуррентных платежей. Пользователю будут доступны только способы оплаты, поддерживающие сохранение. На экране контракта будет отображено сообщение о том, что платёжный метод будет сохранён. |
| off         | SavePaymentMethod | Не дает пользователю выбрать, сохранять способ оплаты или нет. |
| userSelects | SavePaymentMethod | Пользователь выбирает, сохранять платёжный метод или нет. Если метод можно сохранить, на экране контракта появится переключатель. |

## Сканирование банковских карт

Если хотите, чтобы пользователи смогли сканировать банковские карты при оплате, необходимо:

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

## Настройка 3D Secure

Если вы хотите использовать нашу реализацию 3-D Secure, не закрывайте модуль SDK после получения токена.\
Отправьте токен на ваш сервер и после успешной оплаты закройте модуль.\
Если ваш сервер сообщил о необходимости подтверждения платежа (т.е. платёж пришёл со статусом `pending`), вызовите метод `start3dsProcess(requestUrl:)`

После успешного прохождения 3-D Secure будет вызван метод `didSuccessfullyPassedCardSec(on module:)` протокола `TokenizationModuleOutput`.

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

3. Покажите 3-D Secure, если необходимо подтвердить платеж.

```swift
func needsConfirmPayment(requestUrl: String) {
    self.tokenizationViewController.start3dsProcess(requestUrl: requestUrl)
}
```

4. После успешного прохождения 3-D Secure будет вызван метод.

```swift
func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        // Now close tokenization module
        self.dismiss(animated: true)
    }
}
```

## Логирование

У вас есть возможность включить логирование всех сетевых запросов.\
Для этого необходимо при создании `TokenizationModuleInputData` передать `isLoggingEnabled: true`

```swift
let moduleData = TokenizationModuleInputData(
    ...
    isLoggingEnabled: true)
```

## Тестовый режим

У вас есть возможность запустить мобильный SDK в тестовом режиме.\
Тестовый режим не выполняет никаких сетевых запросов и имитирует ответ от сервера.

Если вы хотите запустить SDK в тестовом режиме, необходимо:

1. Сконфигурировать объект с типом `TestModeSettings`.

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

## Запуск Example

Чтобы запустить Example приложение, необходимо:

1. Сделать `git clone` репозитория.

```shell
git clone https://github.com/yandex-money/yandex-checkout-payments-swift.git
```

2. Добавить `TMXProfiling.framework` и `TMXProfilingConnections.framework` в папку `Frameworks`, которая находится на одном уровне с папкой `Pods` (см. [Подключение TMXProfiling и TMXProfilingConnections](#%d0%9f%d0%be%d0%b4%d0%ba%d0%bb%d1%8e%d1%87%d0%b5%d0%bd%d0%b8%d0%b5-tmxprofiling-%d0%b8-tmxprofilingconnections))
3. В консоли перейти в папку с проектом и выполнить следующие команды:

```shell
gem install bundler
bundle
pod install
```

4. Открыть `YandexCheckoutPayments.xcworkspace`.
5. Выбрать и запустить схему `ExamplePods`.

## Кастомизация интерфейса

По умолчанию используется цвет blueRibbon. Цвет основных элементов, кнопки, переключатели, поля ввода.

1. Сконфигурировать объект `CustomizationSettings` и передать его в параметр `customizationSettings` объекта `TokenizationModuleInputData`.

```swift
let moduleData = TokenizationModuleInputData(
    ...
    customizationSettings: CustomizationSettings(mainScheme: /* UIColor */ ))
```

## Платёж привязанной к магазину картой с дозапросом CVC/CVV

1. Создайте `BankCardRepeatModuleInputData`.

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

2. Создайте `TokenizationFlow` с кейсом `.bankCardRepeat` и передайте `BankCardRepeatModuleInputData`.

```swift
let inputData: TokenizationFlow = .bankCardRepeat(bankCardRepeatModuleInputData)
```

3. Создайте `ViewController` из `TokenizationAssembly` и выведите его на экран.

```swift
let viewController = TokenizationAssembly.makeModule(
    inputData: inputData,
    moduleOutput: self
)
present(viewController, animated: true, completion: nil)
```

## Лицензия

Yandex Checkout Payments SDK доступна под лицензией MIT. Смотрите [LICENSE](https://github.com/yandex-money/yandex-checkout-payments-swift/blob/master/LICENSE) файл для получения дополнительной информации.
