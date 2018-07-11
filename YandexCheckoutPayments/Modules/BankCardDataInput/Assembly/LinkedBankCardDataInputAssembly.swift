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

enum LinkedBankCardDataInputAssembly {

    static func makeModule(inputData: LinkedBankCardDataInputModuleInputData,
                           moduleOutput: LinkedBankCardDataInputModuleOutput?) -> UIViewController {

        let view = BankCardDataInputViewController()
        let presenter = LinkedBankCardDataInputPresenter(inputData: inputData)

        let cardService = CardService()
        let analyticsService = AnalyticsProcessingAssembly.makeAnalyticsService()
        let authorizationService
            = AuthorizationProcessingAssembly.makeService(testModeSettings: inputData.testModeSettings)
        let analyticsProvider = AnalyticsProvider(authorizationService: authorizationService)
        let interactor = BankCardDataInputInteractor(cardService: cardService,
                                                     authorizationService: authorizationService,
                                                     analyticsService: analyticsService,
                                                     analyticsProvider: analyticsProvider)

        view.output = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        let panInputPresenter = InputPresenter(textInputStyle: PanInputPresenterStyle())
        view.panPresenter = panInputPresenter

        return view
    }
}
