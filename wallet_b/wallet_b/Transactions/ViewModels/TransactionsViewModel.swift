// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import RealmSwift

struct TransactionsViewModel {
    var title: String {
        return NSLocalizedString("transactions.tabbar.item.title", value: "Transactions", comment: "")
    }

    static let titleFormmater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"//"MMM d yyyy"
        return formatter
    }()

    static let backgroundColor: UIColor = {
        return .white
    }()

    static let headerBackgroundColor: UIColor = {
        return UIColor(hex: "fafafa")
    }()

    static let headerTitleTextColor: UIColor = {
        return UIColor(hex: "555357")
    }()

    static let headerTitleFont: UIFont = {
        return UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
    }()

    static let headerBorderColor: UIColor = {
        return UIColor(hex: "e1e1e1")
    }()

    var isBuyActionAvailable: Bool {
        switch config.server {
        case .main, .kovan, .classic, .callisto, .ropsten, .rinkeby, .poa, .sokol, .custom: return false
        }
    }

    var numberOfSections: Int {
        return tokenTransactionSections.count
    }

    var hasContent: Bool {
        return !storage.transactions.isEmpty
    }

    var badgeValue: String? {
        let pendingTransactions = storage.pendingObjects
        return pendingTransactions.isEmpty ? .none : "\(pendingTransactions.count)"
    }

    private let config: Config
    private let network: TrustNetwork
    private let storage: TransactionsStorage
    private let session: WalletSession
    
    private var tokenTransactionSections: [TransactionSection] = []
    
    var showType: Int!

    init(
        network: TrustNetwork,
        storage: TransactionsStorage,
        session: WalletSession,
        config: Config = Config()
    ) {
        self.network = network
        self.storage = storage
        self.session = session
        self.config = config
    }

    func transactionsUpdateObservation(with block: @escaping () -> Void) {
        self.storage.transactionsObservation()
        self.storage.transactionsUpdateHandler = block
    }

    func invalidateTransactionsObservation() {
        self.storage.invalidateTransactionsObservation()
    }

    func numberOfItems(for section: Int) -> Int {
        return tokenTransactionSections[section].items.count
    }

    func item(for row: Int, section: Int) -> Transaction {
        return tokenTransactionSections[section].items[row]
    }

    func titleForHeader(in section: Int) -> String {
        let stringDate = tokenTransactionSections[section].title
        guard let date = TransactionsViewModel.convert(from: stringDate) else {
            return stringDate
        }

        if NSCalendar.current.isDateInToday(date) {
            return LanguageHelper.getString(key: "今天")
        }
        if NSCalendar.current.isDateInYesterday(date) {
            return LanguageHelper.getString(key: "昨天")
        }
        return stringDate
    }

//    func hederView(for section: Int) -> UIView {
//        return SectionHeader(
//            fillColor: TransactionsViewModel.headerBackgroundColor,
//            borderColor: TransactionsViewModel.headerBorderColor,
//            title: titleForHeader(in: section),
//            textColor: TransactionsViewModel.headerTitleTextColor,
//            textFont: TransactionsViewModel.headerTitleFont
//        )
//    }

    
    func cellViewModel(for indexPath: IndexPath) -> TransactionDetailsViewModel {
        return TransactionDetailsViewModel(transaction: tokenTransactionSections[indexPath.section].items[indexPath.row], config: config, chainState: session.chainState, currentWallet: session.account, currencyRate:session.balanceCoordinator.currencyRate)
    }

    func statBlock() -> Int {
        guard let transaction = storage.completedObjects.first else { return 1 }
        return transaction.blockNumber - 2000
    }

    mutating func fetch(completion: (() -> Void)? = .none) {
        fetchTransactions(completion: completion)
        fetchPending()
    }

    func fetchTransactions(completion: (() -> Void)? = .none) {
        self.network.count = -1
        self.network.transactions(for: session.account.address, startBlock: 1, page: 0, contract: nil) { result in
            guard let transactions = result.0 else { return }
            self.storage.add(transactions)
            completion?()
        }
    }

    func addSentTransaction(_ transaction: SentTransaction) {
        
        let transaction1 = SentTransaction.from(from: session.account.address, transaction: transaction)
        
        print(transaction.original.chainID)
        UserDefaults.standard.set(transaction.original.data, forKey: transaction1.id)
        UserDefaults.standard.set(transaction.original.chainID, forKey: transaction1.id+"1")

        storage.add([transaction1])
    }
    

    func fetchPending() {
        self.storage.pendingObjects.forEach { transaction in
            self.network.update(for: transaction, completion: { result in
                switch result {
                case .success(let tempResult):
                    switch tempResult.1 {
                    case .deleted:
                        self.storage.delete([tempResult.0])
                    default:
                        self.storage.update(state: tempResult.1, for: tempResult.0)
                    }
                case .failure:
                    break
                }
            })
        }
    }
    
    mutating func reGetAllTransaction() {
        self.storage.deleteAll()
        print(self.storage.transactionSections)
    }
    
    private func transactionFrom(for transaction: Transaction)->String {
        guard let operation = transaction.operation else { return transaction.from }
        return operation.from
    }
    
    private func transactionTo(for transaction: Transaction)->String {
        guard let operation = transaction.operation else { return transaction.to }
        return operation.to
    }
    
    private func direction(for transaction: Transaction)->TransactionDirection {
        if session.account.address.description == transactionTo(for: transaction) || session.account.address.description.lowercased() == transactionTo(for: transaction).lowercased() {
            return .incoming
        }
        return .outgoing
    }
    
    mutating func updateSections() {
//       self.storage.updateTransactionSection()
        tokenTransactionSections = self.storage.transactionSections
        var arrayTab: [TransactionSection] = []
        for item in tokenTransactionSections {
            var array: [Transaction] = []
            for transaction in item.items{
                switch transaction.state {
                case .error, .unknown, .failed, .deleted:
                    if self.showType == 3{
                        array.append(transaction)
                    }
                case .completed:
                    switch direction(for: transaction) {
                    case .incoming:
                        if self.showType == 2{
                            array.append(transaction)
                        }
                    case .outgoing:
                        if self.showType == 1{
                            array.append(transaction)
                        }
                    }
                case .pending:
                    print("pending")
                }
            }
            if array.count>0{
                arrayTab.append(TransactionSection(title: item.title, items: array))
            }
        }
        if self.showType==0 {
            
        }else{
            tokenTransactionSections = arrayTab
        }
    }

    static func convert(from title: String) -> Date? {
        return titleFormmater.date(from: title)
    }
}
