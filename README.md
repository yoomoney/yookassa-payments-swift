# YooKassa Payments SDK

[![Platform](https://img.shields.io/badge/Support-iOS%2010.0+-brightgreen.svg)](https://img.shields.io/badge/Support-iOS%2010.3+-brightgreen.svg)
[![GitHub tag](https://img.shields.io/github/tag/yoomoney/yookassa-payments-swift.svg)](https://img.shields.io/github/tag/yoomoney/yookassa-payments-swift.svg)
[![Documentation](docs/badge.svg)](docs/badge.svg)
[![license](https://img.shields.io/github/license/yoomoney/yookassa-payments-swift.svg)](https://img.shields.io/github/license/yoomoney/yookassa-payments-swift.svg)

Библиотека позволяет встроить прием платежей в мобильные приложения на iOS и работает как дополнение к API ЮKassa.\
В мобильный SDK входят готовые платежные интерфейсы (форма оплаты и всё, что с ней связано).\
С помощью SDK можно получать токены для проведения оплаты с банковской карты, через Apple Pay, Сбербанк Онлайн или из кошелька в ЮMoney.

- [Код библиотеки](https://github.com/yoomoney/yookassa-payments-swift/tree/master/YooKassaPayments)
- [Код демо-приложения, которое интегрирует SDK](https://github.com/yoomoney/yookassa-payments-swift/tree/master/YooKassaPaymentsExample)
- [Документация](https://yoomoney.github.io/yookassa-payments-swift/)

---

- [YooKassa Payments SDK](#yookassa-payments-sdk)
  - [Changelog](#changelog)
  - [Migration guide](#migration-guide)
  - [Подключение зависимостей](#подключение-зависимостей)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
  - [Подключение TMXProfiling и TMXProfilingConnections](#подключение-tmxprofiling-и-tmxprofilingconnections)
  - [Быстрая интеграция](#быстрая-интеграция)
  - [Доступные способы оплаты](#доступные-способы-оплаты)
  - [Настройка способов оплаты](#настройка-способов-оплаты)
    - [ЮMoney](#юmoney)
      - [Как получить `client id` центра авторизации системы `ЮMoney`](#как-получить-client-id-центра-авторизации-системы-юmoney)
      - [Передать `client id` в параметре `moneyAuthClientId`](#передать-client-id-в-параметре-moneyauthclientid)
    - [Банковская карта](#банковская-карта)
    - [Сбербанк Онлайн](#сбербанк-онлайн)
    - [Apple Pay](#apple-pay)
  - [Описание публичных параметров](#описание-публичных-параметров)
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
  - [Сканирование банковских карт](#сканирование-банковских-карт)
  - [Настройка подтверждения платежа](#настройка-подтверждения-платежа)
  - [Логирование](#логирование)
  - [Тестовый режим](#тестовый-режим)
  - [Запуск Example](#запуск-example)
  - [Кастомизация интерфейса](#кастомизация-интерфейса)
  - [Платёж привязанной к магазину картой с дозапросом CVC/CVV](#платёж-привязанной-к-магазину-картой-с-дозапросом-cvccvv)
  - [Лицензия](#лицензия)

## Changelog

[Ссылка на Changelog](https://github.com/yoomoney/yookassa-payments-swift/blob/master/CHANGELOG.md)

## Migration guide

[Ссылка на Migration guide](https://github.com/yoomoney/yookassa-payments-swift/blob/master/MIGRATION.md)

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
  [Пример](https://github.com/yoomoney/yookassa-payments-swift/tree/master/YooKassaPaymentsExample/Podfile-example) `Podfile` из демо-приложения.

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

> `Your Target Name` - название таргета в Xcode для вашего приложения.\
> `tag` - версия SDK. Актуальную версию можно узнать на github в разделе [releases](https://github.com/yoomoney/yookassa-payments-swift/releases).

3. Выполните команду `pod install`

### Carthage

На текущий момент Carthage не поддерживается.

## Подключение TMXProfiling и TMXProfilingConnections

Чтобы получить файл `.xcframework`,  [зарегистрируйтесь в ЮKassa](https://yookassa.ru/joinups)
и сообщите вашему менеджеру, что хотите подключить мобильный SDK.

1. Используя Finder или другой файловый менеджер добавьте библиотеки `TMXProfiling.xcframework` и `TMXProfilingConnections.xcframework` в папку c вашим проектом.

2. В разделе `General` у основного таргета проекта добавьте `TMXProfiling.xcframework` и `TMXProfilingConnections.xcframework` в `Frameworks, Libraries, and Embedded Content`.

3. `TMXProfiling.xcframework` и `TMXProfilingConnections.xcframework` должны быть добавлены как `Embed & Sign`

## Быстрая интеграция

1. Создайте `TokenizationModuleInputData` (понадобится [ключ для клиентских приложений](https://yookassa.ru/my/tunes) из личного кабинета ЮKassa). В этой модели передаются параметры платежа (валюта и сумма) и параметры платежной формы, которые увидит пользователь при оплате (способы оплаты, название магазина и описание заказа).

> Для работы с сущностями YooKassaPayments импортируйте зависимости в исходный файл

```swift
import YooKassaPayments
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
    func tokenizationModule(
        _ module: TokenizationModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        // Отправьте токен в вашу систему
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
            // Создать экран успеха после прохождения подтверждения (3DS или Sberpay)
            self.dismiss(animated: true)
            // Показать экран успеха
        }
    }
}
```

Закройте модуль SDK и отправьте токен в вашу систему. Затем [создайте платеж](https://yookassa.ru/developers/api#create_payment) по API ЮKassa, в параметре `payment_token` передайте токен, полученный в SDK. Способ подтверждения при создании платежа зависит от способа оплаты, который выбрал пользователь. Он приходит вместе с токеном в `paymentMethodType`.

## Доступные способы оплаты

Сейчас в SDK для iOS доступны следующие способы оплаты:

`.yooMoney` — ЮMoney (платежи из кошелька или привязанной картой)\
`.bankCard` — банковская карта (карты можно сканировать)\
`.sberbank` — SberPay (с подтверждением через приложение Сбербанк Онлайн, если оно установленно, иначе с подтверждением по смс)\
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

if <Условие для ЮMoney> {
    // Добавляем в paymentMethodTypes элемент `.yooMoney`
    paymentMethodTypes.insert(.yooMoney)
}

if <Условие для Apple Pay> {
    // Добавляем в paymentMethodTypes элемент `.applePay`
    paymentMethodTypes.insert(.applePay)
}

let tokenizationSettings = TokenizationSettings(paymentMethodTypes: paymentMethodTypes)
```

Теперь используйте `tokenizationSettings` при инициализации `TokenizationModuleInputData`.

### ЮMoney

Для подключения способа оплаты `ЮMoney` необходимо:

1. Получить `client id` центра авторизации системы `ЮMoney`.
2. При создании `TokenizationModuleInputData` передать `client id` в параметре `moneyAuthClientId`

#### Как получить `client id` центра авторизации системы `ЮMoney`

1. Авторизуйтесь на [yookassa.ru](https://yookassa.ru)
2. Перейти на страницу регистрации клиентов СЦА - [yookassa.ru/oauth/v2/client](https://yookassa.ru/oauth/v2/client)
3. Нажать [Зарегистрировать](https://yookassa.ru/oauth/v2/client/create)
4. Заполнить поля:\
4.1. "Название" - `required` поле, отображается при выдаче прав и в списке приложений.\
4.2. "Описание" - `optional` поле, отображается у пользователя в списке приложений.\
4.3. "Ссылка на сайт приложения" - `optional` поле, отображается у пользователя в списке приложений.\
4.4. "Код подтверждения" - выбрать `Передавать в Callback URL`, можно указывать любое значение, например ссылку на сайт.
5. Выбрать доступы:\
5.1. `Кошелёк ЮMoney` -> `Просмотр`\
5.2. `Профиль ЮMoney` -> `Просмотр`
6. Нажать `Зарегистрировать`

#### Передать `client id` в параметре `moneyAuthClientId`

При создании `TokenizationModuleInputData` передать `client id` в параметре `moneyAuthClientId`

```swift
let moduleData = TokenizationModuleInputData(
    ...
    moneyAuthClientId: "client_id")
```

Чтобы провести платеж:

1. При создании `TokenizationModuleInputData` передайте значение `.yooMoney` в `paymentMethodTypes.`
2. Получите токен.
3. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

### Банковская карта

1. При создании `TokenizationModuleInputData` передайте значение `.bankcard` в `paymentMethodTypes`.
2. Получите токен.
3. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

### SberPay

С помощью SDK можно провести платеж через «Мобильный банк» Сбербанка — с подтверждением оплаты через приложение Сбербанк Онлайн, если оно установленно, иначе с подтверждением по смс.

В `TokenizationModuleInputData` необходимо передавать `applicationScheme` – схема для возврата в приложение, после успешной оплаты с помощью `Sberpay` в приложении СберБанк Онлайн открытого через deeplink.  

Пример `applicationScheme`:

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applicationScheme: "sberpayexample://"
```

Чтобы провести платёж:

1. При создании `TokenizationModuleInputData` передайте значение `.sberbank` в `paymentMethodTypes`.
2. Получите токен.
3. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

Для подтверждения платежа через приложение СберБанк Онлайн:

1. В `AppDelegate` импортируйте зависимость `YooKassaPayments`:

   ```swift
   import YooKassaPayments
   ```

2. Добавьте обработку ссылок через `YKSdk` в `AppDelegate`:

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

3. В `Info.plist` добавьте:

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

4. Реализуйте метод  `didSuccessfullyConfirmation(paymentMethodType:)` протокола `TokenizationModuleOutput`, который будет вызван после успешного подтверждения платежа (см. [Настройка подтверждения платежа](#настройка-подтверждения-платежа)).

### Apple Pay

1. Чтобы подключить Apple Pay, нужно передать в ЮKassa сертификат, с помощью которого Apple будет шифровать данные банковских карт.

Для этого:

- Напишите менеджеру и попросите создать для вас запрос на сертификат (`.csr`).
- Создайте сертификат в панели разработчика Apple (используйте `.csr`).
- Скачайте получившийся сертификат и пришлите менеджеру.

[Подробная инструкция](https://yookassa.ru/files/manual_connection_Apple_Pay(website).pdf) (см. раздел 2 «Обмен сертификатами с Apple»)

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
3. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

## Описание публичных параметров

### TokenizationFlow

`Enum`, который определяет логику работы SDK.

| Case           | Тип              | Описание |
| -------------- | ---------------- | -------- |
| tokenization   | TokenizationFlow | Принимает на вход модель `TokenizationModuleInputData`. Логика для токенизации несколько способов оплаты на выбор: Банковская карта, ЮMoney, Сбербанк-Онлайн, Apple Pay |
| bankCardRepeat | TokenizationFlow | Принимает на вход модель `BankCardRepeatModuleInputData`. Логика для токенизации сохраненных способов оплаты по идентификатору способа оплаты |

### YooKassaPaymentsError

`Enum` с возможными ошибками, которые можно обработать в методе `func didFinish(on module:, with error:)`

| Case                  | Тип   | Описание |
| --------------------- | ----- | -------- |
| paymentMethodNotFound | Error | По paymentMethodId не было найдено ни одного сохраненного способа оплаты. |

### TokenizationModuleInputData

>Обязательные:

| Параметр             | Тип    | Описание |
| -------------------- | ------ | -------- |
| clientApplicationKey | String            | Ключ для клиентских приложений из личного кабинета ЮKassa |
| shopName             | String            | Название магазина в форме оплаты |
| purchaseDescription  | String            | Описание заказа в форме оплаты |
| amount               | Amount            | Объект, содержащий сумму заказа и валюту |
| savePaymentMethod    | SavePaymentMethod | Объект, описывающий логику того, будет ли платеж рекуррентным |

>Необязательные:

| Параметр                   | Тип                   | Описание                                                     |
| -------------------------- | --------------------- | ------------------------------------------------------------ |
| gatewayId                  | String                | По умолчанию `nil`. Используется, если у вас несколько платежных шлюзов с разными идентификаторами. |
| tokenizationSettings       | TokenizationSettings  | По умолчанию используется стандартный инициализатор со всеми способами оплаты. Параметр отвечает за настройку токенизации (способы оплаты и логотип ЮKassa). |
| testModeSettings           | TestModeSettings      | По умолчанию `nil`. Настройки тестового режима.              |
| cardScanning               | CardScanning          | По умолчанию `nil`. Возможность сканировать банковские карты. |
| applePayMerchantIdentifier | String                | По умолчанию `nil`. Apple Pay merchant ID (обязательно для платежей через Apple Pay). |
| returnUrl                  | String                | По умолчанию `nil`. URL страницы (поддерживается только `https`), на которую надо вернуться после прохождения 3-D Secure. Необходим только при кастомной реализации 3-D Secure. Если вы используете `startConfirmationProcess(confirmationUrl:paymentMethodType:)`, не задавайте этот параметр. |
| isLoggingEnabled           | Bool                  | По умолчанию `false`. Включает логирование сетевых запросов. |
| userPhoneNumber            | String                | По умолчанию `nil`. Телефонный номер пользователя.           |
| customizationSettings      | CustomizationSettings | По умолчанию используется цвет blueRibbon. Цвет основных элементов, кнопки, переключатели, поля ввода. |
| moneyAuthClientId          | String                | По умолчанию `nil`. Идентификатор для центра авторизации в системе YooMoney. |
| applicationScheme          | String                | По умолчанию `nil`. Cхема для возврата в приложение, после успешной оплаты с помощью `Sberpay` в приложении СберБанк Онлайн открытого через deeplink. |
### BankCardRepeatModuleInputData

>Обязательные:

| Параметр             | Тип    | Описание |
| -------------------- | ------ | -------- |
| clientApplicationKey | String | Ключ для клиентских приложений из личного кабинета ЮKassa |
| shopName             | String | Название магазина в форме оплаты |
| purchaseDescription  | String | Описание заказа в форме оплаты |
| paymentMethodId      | String | Идентификатор сохраненного способа оплаты |
| amount               | Amount | Объект, содержащий сумму заказа и валюту |

>Необязательные:

| Параметр              | Тип                   | Описание                                                     |
| --------------------- | --------------------- | ------------------------------------------------------------ |
| testModeSettings      | TestModeSettings      | По умолчанию `nil`. Настройки тестового режима.              |
| returnUrl             | String                | По умолчанию `nil`. URL страницы (поддерживается только `https`), на которую надо вернуться после прохождения 3-D Secure. Необходим только при кастомной реализации 3-D Secure. Если вы используете `startConfirmationProcess(confirmationUrl:paymentMethodType:)`, не задавайте этот параметр. |
| isLoggingEnabled      | Bool                  | По умолчанию `false`. Включает логирование сетевых запросов. |
| customizationSettings | CustomizationSettings | По умолчанию используется цвет blueRibbon. Цвет основных элементов, кнопки, переключатели, поля ввода. |

### TokenizationSettings

Можно настроить список способов оплаты и отображение логотипа ЮKassa в приложении.

| Параметр               | Тип                | Описание |
| ---------------------- | ------------------ | -------- |
| paymentMethodTypes     | PaymentMethodTypes | По умолчанию `.all`. [Способы оплаты](#настройка-способов-оплаты), доступные пользователю в приложении. |
| showYooKassaLogo       | Bool               | По умолчанию `true`. Отвечает за отображение логотипа ЮKassa. По умолчанию логотип отображается. |

### TestModeSettings

| Параметр                   | Тип    | Описание |
| -------------------------- | ------ | -------- |
| paymentAuthorizationPassed | Bool   | Определяет, пройдена ли платежная авторизация при оплате ЮMoney. |
| cardsCount                 | Int    | Количество привязанные карт к кошельку в ЮMoney. |
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

## Настройка подтверждения платежа

Если вы хотите использовать нашу реализацию подтверждения платежа, не закрывайте модуль SDK после получения токена.\
Отправьте токен на ваш сервер и после успешной оплаты закройте модуль.\
Если ваш сервер сообщил о необходимости подтверждения платежа (т.е. платёж пришёл со статусом `pending`), вызовите метод `startConfirmationProcess(confirmationUrl:paymentMethodType:)`.

После успешного прохождения подтверждения будет вызван метод `didSuccessfullyConfirmation(paymentMethodType:)` протокола `TokenizationModuleOutput`.

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

3. Вызовите подтверждение платежа, если это необходимо.

```swift
self.tokenizationViewController.startConfirmationProcess(
    confirmationUrl: confirmationUrl,
    paymentMethodType: paymentMethodType
)
```

4. После успешного подтверждения платежа будет вызван метод.

```swift
func didSuccessfullyConfirmation(paymentMethodType: PaymentMethodType) {
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
git clone https://github.com/yoomoney/yookassa-payments-swift.git
```

2. Создайте папку `Frameworks` в корне проекта.
3. Добавьте `TMXProfiling.xcframework` и `TMXProfilingConnections.xcframework` в папку `Frameworks`
4. В консоли перейти в папку с проектом и выполнить следующие команды:

```shell
gem install bundler
bundle
pod install
```

4. Открыть `YooKassaPayments.xcworkspace`.
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

YooKassa Payments SDK доступна под лицензией MIT. Смотрите [LICENSE](https://github.com/yoomoney/yookassa-payments-swift/blob/master/LICENSE) файл для получения дополнительной информации.
