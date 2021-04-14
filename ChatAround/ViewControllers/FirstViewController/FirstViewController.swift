//
//  FirstViewController.swift
//  ChatAround
//
//  Created by taima on 4/7/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        localized()
        setupData()
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func btnToLogin(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        if sender.tag == 0 {
            vc.type = .user
            AppDelegate.shared.rootNavigationViewController.pushViewController(vc, animated: true)
            return
        }
        vc.type = .place
        AppDelegate.shared.rootNavigationViewController.pushViewController(vc, animated: true)
    }
}
extension FirstViewController {
    func setupView(){}
    func localized(){}
    func setupData(){}
    func fetchData(){}
}
