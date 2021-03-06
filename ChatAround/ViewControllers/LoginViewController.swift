//
//  LoginViewController.swift
//  ChatAround
//
//  Created by taima on 3/24/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        login()
    }
    
    @IBAction func btnToRegister(_ sender: Any) {
        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController {
    func login(){
        let email = self.txtEmail.text ?? ""
        let password = self.txtPassword.text ?? ""
        self.showIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let authResult = authResult {
                UserProfile.shared.userID = authResult.user.uid
                UserProfile.shared.userName = authResult.user.displayName
                let ref = db.collection("User").document(UserProfile.shared.userID ?? "")
                //ref.setData( ["isOnline": true], merge: true)
                ref.updateData(["isOnline": true])
                self.getUserInfo(ref)
                let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                AppDelegate.shared.rootNavigationViewController.setViewControllers([vc], animated: true)
            }
        }
    }
    
    func getUserInfo(_ ref: DocumentReference) {
        ref.getDocument { (doc, error) in
            self.hideIndicator()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let doc = doc {
                let result = Result {
                    try doc.data(as: UserModel.self)
                }
                switch result {
                    
                case .success(let user):
                    guard let user = user else {return}
                    UserProfile.shared.userName = user.name
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
