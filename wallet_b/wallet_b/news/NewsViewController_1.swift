//
//  NewsViewController_1.swift
//  wallet_b
//
//  Created by xhf on 2018/7/18.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON
import SwiftFCXRefresh


///成功
typealias SuccessStringClosure = (_ result: String) -> Void
typealias SuccessJSONClosure = (_ result:JSON) -> Void
/// 失败
typealias FailClosure = (_ errorMsg: String?) -> Void

public enum NewHttp{
    case gettickers(page:Int,sort:String)
    case getnewlist(page:Int)
    case getversion(sys:String)
}

extension NewHttp:TargetType{
    //请求URL
    public var baseURL:URL{
        return URL(string:"http://118.31.66.90/wallet/frontend/web")!
    }
    //详细的路径(例如/login)
    public var path: String {
        switch self {
        case .gettickers(_):
            return "/api/gettickers"
        case .getnewlist(_):
            return "/api/getnewlist"
        case .getversion(_):
            return "/api/getversion"
        }
    }
    ///请求方式
    public var method:Moya.Method {
        switch self {
        case .gettickers(_):
            return .get
        case .getnewlist(_):
            return .get
        case .getversion(_):
            return .get
        }
    }
    ///单元测试用
    public var sampleData:Data{
        return "".data(using:.utf8)!
    }
    ///任务
    public var task: Task {
        switch self {
        case let .gettickers(page,sort):
            var params: [String: Any] = [:]
            params["page"] = page
            params["sort"] = sort
            return .requestParameters(parameters:params, encoding: URLEncoding.default)
        case let .getnewlist(page):
            return .requestParameters(parameters:["page":page], encoding: URLEncoding.default)
        case let .getversion(sys):
            return .requestParameters(parameters:["sys":sys], encoding: URLEncoding.default)
        }
    }
    ///请求头信息
    public var headers: [String : String]? {
        return nil
    }
}


