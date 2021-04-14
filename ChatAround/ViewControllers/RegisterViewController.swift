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
    
    enum UserType {
        case user
        case place
    }
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var setLocationView: UIView!
    
    var placeLocation: CLLocationCoordinate2D?
    
    var type: UserType = .user

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSignup(_ sender: Any) {
        switch type {
        case .user:
            createUser()
        case .place:
            createPlaceUser()
        }
    }
    
    @IBAction func btnSetLocation(_ sender: Any) {
        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "SetLocationOnMapViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatGUI()
    }
}

extension RegisterViewController {
    func updatGUI(){
        switch self.type {
        case .user:
            setLocationView.isHidden = true
        case .place:
            setLocationView.isHidden = false
        }
    }
    
    func createUser(){
        //let db = Firestore.firestore()
        let email = self.txtEmail.text ?? ""
        let password = self.txtPassword.text ?? ""
        let name = self.txtName.text ?? ""
        self.showIndicator()
        Auth.auth().createUser(withEmail: email, password: password) { (data, error) in
            self.hideIndicator()
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
    
    func createPlaceUser() {
        let email = self.txtEmail.text ?? ""
        let password = self.txtPassword.text ?? ""
        let name = self.txtName.text ?? ""
        self.showIndicator()
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            self.hideIndicator()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let authResult = authResult, let location = self.placeLocation {
                let place = UserModel(name: name, email: email, token: authResult.user.uid , geoPoint: GeoPoint(latitude: location.latitude, longitude: location.longitude), isOnline: true)
                do {
                    let userRef = db.collection("Places").document(authResult.user.uid)
                    try userRef.setData(from: place)
                    UserProfile.shared.userID = authResult.user.uid
                    UserProfile.shared.userName = place.name
                    let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    AppDelegate.shared.rootNavigationViewController.setViewControllers([vc], animated: true)
                } catch let error {
                    print("Error writing user to Firestore: \(error.localizedDescription)")
                }
            }
        }
    }
}
