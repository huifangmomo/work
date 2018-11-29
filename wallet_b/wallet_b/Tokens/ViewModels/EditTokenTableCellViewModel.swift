// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

struct EditTokenTableCellViewModel {

    let token: TokenObject
    let coinTicker: CoinTicker?
    let config: Config
    let isLocal: Bool
    private let shortFormatter = EtherNumberFormatter.short
    init(
        token: TokenObject,
        coinTicker: CoinTicker?,
        config: Config,
        isLocal: Bool = true
    ) {
        self.token = token
        self.coinTicker = coinTicker
        self.config = config
        self.isLocal = isLocal
    }

    var title: String {
        let str = String(format: token.title_2, amount)
        return str
    }
    
    var amount: String {
        return shortFormatter.string(from: BigInt(token.value) ?? BigInt(), decimals: token.decimals)
    }

    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .medium)
    }

    var titleTextColor: UIColor {
        return UIColor.black
    }

    var placeholderImage: UIImage? {
        return R.image.icon_Money_1()
    }

    var imageUrl: URL? {
        return token.imageURL
    }

    var isEnabled: Bool {
        return !token.isDisabled
    }

    private var isAvailableForChange: Bool {
        // One version had an option to disable ETH token. Adding functionality to enable it back.
        if token.contract == TokensDataStore.etherToken(for: config).contract && token.isDisabled == true {
            return false
        }
        return token.contract == TokensDataStore.etherToken(for: config).contract ? true : false
    }

    var contractText: String? {
        if !isAvailableForChange {
            return token.contract
        }
        return .none
    }

    var isTokenContractLabelHidden: Bool {
        if contractText == nil {
            return true
        }
        return false
    }

    var isSwitchHidden: Bool {
        return isAvailableForChange || !isLocal
    }
}
