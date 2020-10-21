/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2017 NBCO Yandex.Money LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import class UIKit.UIViewController

enum BankCardDataInputAssembly {
    static func makeModule(inputData: BankCardDataInputModuleInputData,
                           moduleOutput: BankCardDataInputModuleOutput?) -> UIViewController {

        let view = BankCardDataInputViewController()
        let presenter = BankCardDataInputPresenter(inputData: inputData)
        let router = BankCardDataInputRouter(cardScanner: inputData.cardScanner)

        let cardService = CardService()
        let analyticsService = AnalyticsProcessingAssembly.makeAnalyticsService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProvidingAssembly.makeAnalyticsProvider(
            testModeSettings: inputData.testModeSettings
        )
        let interactor = BankCardDataInputInteractor(
            cardService: cardService,
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            bankSettingsService: BankServiceSettingsImpl.shared
        )

        view.output = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput
        presenter.router = router

        interactor.output = presenter

        router.transitionHandler = view
        router.output = presenter

        let panInputPresenter = InputPresenter(textInputStyle: PanInputPresenterStyle())
        view.panPresenter = panInputPresenter

        return view
    }
}
