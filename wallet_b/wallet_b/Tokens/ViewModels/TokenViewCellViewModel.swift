// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

struct TokenViewCellViewModel {

    private let shortFormatter = EtherNumberFormatter.short

    let token: TokenObject
    let ticker: CoinTicker?

    init(
        token: TokenObject,
        ticker: CoinTicker?
    ) {
        self.token = token
        self.ticker = ticker
    }

    var title: String {
        return token.title
    }

    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .medium)
    }

    var titleTextColor: UIColor {
        return UIColor.black
    }

    var amount: String {
        return shortFormatter.string(from: BigInt(token.value) ?? BigInt(), decimals: token.decimals)
    }

    var currencyAmount: String? {
        guard let ticker = ticker, let price = Double(ticker.price), price > 0 else { return .none }
        let str:String! = CurrencyFormatter.formatter.string(from: NSNumber(value: price))
        if str.contains("US") {
            return str.substring(from: 2)
        }else{
            return str
        }
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    var currencyAmountFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    var backgroundColor: UIColor {
        return .white
    }

//    var amountTextColor: UIColor {
//        return Colors.black
//    }
//
//    var currencyAmountTextColor: UIColor {
//        return Colors.lightGray
//    }

    var percentChange: String? {
        guard let _ = currencyAmount else {
            return .none
        }
        guard let percent_change_24h = ticker?.percent_change_24h, !percent_change_24h.isEmpty else { return nil }
        return "(" + percent_change_24h + "%)"
    }

    var percentChangeFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .light)
    }

    var placeholderImage: UIImage? {
        return R.image.icon_Money_1()
    }

    var imageUrl: URL? {
        return URL(string: token.imagePath)
    }
    
    var percentChangeColor: UIColor {
        guard let ticker = ticker else { return UIColor(hex: "999999") }
        return ticker.percent_change_24h.starts(with: "-") ? UIColor.red : UIColor.green
    }
}
