//
//  TransferMainViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/16.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import Result

extension UINavigationController {
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return visibleViewController
    }
}

class TransferMainViewController: UIViewController {
    
    var mainTransferNavigationController:UINavigationController!
    var transferTableViewController:TransferTableViewController!

    var transferConfirmViewController:TransferConfirmViewController!
    
    var blurView:UIVisualEffectView!
    
    var statusBarStyle = UIStatusBarStyle.default
    
    var paymentFlow: PaymentFlow!
    
    var dappTransaction: UnconfirmedTransaction?
    
    var prices: String?
    
    var didCompleted: ((Result<ConfirmResult, AnyError>) -> Void)?
    var tabBarVc:UITabBarController!
    
    public var toAddressValueStr:String!
    public var sendValueStr:String!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return self.statusBarStyle
    }
    
//    override var childViewControllerForStatusBarStyle: UIViewController? {
//        let currentChildViewController = childViewControllers[0]
//        return currentChildViewController
//    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        
        //初始化主视图
        mainTransferNavigationController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "TransferNavigation")
            as! UINavigationController
        self.tabBarVc?.tabBar.isHidden = true;

        
        //首先创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .light)
        //接着创建一个承载模糊效果的视图
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.5
        //设置模糊视图的大小（全屏）
        blurView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        //添加模糊视图到页面view上（模糊视图下方都会有模糊效果）
        mainTransferNavigationController.view.addSubview(blurView)
        blurView.isHidden = true
        
        transferTableViewController = mainTransferNavigationController.viewControllers.first
            as! TransferTableViewController
        transferTableViewController.transferMainViewController = self
        transferTableViewController.paymentFlow = paymentFlow
        transferTableViewController.toAddressValueStr = toAddressValueStr;
        transferTableViewController.sendValueStr = sendValueStr;
        
        self.view.addSubview(mainTransferNavigationController.view)
        
        transferConfirmViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "transferConfirm")
            as! TransferConfirmViewController
        self.view.addSubview(transferConfirmViewController.view)
        transferConfirmViewController.view.isHidden = true;
        transferConfirmViewController.transferMainViewController = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(handleTapGesture))
        transferConfirmViewController.touchView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    //单击手势响应
    @objc func handleTapGesture(_ tapGes : UITapGestureRecognizer) {
        //        print(tapGes.location(in: view).y)
        //        if tapGes.location(in: view).y<self.view.frame.height-changViewHeight {
        self.hideList()
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func showList() {
        blurView.isHidden = false
        blurView.alpha = 0
        self.statusBarStyle = UIStatusBarStyle.lightContent
        self.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = true;
        self.transferConfirmViewController.view.center.y = self.view.frame.height/2 + 420
        self.transferConfirmViewController.view.isHidden = false
        doTheAnimate(mainPosition: self.view.frame.height/2,blurAlpha:0.7, mainProportion: 0.93,
                     blackCoverAlpha: 1) {
                        finished in
                        
        }
    }
    
    func hideList() {
        doTheAnimate(mainPosition: self.view.frame.height/2+420,blurAlpha:0,mainProportion: 1,
                     blackCoverAlpha: 1) {
                        finished in
                        self.transferConfirmViewController.view.isHidden = true
                        self.blurView.isHidden = true
                        self.statusBarStyle = UIStatusBarStyle.default
                        self.setNeedsStatusBarAppearanceUpdate()
                        self.tabBarController?.tabBar.isHidden = false;
        }
    }
    
    func doTheAnimate(mainPosition: CGFloat, blurAlpha: CGFloat, mainProportion: CGFloat,
                      blackCoverAlpha: CGFloat, completion: ((Bool) -> Void)! = nil) {
        //usingSpringWithDamping：1.0表示没有弹簧震动动画
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                        self.blurView.alpha = blurAlpha
                        self.transferConfirmViewController.view.center.y = mainPosition
                        self.mainTransferNavigationController.view.transform =
                            CGAffineTransform.identity.scaledBy(x: mainProportion, y: mainProportion)
        }, completion: completion)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        view.endEditing(true)
    }
    
    func actionBack() {
        
        if (self.dappTransaction != nil){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
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
