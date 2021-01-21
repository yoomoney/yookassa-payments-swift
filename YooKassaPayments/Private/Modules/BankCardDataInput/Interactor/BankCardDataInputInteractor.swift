/*
 * The MIT License (MIT)
 *
 * Copyright © 2020 NBCO YooMoney LLC
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

class BankCardDataInputInteractor {

    // MARK: - VIPER

    weak var output: BankCardDataInputInteractorOutput?

    // MARK: - Init data

    private let cardService: CardService
    private let analyticsService: AnalyticsService
    private let analyticsProvider: AnalyticsProvider
    private let bankSettingsService: BankSettingsService

    // MARK: - Init

    init(
        cardService: CardService,
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider,
        bankSettingsService: BankSettingsService
    ) {
        self.cardService = cardService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
        self.bankSettingsService = bankSettingsService
    }
}

// MARK: - BankCardDataInputInteractorInput

extension BankCardDataInputInteractor: BankCardDataInputInteractorInput {
    func validate(cardData: CardData) {
        guard let errors = cardService.validate(cardData: cardData) else {
            output?.successValidateCardData()
            return
        }
        output?.failValidateCardData(errors: errors)
    }

    func validate(csc: String) {
        do {
            try cardService.validate(csc: csc)
        } catch {
            if let error = error as? CardService.ValidationError {
                output?.failValidateCardData(errors: [error])
                return
            }
        }
        output?.successValidateCardData()
    }

    func fetchBankCardSettings(_ pan: String) {
        guard let bankSettings = bankSettingsService.bankSettings(pan) else {
            output?.didFailFetchBankSettings()
            return
        }
        output?.didFetchBankSettings(bankSettings)
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }

    func makeTypeAnalyticsParameters() -> (authType: AnalyticsEvent.AuthType,
                                           tokenType: AnalyticsEvent.AuthTokenType?) {
        return analyticsProvider.makeTypeAnalyticsParameters()
    }
}
