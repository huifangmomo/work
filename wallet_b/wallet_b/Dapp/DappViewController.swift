 //
 //  DappViewController.swift
 //  wallet_b
 //
 //  Created by xhf on 2018/8/10.
 //  Copyright © 2018年 xhf. All rights reserved.
 //
 
 import Foundation
 import UIKit
 import WebKit
 import JavaScriptCore
 import Result
 import TrustKeystore
 import NVActivityIndicatorView
 
 class DappViewController: UIViewController, WKUIDelegate, WKNavigationDelegate,NVActivityIndicatorViewable {
    var webView: WKWebView!
    var URLString: URL!
    
    var account: Wallet!
    var sessionConfig: Config!
    var session:WalletSession!
    
    private var progressContext = 0
    
    private var myContext = 0
    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: CGFloat(0), y: UIScreen.main.bounds.origin.y, width: UIScreen.main.bounds.width, height: 2))
        self.progressView.tintColor = UIColor.green      // 进度条颜色
        self.progressView.trackTintColor = UIColor.white // 进度条背景色
        return self.progressView
    }()
    private struct Keys {
        static let estimatedProgress = "estimatedProgress"
        static let developerExtrasEnabled = "developerExtrasEnabled"
        static let URL = "URL"
        static let ClientName = "wallet"
    }
    
    private lazy var userClient: String = {
        return Keys.ClientName + "/" + (Bundle.main.versionNumber ?? "")
    }()
    
    //    lazy var config: WKWebViewConfiguration = {
    //        let config = WKWebViewConfiguration.make(for: account, with: sessionConfig, in: ScriptMessageProxy(delegate: self))
    //        config.websiteDataStore = WKWebsiteDataStore.default()
    //        return config
    //    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dapp"
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(loadView), name: NSNotification.Name(rawValue: "WalletChange"), object: nil)
        self.view.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.navigationController?.isNavigationBarHidden = true
        
        if #available(iOS 11.0, *) {
        } else {
            self.automaticallyAdjustsScrollViewInsets = true
            self.edgesForExtendedLayout = UIRectEdge.top
        }
        
        
