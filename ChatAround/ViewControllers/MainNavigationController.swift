//
//  MainNavigationController.swift
//  ChatAround
//
//  Created by taima on 3/24/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
extension MainNavigationController {
    func setupView(){
        AppDelegate.shared.rootNavigationViewController = self
        
        if UserProfile.shared.isUserLogin() {
            let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ViewController")
            self.setViewControllers([vc], animated: true)
            return
        }
        
        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        self.setViewControllers([vc], animated: true)
    }

}
