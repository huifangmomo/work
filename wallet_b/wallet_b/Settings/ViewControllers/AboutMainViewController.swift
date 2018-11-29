//
//  AboutMainViewController.swift
//  wallet_b
//
//  Created by 周飙 on 2018/11/16.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

class AboutMainViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var vLab: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nowLab: UILabel!
    @IBOutlet weak var upDataBtn: UIButton!
    @IBOutlet weak var overView: UIView!
    
    
    var jsonData: Dictionary<String, String>!
    let majorVersion = Bundle.main.infoDictionary! ["CFBundleShortVersionString"] as! String
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "关于"
        self.view.backgroundColor = UIColor.white
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.vLab.text = majorVersion
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeCallback(_ sender: UIButton) {
        self.overView.isHidden = true
    }
    
    @IBAction func updataCallback(_ sender: UIButton) {
        self.overView.isHidden = true
        if sender.titleLabel?.text == "确认" {
            
        }else{
            let url = URL(string: self.jsonData["url"]!)
            UIApplication.shared.open(url!, options: ["":""], completionHandler: nil)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        if cell == nil{
            cell = UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier:"cellId")
        }
        cell!.accessoryType = .disclosureIndicator
        switch indexPath.row {
        case 0:
            cell!.textLabel?.text = "版本日志"
        case 1:
            cell!.textLabel?.text = "官网"
            cell!.detailTextLabel?.text = "mtoken.wxmolegames.com"
        case 2:
            cell!.textLabel?.text = "检测版本"
        default:
            break
        }
        return  cell!
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int) ->CGFloat{
        return 0.00001
    }
    
    func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 0.00001
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 44
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        print("点击"+String(indexPath.row))
        
        
        switch indexPath.row {
        case 0:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebView") as! WebViewController
            vc.title = "版本日志"
            let url = URL(string: "http://118.31.66.90/wallet/frontend/web/api/updatelog?sys=ios")
            vc.URLString = url
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebView") as! WebViewController
            vc.title = "官网"
            let url = URL(string: "http://mtoken.wxmolegames.com/")
            vc.URLString = url
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            
        
            self.requestDataWithTargetJSON(target:NewHttp.getversion(sys: "ios"), successClosure: { (json) in
                self.jsonData = json["data"] as! Dictionary<String, String>
                print(self.jsonData as Any)
                
                if self.majorVersion == self.jsonData["version"] {
                    self.nowLab.text = "当前为最新版本"
                    self.upDataBtn.setTitle("确认", for: .normal)
                }else{
                    self.nowLab.text = "当前版本：" + self.majorVersion
                    self.upDataBtn.setTitle("更新到" + self.jsonData["version"]!, for: .normal)
                }
                self.overView.isHidden = false
            }) { (error) in
                print(error as Any)
            }
            break
        default:
            break
        }
    }
    
    private func requestTimeoutClosure<T:TargetType>(target:T) -> MoyaProvider<T>.RequestClosure{
        let requestTimeoutClosure = { (endpoint:Endpoint<T>, done: @escaping MoyaProvider<T>.RequestResultClosure) in
            do{
                var request = try endpoint.urlRequest()
                request.timeoutInterval = 20 //设置请求超时时间
                done(.success(request))
            }catch{
                return
            }
        }
        return requestTimeoutClosure
    }
    
    func requestDataWithTargetJSON<T:TargetType>(target:T,successClosure:@escaping SuccessJSONClosure,failClosure: @escaping FailClosure) {
        let requestProvider = MoyaProvider<T>(requestClosure:requestTimeoutClosure(target: target))
        let _=requestProvider.request(target) { (result) -> () in
            switch result{
            case let .success(response):
                do {
                    let mapjson = try response.mapJSON()
                    successClosure(mapjson as! JSON)
                } catch {
                    failClosure("数据解析错误")
                }
            case let .failure(error):
                failClosure(error.errorDescription)
            }
        }
    }

}
