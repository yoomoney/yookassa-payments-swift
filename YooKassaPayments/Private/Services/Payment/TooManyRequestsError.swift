import YooKassaPaymentsApi

struct TooManyRequestsError: PresentableError {
    var title: String? {
        return nil
    }

    var message: String { Localized.message }

    var style: PresentableNotificationStyle {
        return .alert
    }
    var actions: [PresentableNotificationAction] {
        return []
    }
}

// MARK: - Localized

private extension TooManyRequestsError {
    enum Localized {
        static let message = NSLocalizedString(
            "Error.paymentOptions.tooManyRequests.429",
            bundle: Bundle.framework,
            value: "Превышен лимит запросов",
            comment: "HTTP 429 Ошибка `Превышен лимит запросов` на экране выбора способа оплаты"
        )
    }
}
