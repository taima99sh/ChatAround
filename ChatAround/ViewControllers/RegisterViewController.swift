//
//  RegisterViewController.swift
//  ChatAround
//
//  Created by taima on 3/24/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import MapKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtName: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        createUser()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSignup(_ sender: Any) {
        createUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
extension RegisterViewController {
    func setupData(){}
    func createUser(){
        //let db = Firestore.firestore()
        let email = self.txtEmail.text ?? ""
        let password = self.txtPassword.text ?? ""
        let name = self.txtName.text ?? ""
        Auth.auth().createUser(withEmail: email, password: password) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let authResult = data {
                
//                let currentUser = Auth.auth().currentUser
//                if let user = currentUser {
//                    let changeRequest = user.createProfileChangeRequest()
//                   changeRequest.displayName = " "
//                    changeRequest.commitChanges { error in
//                     if let error = error {
//                        print(error.localizedDescription)
//                        return
//                       // An error happened.
//                     }
//
//                   }
//                }
                //
                let user = UserModel(name: name, email: email, token: authResult.user.uid , geoPoint: GeoPoint(latitude: 0, longitude: 0), isOnline: true)
                //let userLocation = MKUserLocation.self
                do {
                    let userRef = db.collection("User").document(authResult.user.uid)
                    try userRef.setData(from: user)
                    
                    UserProfile.shared.userID = authResult.user.uid
                    UserProfile.shared.userName = user.name
                    let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    
                    AppDelegate.shared.rootNavigationViewController.setViewControllers([vc], animated: true)
                } catch let error {
                    print("Error writing user to Firestore: \(error.localizedDescription)")
                }
            }
        }
    }
}
