# Migration guide

- [Migration guide](#migration-guide)
  - [2.\*.\* -> 3.\*.\*](#2---3)
  - [2.1.0 -> 2.2.0](#210---220)

## 2.\*.\* -> 3.\*.\*

В `TokenizationModuleInputData` появился новый обязательный параметр - `savePaymentMethod`

Если способ оплаты сохранен, магазин может совершать регулярные платежи с помощью токена.

Для этой настройки существует три варианта:

`SavePaymentMethod.on` - Сохранить платёжный метод для проведения рекуррентных платежей.\
Пользователю будут доступны только способы оплаты, поддерживающие сохранение.\
На экране контракта будет отображено сообщение о том, что платёжный метод будет сохранён.

`SavePaymentMethod.off` - Не дает пользователю выбрать, сохранять способ оплаты или нет.

`SavePaymentMethod.userSelects` - Пользователь выбирает, сохранять платёжный метод или нет. Если метод можно сохранить, на экране контракта появится переключатель.

 Подробнее про проведения рекуррентных платежей можно [прочитать тут](https://kassa.yandex.ru/developers/payments/recurring-payments).

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
