// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import TrustKeystore
import NVActivityIndicatorView

class WelcomeViewController: UIViewController ,NVActivityIndicatorViewable {

    var viewModel = WelcomeViewModel()
    @IBOutlet weak var backBtn: UIButton!
    
    lazy var collectionViewController: OnboardingCollectionViewController = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        let collectionViewController = OnboardingCollectionViewController(collectionViewLayout: layout)
        collectionViewController.pages = pages
        collectionViewController.pageControl = pageControl
        collectionViewController.collectionView?.isPagingEnabled = true
        collectionViewController.collectionView?.showsHorizontalScrollIndicator = false
        collectionViewController.collectionView?.backgroundColor = viewModel.backgroundColor
        return collectionViewController
    }()
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    let createWalletButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(R.image.btn_establish_1(), for: UIControlState.normal)
        button.setBackgroundImage(R.image.btn_establish_2(), for: UIControlState.highlighted)
        button.setTitle(LanguageHelper.getString(key: "create.bar.title"), for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    let importWalletButton: UIButton = {
        let importWalletButton = UIButton()
        importWalletButton.translatesAutoresizingMaskIntoConstraints = false
        importWalletButton.setBackgroundImage(R.image.btn_import_1(), for: UIControlState.normal)
        importWalletButton.setBackgroundImage(R.image.btn_import_2(), for: UIControlState.highlighted)
        importWalletButton.setTitle(LanguageHelper.getString(key: "import.bar.title"), for: UIControlState.normal)
        importWalletButton.setTitleColor(UIColor(hex: "6693ff"), for: UIControlState.normal)
        importWalletButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return importWalletButton
    }()
    let pages: [OnboardingPageViewModel] = [
        OnboardingPageViewModel(
            title: LanguageHelper.getString(key: "welcome.title1"),
            subtitle: LanguageHelper.getString(key: "welcome.description1"),
            image: R.image.icon_establish_1()!
        ),
        OnboardingPageViewModel(
            title: LanguageHelper.getString(key: "welcome.title2"),
            subtitle: LanguageHelper.getString(key: "welcome.description2"),
            image: R.image.icon_establish_2()!
        ),
        OnboardingPageViewModel(
            title: LanguageHelper.getString(key: "welcome.title3"),
            subtitle: LanguageHelper.getString(key: "welcome.description3"),
            image: R.image.icon_establish_3()!
        ),
        OnboardingPageViewModel(
            title: LanguageHelper.getString(key: "welcome.title4"),
            subtitle: LanguageHelper.getString(key: "welcome.description4"),
            image: R.image.icon_establish_4()!
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.numberOfPages = pages.count
        view.addSubview(collectionViewController.view)

        let stackView = UIStackView(arrangedSubviews: [
            pageControl,
            createWalletButton,
            importWalletButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        if self.backBtn.isHidden == true {
            self.importWalletButton.isHidden = true
            stackView.spacing = 30
        }
        view.addSubview(stackView)
        
        collectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            collectionViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: collectionViewController.view.centerYAnchor, constant: 120),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            
            pageControl.heightAnchor.constraint(equalToConstant: 35),
            pageControl.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            
            createWalletButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            createWalletButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            importWalletButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            importWalletButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            ])
        
        createWalletButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        importWalletButton.addTarget(self, action: #selector(importFlow), for: .touchUpInside)
        
        configure(viewModel: viewModel)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func configure(viewModel: WelcomeViewModel) {
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        pageControl.currentPageIndicatorTintColor = viewModel.currentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = viewModel.pageIndicatorTintColor
        pageControl.numberOfPages = viewModel.numberOfPages
        pageControl.currentPage = viewModel.currentPage
    }

    @IBAction func goBackCallback(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func start() {
        print("创建钱包")
        if self.importWalletButton.isHidden == true {
            createCallback()
        }else{
            self.performSegue(withIdentifier: "WelcomeToCreate", sender: "创建钱包")
        }
        //delegate?.didPressCreateWallet(in: self)
    }

    @IBAction func importFlow() {
        print("导入钱包")
//        let alertController = UIAlertController(title: "请选择导入钱包类型", message: "钱包类型",
//                                                preferredStyle: .actionSheet)
//        let ethAction = UIAlertAction(title: "ETH", style: .default,
//                                     handler: {
//                                        action in
//                                        self.performSegue(withIdentifier: "WelcomeToImport", sender: "ETH")
//        })
//        let btcAction = UIAlertAction(title: "BTC", style: .default,
//                                     handler: {
//                                        action in
//                                        self.performSegue(withIdentifier: "WelcomeToImport", sender: "BTC")
//        })
//
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//        alertController.addAction(ethAction)
//        alertController.addAction(btcAction)
//        alertController.addAction(cancelAction)
//        self.present(alertController, animated: true, completion: nil)
        
        self.performSegue(withIdentifier: "WelcomeToImport", sender: "BTC")

        //delegate?.didPressImportWallet(in: self)
    }
    
    func createCallback() {
        //创建钱包
        startAnimating(CGSize(width: 30, height: 30), message: "Loading...", messageFont: nil, type: NVActivityIndicatorType.lineScale)
        let keystore: Keystore = EtherKeystore.shared
        var passphrase = TLWalletPassphrase.getDecryptedWalletPassphrase()
        if keystore.hasWallets && passphrase == nil{ //有ETH钱包但是没有BTC钱包
            passphrase = TLHDWalletWrapper.generateMnemonicPassphrase()
            AppDelegate.instance().createNewBtcWallet(mnemonic: passphrase!, completion: { result  in
                    DispatchQueue.main.async {
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    }
                })
        }else{ //两个钱包都没有
            let password = PasswordGenerator.generateRandom()
            keystore.createAccount(with: password) { result in
                switch result {
                case .success(let account):
                    keystore.exportMnemonic(account: account, completion: { mnemonicResult in
                        switch mnemonicResult {
                        case .success(let words):
                            passphrase = words
                            AppDelegate.instance().createNewBtcWallet(mnemonic: passphrase!, completion: { result  in
                                DispatchQueue.main.async {
                                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                                }
                            })
                        case .failure(let error):
                            print(error)
                            DispatchQueue.main.async {
                                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                            }
                        }
                    })
                    
                    var wallets = UserDefaults.standard.dictionary(forKey: "wallets")
                    var nameIndex = UserDefaults.standard.integer(forKey: "nameIndex")
                    nameIndex = nameIndex+1
                    UserDefaults.standard.set(nameIndex, forKey: "nameIndex")
                    let name = LanguageHelper.getString(key: "以太坊钱包") + String(format: " %d",nameIndex)
                    let img = Int(arc4random()%3)+1
                    let walletInfo = ["name":name,"imgIndex":img] as [String : Any]
                    wallets![account.address.description] = walletInfo
                    UserDefaults.standard.set(wallets, forKey: "wallets")
                    self.performSegue(withIdentifier: "welcomeToCopy", sender: account)
                case .failure(let error):
                    self.alert(text: error.errorDescription!)
                }
            }
        }
    }
    
    func alert(text: String) {
        let alertController = UIAlertController(title: LanguageHelper.getString(key: "提示"),
                                                message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LanguageHelper.getString(key: "确认"), style: .default, handler: {
            action in
            
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WelcomeToImport"{
            let controller = segue.destination as! ImportViewController
            controller.itemString = (sender as? String)!
        }
        if segue.identifier == "welcomeToCopy"{
            let controller = segue.destination as! CopyViewController
            controller.account = sender as! Account
        }
    }
}
