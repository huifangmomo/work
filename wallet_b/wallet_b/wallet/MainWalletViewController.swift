//
//  MainWalletViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/9.
//  Copyright © 2018年 xhf. All rights reserved.
//

import Foundation
import TrustCore
import UIKit
import RealmSwift
import URLNavigator
import TrustWalletSDK

class MainWalletViewController: UIViewController {
    
    // 主页导航控制器
    var mainWalletNavigationController:UINavigationController!
    
    // 主页面控制器
    var tokensViewController:TokensViewController!
    
    // 菜单页控制器
    var changeViewController:changeWalletViewController!
    
    var blurView:UIVisualEffectView!
    
    var statusBarStyle = UIStatusBarStyle.default
    
    var changViewHeight:CGFloat = 0.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return self.statusBarStyle
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        changViewHeight = 75+60*3
        
        //初始化主视图
        mainWalletNavigationController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "mainWalletNavigaiton")
            as! UINavigationController
        
        
        //首先创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .light)
        //接着创建一个承载模糊效果的视图
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.5
        //设置模糊视图的大小（全屏）
        blurView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        //添加模糊视图到页面view上（模糊视图下方都会有模糊效果）
        mainWalletNavigationController.view.addSubview(blurView)
        blurView.isHidden = true
        
        tokensViewController = mainWalletNavigationController.viewControllers.first
            as! TokensViewController
        tokensViewController.mainWalletViewController = self
        
        let height = tokensViewController.view.frame.size.height - tokensViewController.tokenTableView.frame.origin.y - (self.tabBarController?.tabBar.frame.size.height)!
        tokensViewController.tableViewHeight.constant = height

        self.view.addSubview(mainWalletNavigationController.view)
        
        changeViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "walletList")
            as! changeWalletViewController
        self.view.addSubview(changeViewController.view)
        changeViewController.view.isHidden = true;
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(handleTapGesture))
        changeViewController.touchView.addGestureRecognizer(tapGestureRecognizer)
        changeViewController.tableViewHight.constant = changViewHeight-75
        changeViewController.view.layoutIfNeeded()
        changeViewController.mainWalletViewController = self
    }
    
    private func realm(for config: Realm.Configuration) -> Realm {
        return try! Realm(configuration: config)
    }
    
    //单击手势响应
    @objc func handleTapGesture(_ tapGes : UITapGestureRecognizer) {
//        print(tapGes.location(in: view).y)
//        if tapGes.location(in: view).y<self.view.frame.height-changViewHeight {
            self.hideList()
//        }
    }
    
    func showList() {
        blurView.isHidden = false
        blurView.alpha = 0
        self.statusBarStyle = UIStatusBarStyle.lightContent
        self.setNeedsStatusBarAppearanceUpdate()
        //self.tabBarController?.tabBar.isHidden = true;
        self.changeViewController.view.center.y = self.view.frame.height/2 + changViewHeight
        self.changeViewController.balanceCoordinator = mainTabBarController.balanceCoordinator
        self.changeViewController.ensManager = mainTabBarController.ensManager
        self.changeViewController.show()
        self.changeViewController.view.isHidden = false
        doTheAnimate(mainPosition: self.view.frame.height/2,blurAlpha:0.7, mainProportion: 0.93,
                     blackCoverAlpha: 0) {
                        finished in
                        
        }
    }
    
    func hideList() {
        doTheAnimate(mainPosition: self.view.frame.height/2+changViewHeight,blurAlpha:0,mainProportion: 1,
                     blackCoverAlpha: 1) {
                        finished in
            self.changeViewController.view.isHidden = true
            self.blurView.isHidden = true
            self.statusBarStyle = UIStatusBarStyle.default
            self.setNeedsStatusBarAppearanceUpdate()
            //self.tabBarController?.tabBar.isHidden = false;
        }
    }
    
    func doTheAnimate(mainPosition: CGFloat, blurAlpha: CGFloat, mainProportion: CGFloat,
                      blackCoverAlpha: CGFloat, completion: ((Bool) -> Void)! = nil) {
        //usingSpringWithDamping：1.0表示没有弹簧震动动画
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                        self.blurView.alpha = blurAlpha
                        self.tabBarController?.tabBar.alpha = blackCoverAlpha
                        self.changeViewController.view.center.y = mainPosition
                        self.mainWalletNavigationController.view.transform =
                            CGAffineTransform.identity.scaledBy(x: mainProportion, y: mainProportion)
        }, completion: completion)
    }
    
    func changeInfo(for wallet: Wallet)  {
        mainTabBarController.changeInfo(for: wallet)
    }
    
    func upDataTokens(for wallet: Wallet) {
        hideList()
        changeInfo(for: wallet)
        tokensViewController.fetch()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WalletChange"), object: nil)
    }
    
    func toWelcome() {
        hideList()
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "WelcomeView")
        self.present(vc, animated: true, completion: nil)
//        tokensViewController.performSegue(withIdentifier: "WalletToWelcome", sender: "跳转去欢迎界面")
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

}
