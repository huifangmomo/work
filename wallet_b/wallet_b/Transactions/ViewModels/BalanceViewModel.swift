// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct BalanceViewModel: BalanceBaseViewModel {

    let balance: Balance?
    let rate: CurrencyRate?
    let config: Config

    init(
        balance: Balance? = .none,
        rate: CurrencyRate? = .none,
        config: Config = Config()
    ) {
        self.balance = balance
        self.rate = rate
        self.config = config
    }

    var amount: Double {
        guard let balance = balance else { return 0.00 }
        return CurrencyFormatter.plainFormatter.string(from: balance.value).doubleValue
    }

    var amountString: String {
        guard let balance = balance else { return "--" }
        guard !balance.isZero else { return "0.00 \(config.server.symbol)" }
        return "\(balance.amountFull) \(config.server.symbol)"
    }

    var currencyAmount: String? {
        guard let rate = rate else { return nil }
        guard
            let currentRate = (rate.rates.filter { $0.contract == config.server.address }.first),
            currentRate.price > 0,
            amount > 0
        else { return nil }
        let totalAmount = amount * currentRate.price
        let str:String! = CurrencyFormatter.formatter.string(from: NSNumber(value: totalAmount))
        if str.contains("US") {
            return str.substring(from: 2)
        }else{
            return str
        }
    }

    var amountFull: String {
        return balance?.amountFull ?? "--"
    }

    var amountShort: String {
        return balance?.amountShort ?? "--"
    }

    var symbol: String {
        return config.server.symbol
    }
}