class NewsViewController_1: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var str: String?
    var textLabel: UILabel!
    var showType = 0
    var mainNewViewController : NewsViewController!
    
    var listData_1 = [Dictionary<String, Any>]()
    var listData_2 = [Dictionary<String, Any>]()
    var listData = [Dictionary<String, Any>]()
    
    var imageNil:UIImageView!
    var sortStr:String!
    
    // 判断是否是上提加载
    var pageNme:Int = 1
    var headerRefreshView: FCXRefreshHeaderView?
    var footerRefreshView: FCXRefreshFooterView?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        showType = 0
        
        tableView.register(UINib(nibName: "hqCell", bundle: nil), forCellReuseIdentifier: "hqCell")
        tableView.register(UINib(nibName: "TitleBarCell", bundle: nil), forCellReuseIdentifier: "TitleBarCell")
        tableView.register(UINib(nibName: "btnTabCell", bundle: nil), forCellReuseIdentifier: "btnTabCell")
        tableView.register(UINib(nibName: "zxCell", bundle: nil), forCellReuseIdentifier: "zxCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
            self?.fetch()
        }
        
        footerRefreshView = tableView.addFCXRefreshAutoFooter { [weak self] (refreshHeader) in
            self?.loadMoreAction()
        }
        
        self.imageNil = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-70, y: self.view.frame.size.height/2-44, width: 140, height: 168))
        self.imageNil.image = UIImage(named: "alarm")
        self.view.addSubview(self.imageNil)
        self.sortStr = ""
        self.fetch()
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
    
    func fetch() {
        if self.showType==0 {
            self.requestDataWithTargetJSON(target:NewHttp.gettickers(page: self.pageNme,sort:self.sortStr), successClosure: { (json) in
                let dataArr = json["data"] as! [Dictionary<String, Any>]
                self.listData_1 = dataArr
                if dataArr.count > 0 && dataArr.count<20{
                    self.tableView.reloadData()
                    self.headerRefreshView?.endRefresh()
                    self.footerRefreshView?.resetNoMoreData()
                }else if dataArr.count == 20{
                    self.tableView.reloadData()
                    self.headerRefreshView?.endRefresh()
                }else{
                    self.headerRefreshView?.endRefresh()
                    self.footerRefreshView?.resetNoMoreData()
                }
            }) { (error) in
                print(error as Any)
            }
        }else{
            self.requestDataWithTargetJSON(target:NewHttp.getnewlist(page: 1), successClosure: { (json) in
                let dataArr = json["data"] as! [Dictionary<String, Any>]
                self.listData_2 = dataArr
                if dataArr.count >= 0 && dataArr.count<20{
                    self.tableView.reloadData()
                    self.headerRefreshView?.endRefresh()
                    self.footerRefreshView?.resetNoMoreData()
                }else if dataArr.count == 20{
                    self.tableView.reloadData()
                    self.headerRefreshView?.endRefresh()
                }else{
                    self.headerRefreshView?.endRefresh()
                    self.footerRefreshView?.resetNoMoreData()
                }
            }) { (error) in
                print(error as Any)
            }
        }
        print("结束加载数据")
    }
    
    func loadMoreAction() {
        self.pageNme = self.pageNme+1
        if self.showType==0 {
            self.requestDataWithTargetJSON(target:NewHttp.gettickers(page: self.pageNme,sort:self.sortStr), successClosure: { (json) in
                let dataArr = json["data"] as! [Dictionary<String, Any>]
                self.listData_1 = self.listData_1 + dataArr
                if dataArr.count > 0 && dataArr.count<20{
                    self.tableView.reloadData()
                    self.footerRefreshView?.endRefresh()
                    self.footerRefreshView?.resetNoMoreData()
                }else if dataArr.count == 20{
                    self.tableView.reloadData()
                    self.footerRefreshView?.endRefresh()
                }else{
                    self.footerRefreshView?.endRefresh()
                    self.footerRefreshView?.resetNoMoreData()
                }
            }) { (error) in
                print(error as Any)
            }
        }else{
            self.requestDataWithTargetJSON(target:NewHttp.getnewlist(page: self.pageNme), successClosure: { (json) in
                let dataArr = json["data"] as! [Dictionary<String, Any>]
                self.listData_2 = self.listData_2 + dataArr
                if dataArr.count > 0 && dataArr.count<20{
                    self.tableView.reloadData()
                    self.footerRefreshView?.endRefresh()
                    self.footerRefreshView?.resetNoMoreData()
                }else if dataArr.count == 20{
                    self.tableView.reloadData()
                    self.footerRefreshView?.endRefresh()
                }else{
                    self.footerRefreshView?.endRefresh()
                    self.footerRefreshView?.resetNoMoreData()
                }
            }) { (error) in
                print(error as Any)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showType==0 {
            if self.listData_1.count != 0{
                self.imageNil.isHidden = true
                return  self.listData_1.count+1
            }else{
                self.imageNil.isHidden = false
                return 0
            }
        }else{
            if self.listData_2.count != 0{
                self.imageNil.isHidden = true
                return  self.listData_2.count
            }else{
                self.imageNil.isHidden = false
                return 0
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showType==0 {
            if indexPath.row==0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "btnTabCell") as! btnTabCell
                // 5. 实现闭包,获取到传递的参数
                cell.callBackBlock { (str,str1) in
                    self.sortStr = str + str1
                    self.fetch()
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "hqCell") as! hqCell
                cell.img.isHidden = true
//                let imageUrl = URL(string: self.listData_1[indexPath.row]["title_pic"] as! String)
//                cell.img.kf.setImage(
//                    with:imageUrl
//                )
                if self.listData_1.count>0{
                    cell.name.text = (self.listData_1[indexPath.row-1]["symbol"] as! String)
                    cell.lab_1.text = "市值 " + (self.listData_1[indexPath.row-1]["market_cap"] as! String)
                    cell.lab_2.text = "¥" + String(format: "%.2f", Float(self.listData_1[indexPath.row-1]["volume_24h"] as! String)!)
                    cell.priceLab.text = "¥"+(self.listData_1[indexPath.row-1]["price"] as! String)
                    cell.zdfLab.text = (self.listData_1[indexPath.row-1]["change_1h"] as! String)+"%"
                    if Double(self.listData_1[indexPath.row-1]["change_1h"] as! String)! < 0.0 {
                        cell.bgImg.image = R.image.bg_fall()
                    }else{
                        cell.bgImg.image = R.image.bg_rise()
                    }
                }
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "zxCell") as! zxCell
            if self.listData_2.count>0{
                cell.title_1.text = (self.listData_2[indexPath.row]["title"] as! String)
                cell.title_2.text = ""
                cell.fromLab.text = (self.listData_2[indexPath.row]["author"] as! String)
                cell.timeLab.text = (self.listData_2[indexPath.row]["time"] as! String)
                let imageUrl = URL(string: self.listData_2[indexPath.row]["title_pic"] as! String)
                cell.img.kf.setImage(
                    with:imageUrl
                )
            }
            return cell
        }
    }
    
//    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int) ->CGFloat{
//        return 24
//    }
//
    func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 0.00001
    }
    
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        if showType==0 {
            if indexPath.row==0 {
                 return 34
            }else{
                return 65
            }
        }else{
             return 104
        }
       
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        print("点击"+String(indexPath.row))
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        
        if showType==0 {

        }else{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebView") as! WebViewController
            vc.title = (self.listData_2[indexPath.row]["title"] as! String)
            let url = URL(string:"http://118.31.66.90/wallet/frontend/web"+"/api/newsinfo?id="+(self.listData_2[indexPath.row]["id"] as! String))
            vc.URLString = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(str!+"viewWillAppear")
    }
    
    func upDataTableView() {
        print(str!+"upDataTableView")
        fetch()
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
