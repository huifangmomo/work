//
//  PayAlert.swift
//  PayAlertView
//
//  Created by 余金 on 16/3/14.
//  Copyright © 2016年 fengzhi. All rights reserved.
//

import UIKit

class PayAlert: UIView,UITextFieldDelegate {
    
    var contentView:UIView?
    var completeBlock : (((String) -> Void)?)
    private var textField:UITextField!
    private var inputViewWidth:CGFloat!
    private var passCount:CGFloat!
    private var passheight:CGFloat!
    private var inputViewX:CGFloat!
    private var pwdCircleArr = [UILabel]()
    let titleLabel = UILabel()
    var linView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.passheight = 35
        self.passCount = 6
        self.inputViewWidth = 35 * passCount
        self.inputViewX = (240 - inputViewWidth) / 2.0
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        contentView =  UIView(frame: CGRect(x: 40, y: 100, width: 240, height: 150))
        contentView?.center = CGPoint(x: self.center.x, y: self.center.y/2)
        contentView!.backgroundColor = UIColor.white
        contentView?.layer.cornerRadius = 5;
        self.addSubview(contentView!)
        
        titleLabel.frame =  CGRect(x: 0, y: 0, width: contentView!.frame.size.width, height: 46)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        contentView!.addSubview(titleLabel)
        
        linView = UIView (frame: CGRect(x: 0, y: 46, width: self.frame.size.height, height: 1))
        linView.backgroundColor = UIColor.black
        linView.alpha = 0.4
        contentView?.addSubview(linView)
        
        textField = UITextField(frame: CGRect(x: 0, y: contentView!.frame.size.height - 70,  width: contentView!.frame.size.width,  height: 35))
        textField.delegate = self
        textField.isHidden = true
        textField.keyboardType = UIKeyboardType.numberPad
        contentView?.addSubview(textField!)
        
        
        let inputView:UIView = UIView(frame: CGRect(x: self.inputViewX, y: contentView!.frame.size.height - 70,  width: inputViewWidth, height: 35))
        
        inputView.layer.borderWidth = 1;
        inputView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor;
        contentView?.addSubview(inputView)
        
        let rect:CGRect = inputView.frame
        let x:CGFloat = rect.origin.x + (inputViewWidth / 12)
        let y:CGFloat = rect.origin.y + 35 / 2 - 5

        
        for i in 0...5 {
            let circleLabel:UILabel =  UILabel(frame: CGRect(x: x + 35 * CGFloat(i)-5 , y: y,  width: 10,  height: 10))
            circleLabel.backgroundColor = UIColor.black
            circleLabel.layer.cornerRadius = 5
            circleLabel.layer.masksToBounds = true
            circleLabel.isHidden = true
            contentView?.addSubview(circleLabel)
            pwdCircleArr.append(circleLabel)
            
            if i == 5 {
                continue
            }
            let line:UIView = UIView(frame: CGRect(x: rect.origin.x + (inputViewWidth / 6)*CGFloat(i + 1), y: rect.origin.y, width: 1 , height: 35))
            line.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            line.alpha = 0.4
            contentView?.addSubview(line)
        }
    }
    
    func show(view:UIView){
        view.addSubview(self)
        contentView!.transform = CGAffineTransform(scaleX: 1.21, y: 1.21)
        contentView!.alpha = 0;
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.textField.becomeFirstResponder()
            self.contentView!.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentView!.alpha = 1;
            
            }, completion: nil)
        
    }
    
    func show_2(view:UIView){
        view.addSubview(self)
        self.backgroundColor = UIColor.white
        linView.isHidden = true
        self.textField.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var password : String
        if string.count <= 0 {
            if((textField.text?.count)! == 0){
                return false
            }
            let index = (textField.text?.count)!-1
            password =  textField.text!.substring(to: index)
        }
        else {
            if((textField.text?.count)! >= 6){
                return false
            }
            password = textField.text! + string
            
        }
        self .setCircleShow(count: password.count-1)
        
        if(password.count == 6){
            completeBlock?(password)
            return false;
        }
        return true;
    }
    
    func setCircleShow(count:NSInteger){
        for circle in pwdCircleArr {
            circle.isHidden = true;
        }
        if count == -1 {
            return
        }
        for i in 0...count {
            pwdCircleArr[i].isHidden = false
        }
    }
    
    func clearPSD(){
        self.textField.text = ""
        setCircleShow(count:-1)
    }
}
