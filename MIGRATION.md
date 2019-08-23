# Migration guide

- [Migration guide](#migration-guide)
  - [2.1.0 -> 2.2.0](#210---220)

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
