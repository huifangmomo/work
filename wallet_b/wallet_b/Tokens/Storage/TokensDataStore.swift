// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import APIKit
import RealmSwift
import BigInt
import Moya
import TrustCore

enum TokenAction {
    case disable(Bool)
    case updateInfo
}

class TokensDataStore {
    var tokens: Results<TokenObject> {
        return realm.objects(TokenObject.self).filter(NSPredicate(format: "isDisabled == NO"))
            .sorted(byKeyPath: "contract", ascending: true)
    }
    var nonFungibleTokens: Results<NonFungibleTokenCategory> {
        return realm.objects(NonFungibleTokenCategory.self).sorted(byKeyPath: "name", ascending: true)
    }
    let config: Config
    let realm: Realm
    
    var objects: [TokenObject] {
        return realm.objects(TokenObject.self)
            .sorted(byKeyPath: "contract", ascending: true)
            .filter { !$0.contract.isEmpty }
    }
    var enabledObject: [TokenObject] {
        return realm.objects(TokenObject.self)
            .sorted(byKeyPath: "contract", ascending: true)
            .filter { !$0.isDisabled }
    }
    var nonFungibleObjects: [NonFungibleTokenObject] {
        return realm.objects(NonFungibleTokenObject.self).map { $0 }
    }

    init(
        realm: Realm,
        config: Config
    ) {
        self.config = config
        self.realm = realm
        self.addEthToken()
    }

    
    func getToken(for address: Address) -> TokenObject? {
        return realm.object(ofType: TokenObject.self, forPrimaryKey: address.description)
    }
    
    private func addEthToken() {
        let etherToken = TokensDataStore.etherToken(for: config)
        if objects.first(where: { $0 == etherToken }) == nil {
            add(tokens: [etherToken])
        }
        
//        let token1 = ERC20Token(
//            contract: Address(string: "0xB8c77482e45F1F44dE1745F52C74426C631bDD52")!,
//            name: "BNB",
//            symbol: "BNB",
//            decimals: 18
//        )
//        addCustom(token: token1)
//        let token2 = ERC20Token(
//            contract: Address(string: "0xd850942ef8811f2a866692a623011bde52a462c1")!,
//            name: "VeChain",
//            symbol: "VEN",
//            decimals: 18
//        )
//        addCustom(token: token2)
//        let token3 = ERC20Token(
//            contract: Address(string: "0xd26114cd6EE289AccF82350c8d8487fedB8A0C07")!,
//            name: "OmiseGO",
//            symbol: "OMG",
//            decimals: 18
//        )
//        addCustom(token: token3)
//        let token4 = ERC20Token(
//            contract: Address(string: "0xe41d2489571d322189246dafa5ebde1f4699f498")!,
//            name: "ZRX ",
//            symbol: "ZRX",
//            decimals: 18
//        )
//        addCustom(token: token4)
//        let token5 = ERC20Token(
//            contract: Address(string: "0xd850942ef8811f2a866692a623011bde52a462c1")!,
//            name: "Zilliqa",
//            symbol: "ZIL",
//            decimals: 12
//        )
//        addCustom(token: token5)
//        let token6 = ERC20Token(
//            contract: Address(string: "0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2")!,
//            name: "Maker",
//            symbol: "MKR",
//            decimals: 18
//        )
//        addCustom(token: token6)
//        
//        let token7 = ERC20Token(
//            contract: Address(string: "0xaa4a3990673d9d913a24f89e956e7c02a03f9b08")!,
//            name: "MONEY MONSTER",
//            symbol: "MMON",
//            decimals: 6
//        )
//        addCustom(token: token7)
    }

    func coinTicker(for token: TokenObject) -> CoinTicker? {
        return tickers().first(where: {
            return $0.key == CoinTickerKeyMaker.makePrimaryKey(symbol: $0.symbol, contract: token.contract, currencyKey: $0.tickersKey)
        })
    }
    

    func addCustom(token: ERC20Token) {
        let newToken = TokenObject(
            contract: token.contract.description,
            name: token.name,
            symbol: token.symbol,
            decimals: token.decimals,
            value: "0",
            isCustom: true
        )
        add(tokens: [newToken])
    }

