//
//  TabBarController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/22.
//  Copyright © 2018年 xhf. All rights reserved.
//

import Foundation
import TrustCore
import UIKit
import RealmSwift
import URLNavigator
import TrustWalletSDK

import BigInt
import Result
import TrustKeystore
import JSONRPCKit
import APIKit


class TabBarController: UITabBarController {
    let config: Config = .current
    var wallet:Wallet!
    var session:WalletSession!
    var tokensStorage:TokensDataStore!
    var trustNetwork:TrustNetwork!
    var transactionsStorage:TransactionsStorage!
    var ensManager: ENSManager!
    var balanceCoordinator: TokensBalanceService!
    
    let changeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "walletList")as! changeWalletViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        changeItem()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeInfo(for account: Wallet)  {
        let migration = MigrationInitializer(account: account, chainID: config.chainID)
        migration.perform()
        
        let sharedMigration = SharedMigrationInitializer()
        sharedMigration.perform()
        
        let realm = self.realm(for: migration.config)
        let sharedRealm = self.realm(for: sharedMigration.config)
        let tokensStorage = TokensDataStore(realm: realm, config: config)
        let balanceCoordinator =  TokensBalanceService()
        let trustNetwork = TrustNetwork(
            provider: TrustProviderFactory.makeProvider(),
            APIProvider: TrustProviderFactory.makeAPIProvider(),
            balanceService: balanceCoordinator,
            account: account,
            config: config
        )
        let balance =  BalanceCoordinator(account: account, config: config, storage: tokensStorage)
        let transactionsStorage = TransactionsStorage(
            realm: realm,
            account: account
        )
        let nonceProvider = GetNonceProvider(storage: transactionsStorage)
        let session = WalletSession(
            account: account,
            config: config,
            balanceCoordinator: balance,
            nonceProvider: nonceProvider
        )
        transactionsStorage.removeTransactions(for: [.failed, .unknown])
        
        keystore.recentlyUsedWallet = account
        
        self.wallet = account
        self.session = session
        self.tokensStorage = tokensStorage
        self.trustNetwork = trustNetwork
        self.transactionsStorage = transactionsStorage
        self.ensManager = ENSManager(realm: realm, config: config)
        self.balanceCoordinator = balanceCoordinator
    }
    
    func getTokensViewModel(for tokensViewController: TokensViewController) -> TokensViewModel {        
        tokensViewController.wallet = self.wallet
        tokensViewController.session = self.session
        tokensViewController.tokensStorage = self.tokensStorage
        tokensViewController.trustNetwork = self.trustNetwork
        tokensViewController.transactionsStorage = self.transactionsStorage
        return TokensViewModel(address: session.account.address, store: tokensStorage, tokensNetwork: trustNetwork)
    }
    
    func getTransactionsViewModel(for transationsViewController: TransationsViewController) -> TransactionsViewModel {
        transationsViewController.account = self.wallet
        transationsViewController.session = self.session
        return TransactionsViewModel(network: self.trustNetwork, storage: self.transactionsStorage, session: self.session)
    }
    
    func getSettingsViewModel(for settingViewController: SettingViewController) -> SettingsViewModel {
        settingViewController.wallet = self.wallet
        settingViewController.session = self.session
        settingViewController.balanceCoordinator = self.balanceCoordinator
        return SettingsViewModel(isDebug: isDebug)
    }
    
    func getSendViewData(for transferTableViewController: TransferTableViewController) {
        transferTableViewController.session = self.session
        transferTableViewController.storage = self.tokensStorage
        transferTableViewController.config = self.config
    }
    
    func addSentTransaction(_ transaction: SentTransaction) {
        let transactionsViewModel = TransactionsViewModel(network: self.trustNetwork, storage: self.transactionsStorage, session: self.session)
        transactionsViewModel.addSentTransaction(transaction)
    }
    
    func estimateGasLimit(for transferTableViewController: TransferTableViewController,completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        let addressString = session.account.address.description
        let amountString = "1"
        guard let address = Address(string: addressString) else {
            return
        }
        let parsedValue: BigInt? = {
            switch transferTableViewController.transferType! {
            case .ether, .dapp, .nft:
                return EtherNumberFormatter.full.number(from: amountString, units: .ether)
            case .token(let token):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            }
        }()
        guard let value = parsedValue else {
            return
        }
        let dataString = "0x"
        var transaction = UnconfirmedTransaction(
            transferType: transferTableViewController.transferType,
            value: value,
            to: address,
            data: Data(hex: dataString.drop0x),
            gasLimit: .none,
            gasPrice: transferTableViewController.viewModel.gasPrice,
            nonce: .none
        )
        
        if (transferTableViewController.transferMainViewController.dappTransaction != nil) {
            transaction = transferTableViewController.transferMainViewController.dappTransaction!
        }
        
        let configurator = TransactionConfigurator(
            session: session,
            account: transferTableViewController.account,
            transaction: transaction
        )
        configurator.estimateGasLimit(completion: completion)
    }
    
    private func realm(for config: Realm.Configuration) -> Realm {
        return try! Realm(configuration: config)
    }
    
    func changeItem() {
        if let items = self.tabBar.items {
            let item0 = items[0]
            item0.title = "Dapp"
            
            let item1 = items[1]
            item1.title = LanguageHelper.getString(key: "行情")
            
            let item2 = items[2]
            item2.title = LanguageHelper.getString(key: "钱包")
            
            let item3 = items[3]
            item3.title = LanguageHelper.getString(key: "交易")
            
            let item4 = items[4]
            item4.title = LanguageHelper.getString(key: "设置")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
