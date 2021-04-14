//
//  UIViewControllerExtension.swift
//  E-commerce App
//
//  Created by taima on 9/28/19.
//  Copyright © 2019 mac air. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages
import MBProgressHUD

func digitsCode(numOfDigits: Int) -> String {
    let arrletters = Array("0123456789")
    var code = ""
    for _ in  1...numOfDigits {
        code += String(arrletters.randomElement() ?? " ")
    }
    return code
}
extension UIViewController {
    
    
    
    
    func showAlert(title: String, message: String,button1title: String = "ok", button2title: String = "cansel",button1style: UIAlertAction.Style = .default, button2style: UIAlertAction.Style = .default, button1action: @escaping (()->Void), button2action: @escaping (()->Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let button1 = UIAlertAction.init(title: button1title, style: button1style) { (action) in
            button1action()
        }
        let button2 = UIAlertAction.init(title: button2title, style: button2style) { (action) in
            button2action()
        }
        alert.addAction(button1)
        alert.addAction(button2)
        self.present(alert, animated:true, completion: nil)
    }
    func showErrorAlert (message: String){
        showAlert(title: "Error", message: message, button1action: {
            
        }) {
            
        }
    }
    
    func SuccessMessage(title:String? , successbody:String?){
        let Successview = MessageView.viewFromNib(layout: .messageView)
        Successview.configureTheme(.success)
        Successview.configureContent(title: title!, body: successbody!)
        Successview.button?.isHidden = true
        SwiftMessages.show(view: Successview)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            SwiftMessages.hideAll()
        }
    }
    
    func ErrorMessage(title:String? , errorbody:String?){
        let Errorview = MessageView.viewFromNib(layout: .messageView)
        Errorview.configureTheme(.error)
//        Errorview.configureContent(title: "", body: errorbody, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: NSLocalizedString("Hide", comment: ""), buttonTapHandler: { _ in SwiftMessages.hide() })
        Errorview.configureContent(title: title!, body: errorbody!)
        SwiftMessages.show(view: Errorview)
        Errorview.button?.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            SwiftMessages.hideAll()
        }
    }
    
    func NoticMessage(title:String? , noticbody:String?){
        let Noticview = MessageView.viewFromNib(layout: .centeredView)
        Noticview.configureTheme(.warning)
        Noticview.configureContent(title: title, body: noticbody, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: NSLocalizedString("Hide", comment: ""), buttonTapHandler: { _ in SwiftMessages.hide() })
        SwiftMessages.show(view: Noticview)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SwiftMessages.hideAll()
        }
    }
    
    func SuccessOrderMessage(title:String? , successbody:String?){
        let SuccessRview = MessageView.viewFromNib(layout: .centeredView)
        SuccessRview.configureTheme(.success)
        SuccessRview.configureContent(title: title!, body: successbody!)
        SuccessRview.button?.isHidden = true
        SwiftMessages.show(view: SuccessRview)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            SwiftMessages.hideAll()
            //self.GoToHome()
        }
    }
    
//    func reloadButton() {
//        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
//          button.backgroundColor = .green
//          button.setTitle("Test Button", for: .normal)
//          button.addTarget(self, action: #selector(reloadAction), for: .touchUpInside)
//          self.view.addSubview(button)
//    }
//
//    @objc func reloadAction() {
//
//    }
    
    func showIndicator(withTitle title: String = "", and Description:String = "") {
       let Indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
       Indicator.label.text = title
       Indicator.isUserInteractionEnabled = false
       Indicator.detailsLabel.text = Description
       Indicator.show(animated: true)
    }
    func hideIndicator() {
       MBProgressHUD.hide(for: self.view, animated: true)
    }

    
    
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
