//
//  WebViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/17.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: CGFloat(0), y: CGFloat(1), width: UIScreen.main.bounds.width, height: 2))
        self.progressView.tintColor = UIColor.green      // 进度条颜色
        self.progressView.trackTintColor = UIColor.white // 进度条背景色
        return self.progressView
    }()
    var webView: WKWebView!
    var URLString: URL!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        self.progressView.frame.origin.y = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        self.view.addSubview(progressView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        let myURL = URLString
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
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
