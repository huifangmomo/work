//
//  AppDelegate.swift
//  wallet_b
//
//  Created by xhf on 2018/7/3.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isTouchID = false
    var blurView:UIVisualEffectView!
    let controller = UIViewController.init();
    
    
    var appWallet = TLWallet(walletName: "App Wallet", walletConfig: TLWalletConfig(isTestnet: false))

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
//        self.logUser()

        LanguageHelper.shareInstance.initUserLanguage()
        self.registerJPush(launchOptions: launchOptions)
        
        let config = UMAnalyticsConfig.sharedInstance()
        config?.appKey = "5bcd9fe0b465f54aab000149"
        config?.channelId = "App Store" //enterprise   App Store
        MobClick.start(withConfigure: config)

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        MobClick.setAppVersion(version)
    
        return true
    }
    
//    func logUser() {
//        // TODO: Use the current user's information
//        // You can call any combination of these three methods
//        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
//        Crashlytics.sharedInstance().setUserIdentifier("12345")
//        Crashlytics.sharedInstance().setUserName("Test User")
//    }
    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! (AppDelegate)
    }
    
    func showPrivateKeyReaderController(_ viewController: UIViewController, success: @escaping TLWalletUtils.SuccessWithDictionary, error: @escaping TLWalletUtils.ErrorWithString) {
//        if !isCameraAllowed() {
//            self.promptAppNotAllowedCamera()
//            return
//        }
//
//        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
//
//            if let data = data, TLCoreBitcoinWrapper.isBIP38EncryptedKey(data, isTestnet: self.appWallet.walletConfig.isTestnet) {
//                self.scannedEncryptedPrivateKey = data
//            }
//            else {
//                guard let data = data else {
//                    error("No Data")
//                    return
//                }
//                success(["privateKey": data])
//            }
//
//        }, error:{(e: String?) in
//            error(e)
//        })
//
//        viewController.present(reader, animated:true, completion:nil)
    }
    
    func showExtendedPrivateKeyReaderController(_ viewController: (UIViewController), success: @escaping (TLWalletUtils.SuccessWithString), error: @escaping (TLWalletUtils.ErrorWithString)) {
//        if (!isCameraAllowed()) {
//            promptAppNotAllowedCamera()
//            return
//        }
//        
//        let reader = TLQRCodeScannerViewController(success:{(data: String?) in
//            success(data)
//        }, error:{(e: String?) in
//            error(e)
//        })
//        
//        viewController.present(reader, animated:true, completion:nil)
    }



    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        visualEffect.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
//
//        visualEffect.alpha = 0.7
//
//        application.keyWindow?.addSubview(visualEffect)
        
       
//        var rootViewController = application.keyWindow?.rootViewController
//        rootViewController?.present(controller, animated: false, completion: nil)

        application.keyWindow?.addSubview(controller.view)
        let blurEffect = UIBlurEffect(style: .light)
        //接着创建一个承载模糊效果的视图
        self.blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.7
        //设置模糊视图的大小（全屏）
        blurView.frame.size = CGSize(width: controller.view.frame.width, height: controller.view.frame.height)
        controller.view.addSubview(blurView)
    }
    
    func registerJPush(launchOptions:[UIApplicationLaunchOptionsKey:Any]?) {
        if (UIDevice.current.systemVersion as NSString).floatValue >= 10.0 {
            let entity = JPUSHRegisterEntity()
            entity.types = 0|1|2
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate:nil)
        } else {
            JPUSHService.register(forRemoteNotificationTypes:0|1|2, categories:nil)
            
        }
        JPUSHService.setup(withOption: launchOptions, appKey: "2fcead2f0905a14f30794fa4", channel: "App Store", apsForProduction: true)
        JPUSHService.setLogOFF() //关闭日志打印
    }

    func application(_ application:UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    // 前台模式收到推送数据
    func application(_ application:UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable:Any], fetchCompletionHandler completionHandler:@escaping (UIBackgroundFetchResult) ->Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(.newData)
        let alertController = UIAlertController(title:"消息通知",message:"您有一条消息请查看", preferredStyle: .alert)
        let okAction = UIAlertAction(title:"查看", style: .default, handler: {
            action in
            print("点击了确定")
            })
        alertController.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    
    
    func application(_ application:UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable:Any]) {
        JPUSHService.handleRemoteNotification(userInfo)
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0;

        if isTouchID == true {
            isTouchID = false
            return
        }
        let psd = UserDefaults.standard.string(forKey: "passWord")
        let isdelete = UserDefaults.standard.string(forKey: "isdelete")

        if psd != nil && isdelete == nil{
            isTouchID = true
            MyFinger.userFigerprintAuthenticationTipStr(withtips:"验证指纹") { (result:MyFinger.XWCheckResult) in
                switch result{
                case .success://情况没写全，需要的自己去看，我都列出来了
                    print("用户解锁成功")
                    DispatchQueue.main.async {
                        self.controller.view.removeFromSuperview()
                    }
                    
                    break
                case .failed:
                    print("用户解锁失败")
                    break
                case .passwordNotSet , .touchidNotSet , .touchidNotAvailable , .canclePer , .inputNUm:
                    print("用户点击输入密码")
                    DispatchQueue.main.async {
                        let payAlert = PayAlert(frame: UIScreen.main.bounds)
                        payAlert.titleLabel.text = "请输入密码"
                        payAlert.show(view: self.controller.view)
                        payAlert.completeBlock = ({(password:String) -> Void in
                            print("输入的密码是:" + password)
                            if password == psd {
                                payAlert.removeFromSuperview()
                                self.controller.view.removeFromSuperview()
                            }else{
                                payAlert.clearPSD()
                                payAlert.titleLabel.text = "密码错误，请重新输入密码"
                            }
                        })
                    }
                    break
                default:
                    break
                }
            }
        }else{
            controller.view.removeFromSuperview()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