//        var inputText:UITextField = UITextField();
//        let msgAlertCtr = UIAlertController.init(title: "", message: "请输入燃油费", preferredStyle: .alert)
//        let ok = UIAlertAction.init(title: "确定", style:.default) { (action:UIAlertAction) ->() in
//            let text = inputText.text!
//            let myURL = URL(string:"http://"+text);//URLString
//            let myRequest = URLRequest(url: myURL!)
//            self.webView.load(myRequest)
//        }
//        
//        let cancel = UIAlertAction.init(title: "取消", style:.cancel) { (action:UIAlertAction) -> ()in
//            print("取消输入")
//        }
//        
//        msgAlertCtr.addAction(ok)
//        msgAlertCtr.addAction(cancel)
//        //添加textField输入框
//        msgAlertCtr.addTextField { (textField) in
//            inputText = textField
//        }
//        //设置到当前视图
//        self.present(msgAlertCtr, animated: true, completion: nil)
        
    }
    
    override func loadView() {
        self.account = mainTabBarController.wallet
        self.sessionConfig = mainTabBarController.config
        //切换钱包重新注入js
        let config = WKWebViewConfiguration.make(for: account, with: sessionConfig, in: ScriptMessageProxy(delegate: self))
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        webView = WKWebView(frame:UIScreen.main.bounds, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        if !isDebug {
            webView.configuration.preferences.setValue(true, forKey: Keys.developerExtrasEnabled)
        }
        webView.allowsBackForwardNavigationGestures = false
        injectUserAgent()
        view = webView;
        //判断是否是watch账号
        if self.account.type == .address(self.account.address) {
            let btnAlert = UIButton(type: .system)
            btnAlert.frame = UIScreen.main.bounds
            btnAlert.backgroundColor = UIColor(white: 1, alpha: 1)
            btnAlert.setTitle(LanguageHelper.getString(key: "Watch用户暂未开通该功能"), for: UIControlState.normal)
            //设置点击响应事件
            btnAlert.addTarget(self, action:#selector(tapped(_:)), for:.touchUpInside)
            self.view.addSubview(btnAlert)
        }
        self.progressView.frame.origin.y = UIApplication.shared.statusBarFrame.height
        self.view.addSubview(progressView)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //  加载进度条
        if keyPath == "estimatedProgress"{
            progressView.alpha = 1.0
            progressView.setProgress(Float((self.webView?.estimatedProgress) ?? 0), animated: true)
            if (self.webView?.estimatedProgress ?? 0.0)  >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        webView.removeObserver(self, forKeyPath:"estimatedProgress")
    }
    

    
    @objc func tapped(_ button:UIButton) {
        let alertController = UIAlertController(title: LanguageHelper.getString(key: "提示"),
                                                message: LanguageHelper.getString(key: "Watch用户暂未开通该功能"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LanguageHelper.getString(key: "确定"), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLeftNavigationItem(){
        
        let goBackBtn = UIButton.init()
        //        let closeBtn = UIButton.init()
        
        goBackBtn.setImage(R.image.btn_gback_1(), for: UIControlState.normal)
        goBackBtn.setTitle("", for: UIControlState.normal)
        goBackBtn.addTarget(self, action: #selector(goBack), for: UIControlEvents.touchUpInside)
        goBackBtn.sizeToFit()
        goBackBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8)
        goBackBtn.setTitleColor(UIColor(hex: "6693ff"), for: .normal)
        let backItem = UIBarButtonItem.init(customView: goBackBtn)
        
        //        closeBtn.setTitle("关闭", for: UIControlState.normal)
        //        closeBtn.setTitleColor(UIColor(hex: "6693ff"), for: .normal)
        //        closeBtn.addTarget(self, action: #selector(popViewController), for: UIControlEvents.touchUpInside)
        //        closeBtn.sizeToFit()
        //        let closeItem = UIBarButtonItem.init(customView: closeBtn)
        
        let items:[UIBarButtonItem] = [backItem]
        self.navigationItem.leftBarButtonItems = items
    }
    
    @objc func goBack(){
        self.webView.goBack()
    }
    @objc func popViewController(){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkGoBack(){
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = !self.webView.canGoBack
        if self.webView.canGoBack{
            showLeftNavigationItem()
        }else{
            self.navigationItem.leftBarButtonItems = nil
        }
    }
    
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        if webView.url != nil {
            //startAnimating(CGSize(width: 30, height: 30), message: "Loading...", messageFont: nil, type: NVActivityIndicatorType.lineScale)
            let myRequest = URLRequest(url: webView.url!)
            webView.load(myRequest)
        }
    }
    
    private func injectUserAgent() {
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, _ in
            guard let `self` = self, let currentUserAgent = result as? String else { return }
            self.webView.customUserAgent = currentUserAgent + " " + self.userClient
        }
    }
    
    func notifyFinish(callbackID: Int, value: Result<DappCallback, DAppError>) {
        let script: String = {
            switch value {
            case .success(let result):
                print(result.value.object)
                return "executeCallback(\(callbackID), null, \"\(result.value.object)\")"
            case .failure(let error):
                print(error)
                webView.evaluateJavaScript("alert('交易失败')")
                return "executeCallback(\(callbackID), \"\(error)\", null)"
            }
        }()
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        session = mainTabBarController.session
        if webView.url != nil {
            
        }else{
           // startAnimating(CGSize(width: 30, height: 30), message: "Loading...", messageFont: nil, type: NVActivityIndicatorType.lineScale)
//            let myURL = URL(string:"http://www.g-horse.io/goldenhorse/game/ph_index.html" );//URLString
            let myURL = URL(string:"http://118.31.66.90/games/" );//URLString

            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        }
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        self.title = webView.title
        checkGoBack()
        self.navigationItem.title = webView.title
//        DispatchQueue.main.async {
//            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
//        }
        NSLog(webView.url!.absoluteString)
        if webView.url!.absoluteString.contains("http://118.31.66.90/games/"){
            print("不注")
            setTabBarVisible(visible: true,animated: true)
        }else{
            print("注")
            setTabBarVisible(visible: false,animated: true)
            var js = ""
            
            let bundlePath = Bundle.main.path(forResource: "dappUse", ofType: "bundle")
            let bundle = Bundle(path: bundlePath!)
            
            let filepath = bundle!.path(forResource: "drag", ofType: "js")
            do {
                js += try String(contentsOfFile: filepath!)
            } catch { }
            
            //webView.evaluateJavaScript("alert(1222)")
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        let strRequest = navigationAction.request.url?.absoluteString
        if strRequest!.contains("mqqwpa://im/chat?"){
            decisionHandler(.cancel)
            UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
        }else{
            decisionHandler(.allow)
        }
    }
  
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        if (tabBarIsVisible() == visible) {
            return
        }
        mainTabBarController.tabBar.isHidden = !visible
        var frame = UIScreen.main.bounds
        if mainTabBarController.tabBar.isHidden == true{
            if #available(iOS 11.0, *) {
                frame.size.height += (mainTabBarController.tabBar.frame.size.height)
            } else {

            }

        }else{
            if #available(iOS 11.0, *) {
                
            } else {
                frame.size.height -= mainTabBarController.tabBar.frame.size.height
            }
            
        }
        self.webView.frame = frame

    }
    
    func tabBarIsVisible() ->Bool {
        return !mainTabBarController.tabBar.isHidden
    }

    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        checkGoBack()
//        DispatchQueue.main.async {
//            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
//        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            self.webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: .none,
                                                message: message, preferredStyle: .alert)
        //        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: LanguageHelper.getString(key: "确定"), style: .default, handler: {
            action in
            completionHandler()
        })
        //        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: .none,
                                                message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LanguageHelper.getString(key: "确定"), style: .default, handler: {
            action in
            completionHandler(true)
        })
        let cancelAction = UIAlertAction(title: LanguageHelper.getString(key: "取消"), style: .default, handler: {
            action in
            completionHandler(false)
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: .none,
                                                message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        let okAction = UIAlertAction(title: LanguageHelper.getString(key: "确定"), style: .default, handler: {
            action in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        })
        let cancelAction = UIAlertAction(title: LanguageHelper.getString(key: "取消"), style: .default, handler: {
            action in
            completionHandler(nil)
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didCall(action: DappAction, callbackID: Int) {
        print(action)
        switch session.account.type {
        case .privateKey(let account), .hd(let account) :
            switch action {
            case .signTransaction(let unconfirmedTransaction):
                executeTransaction(account: account, action: action, callbackID: callbackID, transaction: unconfirmedTransaction, type: .signThenSend)
            case .sendTransaction(let unconfirmedTransaction):
                executeTransaction(account: account, action: action, callbackID: callbackID, transaction: unconfirmedTransaction, type: .signThenSend)
            case .signMessage(let hexMessage):
                signMessage(with: .message(Data(hex: hexMessage)), account: account, callbackID: callbackID)
            case .signPersonalMessage(let hexMessage):
                signMessage(with: .personalMessage(Data(hex: hexMessage)), account: account, callbackID: callbackID)
            case .signTypedMessage(let typedData):
                signMessage(with: .typedMessage(typedData), account: account, callbackID: callbackID)
            case .unknown:
                break
            }
        case .address:
            self.notifyFinish(callbackID: callbackID, value: .failure(DAppError.cancelled))
            //            self.navigationController.displayError(error: InCoordinatorError.onlyWatchAccount)
        }
    }
    
    private func executeTransaction(account: Account, action: DappAction, callbackID: Int, transaction: UnconfirmedTransaction, type: ConfirmType) {
//        let configurator = TransactionConfigurator(
//            session: session,
//            account: account,
//            transaction: transaction
//        )
        
        let transferMainController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "transferMain") as! TransferMainViewController
        
        transferMainController.paymentFlow = .send(type: transaction.transferType)
        transferMainController.dappTransaction = transaction
        
        //        let coordinator = ConfirmCoordinator(
        //            navigationController: NavigationController(),
        //            session: session,
        //            configurator: configurator,
        //            keystore: keystore,
        //            account: account,
        //            type: type
        //        )
        //        addCoordinator(coordinator)
        transferMainController.didCompleted = { [unowned self] result in
            switch result {
            case .success(let type):
                switch type {
                case .signedTransaction(let transaction):
                    // on signing we pass signed hex of the transaction
                    let callback = DappCallback(id: callbackID, value: .signTransaction(transaction.data))
                    self.notifyFinish(callbackID: callbackID, value: .success(callback))
                    mainTabBarController.addSentTransaction(transaction)
                case .sentTransaction(let transaction):
                    // on send transaction we pass transaction ID only.
                    let data = Data(hex: transaction.id)
                    let callback = DappCallback(id: callbackID, value: .sentTransaction(data))
                    self.notifyFinish(callbackID: callbackID, value: .success(callback))
                    mainTabBarController.addSentTransaction(transaction)
                }
            case .failure:
                self.notifyFinish(
                    callbackID: callbackID,
                    value: .failure(DAppError.cancelled)
                )
            }
            //            self.removeCoordinator(coordinator)
            self.dismiss(animated: true, completion: nil)
        }
        //        coordinator.start()
        self.present(transferMainController, animated: true, completion: nil)
    }
    
    func signMessage(with type: SignMesageType, account: Account, callbackID: Int) {
        let coordinator = SignMessageCoordinator(
            navigationController: self,
            keystore: keystore,
            account: account
        )
        coordinator.didComplete = { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                let callback: DappCallback
                switch type {
                case .message:
                    callback = DappCallback(id: callbackID, value: .signMessage(data))
                case .personalMessage:
                    callback = DappCallback(id: callbackID, value: .signPersonalMessage(data))
                case .typedMessage:
                    callback = DappCallback(id: callbackID, value: .signTypedMessage(data))
                }
                self.notifyFinish(callbackID: callbackID, value: .success(callback))
            case .failure:
                self.notifyFinish(callbackID: callbackID, value: .failure(DAppError.cancelled))
            }
            //            self.removeCoordinator(coordinator)
        }
        //        coordinator.delegate = self
        //        addCoordinator(coordinator)
        coordinator.start(with: type)
    }
 }
 
 extension DappViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let command = DappAction.fromMessage(message) else { return }
        let requester = DAppRequester(title: webView.title, url: webView.url)
        let action = DappAction.fromCommand(command, requester: requester)
        
        self.didCall(action: action, callbackID: command.id)
    }
 }
 