    func add(tokens: [Object]) {
        try? realm.write {
            if let tokenObjects = tokens as? [TokenObject] {
                let tokenObjectsWithBalance = tokenObjects.map { tokenObject -> TokenObject in
                    tokenObject.balance = self.getBalance(for: tokenObject, with: self.tickers())
                    return tokenObject
                }
                realm.add(tokenObjectsWithBalance, update: true)
            } else {
                realm.add(tokens, update: true)
            }
        }
    }

    func delete(tokens: [Object]) {
        try? realm.write {
            realm.delete(tokens)
        }
    }

    func deleteAll() {
        deleteAllExistingTickers()

        try? realm.write {
            realm.delete(realm.objects(TokenObject.self))
            realm.delete(realm.objects(NonFungibleTokenObject.self))
            realm.delete(realm.objects(NonFungibleTokenCategory.self))
        }
    }

    //Background update of the Realm model.
    func update(balance: BigInt, for address: Address) {
        if let tokenToUpdate = enabledObject.first(where: { $0.contract == address.description }) {
            let tokenBalance = self.getBalance(for: tokenToUpdate)

            self.realm.writeAsync(obj: tokenToUpdate) { (realm, _ ) in
                let update = self.objectToUpdate(for: (address, balance), tokenBalance: tokenBalance)
                realm.create(TokenObject.self, value: update, update: true)
            }
        }
    }

    func update(balances: [Address: BigInt]) {
        for balance in balances {
            let token = realm.object(ofType: TokenObject.self, forPrimaryKey: balance.key.description)
            let tokenBalance = self.getBalance(for: token)

            try? realm.write {
                let update = objectToUpdate(for: balance, tokenBalance: tokenBalance)
                realm.create(TokenObject.self, value: update, update: true)
            }
        }
    }

    private func objectToUpdate(for balance: (key: Address, value: BigInt), tokenBalance: Double) -> [String: Any] {
        return [
            "contract": balance.key.description,
            "value": balance.value.description,
            "balance": tokenBalance,
        ]
    }

    func update(tokens: [TokenObject], action: TokenAction) {
        try? realm.write {
            for token in tokens {
                switch action {
                case .disable(let value):
                    token.isDisabled = value
                case .updateInfo:
                    let update: [String: Any] = [
                        "contract": token.address.description,
                        "name": token.name,
                        "symbol": token.symbol,
                        "decimals": token.decimals,
                    ]
                    realm.create(TokenObject.self, value: update, update: true)
                }
            }
        }
    }

    func saveTickers(tickers: [CoinTicker]) {
        guard !tickers.isEmpty else {
            return
        }
        try? realm.write {
            realm.add(tickers, update: true)
        }
    }

    func tickers() -> [CoinTicker] {
        let coinTickers: [CoinTicker] = tickerResultsByTickersKey.map { $0 }

        guard !coinTickers.isEmpty else {
            return [CoinTicker]()
        }

        return coinTickers
    }

    private var tickerResultsByTickersKey: Results<CoinTicker> {
        return realm.objects(CoinTicker.self).filter("tickersKey == %@", CoinTickerKeyMaker.makeCurrencyKey(for: config))
    }

    func deleteAllExistingTickers() {
        try? realm.write {
            realm.delete(tickerResultsByTickersKey)
        }
    }

    static func etherToken(for config: Config = .current) -> TokenObject {
        return TokenObject(
            contract: config.server.address,
            name: config.server.name,
            symbol: config.server.symbol,
            decimals: config.server.decimals,
            value: "0",
            isCustom: false
        )
    }

    func getBalance(for token: TokenObject?) -> Double {
        return getBalance(for: token, with: self.tickers())
    }

    func getBalance(for token: TokenObject?, with tickers: [CoinTicker]) -> Double {
        guard let token = token else {
            return TokenObject.DEFAULT_BALANCE
        }

        guard let ticker = tickers.first(where: { $0.contract == token.contract }) else {
            return TokenObject.DEFAULT_BALANCE
        }

        guard let amountInBigInt = BigInt(token.value), let price = Double(ticker.price) else {
            return TokenObject.DEFAULT_BALANCE
        }

        guard let amountInDecimal = EtherNumberFormatter.full.decimal(from: amountInBigInt, decimals: token.decimals) else {
            return TokenObject.DEFAULT_BALANCE
        }

        return amountInDecimal.doubleValue * price
    }
}
