//
//  NewsViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/18.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import PagingMenuController

//分页菜单配置
private struct PagingMenuOptions: PagingMenuControllerCustomizable {
    //第1个子视图控制器
    private let viewController1 = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "newsView_1")
        as! NewsViewController_1//NewsViewController_1()
    //第2个子视图控制器
    private let viewController2 = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "newsView_1")
        as! NewsViewController_1//NewsViewController_1()
    
    //组件类型
    fileprivate var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    
    //所有子视图控制器
    fileprivate var pagingControllers: [UIViewController] {
        viewController1.str = LanguageHelper.getString(key: "行情")
        viewController1.showType = 0
        viewController2.str = LanguageHelper.getString(key: "资讯")
        viewController2.showType = 1
        return [viewController1, viewController2]
    }
    
    //菜单配置项
    fileprivate struct MenuOptions: MenuViewCustomizable {
        //菜单显示模式
        var displayMode: MenuDisplayMode {
            return .segmentedControl
        }
        //菜单项
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItem1(), MenuItem2()]
        }
        
        var focusMode: MenuFocusMode {
            return .underline(height: 2, color: UIColor(hex: "6693ff"), horizontalPadding: 20, verticalPadding: 0)
        }
        
        var menuPosition: MenuPosition{
            return .top
        }
    }
    
    //第1个菜单项
    fileprivate struct MenuItem1: MenuItemViewCustomizable {
        //自定义菜单项名称
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: LanguageHelper.getString(key: "行情"),color: UIColor(hex: "999999"),selectedColor: UIColor(hex: "6693ff")))
        }
    }
    
    //第2个菜单项
    fileprivate struct MenuItem2: MenuItemViewCustomizable {
        //自定义菜单项名称
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: LanguageHelper.getString(key: "资讯"),color: UIColor(hex: "999999"),selectedColor: UIColor(hex: "6693ff")))
        }
    }
}


class NewsViewController: UIViewController {
    //分页菜单控制器初始化
    var pagingMenuController : PagingMenuController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "行情"
        
        //获取分页菜单配置
        let options = PagingMenuOptions()
        //设置分页菜单配置
        pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(options)
        
        //页面切换响应
        pagingMenuController.onMove = { state in
            switch state {
            case let .willMoveItem(menuItemView, previousMenuItemView):
                print("--- 标签将要切换 ---")
                print("老标签：\(previousMenuItemView.titleLabel.text!)")
                print("新标签：\(menuItemView.titleLabel.text!)")
            case let .didMoveItem(menuItemView, previousMenuItemView):
                print("--- 标签切换完毕 ---")
                print("老标签：\(previousMenuItemView.titleLabel.text!)")
                print("新标签：\(menuItemView.titleLabel.text!)")
            case let .willMoveController(menuController, previousMenuController):
                print("--- 页面将要切换 ---")
                print("老页面：\(previousMenuController)")
                print("新页面：\(menuController)")
                let vc = menuController as! NewsViewController_1
                vc.upDataTableView()
            case let .didMoveController(menuController, previousMenuController):
                print("--- 页面切换完毕 ---")
                print("老页面：\(previousMenuController)")
                print("新页面：\(menuController)")
            
            case .didScrollStart:
                print("--- 分页开始左右滑动 ---")
            case .didScrollEnd:
                print("--- 分页停止左右滑动 ---")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = LanguageHelper.getString(key: "行情")
        let pageIndex = pagingMenuController.currentPage
        let options = PagingMenuOptions()
        pagingMenuController.setup(options)
        pagingMenuController.move(toPage: pageIndex, animated: false)
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
