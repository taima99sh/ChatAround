//
//  ProfileViewController.swift
//  ChatAround
//
//  Created by taima on 4/13/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDB: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnFriends: UIButton!
    @IBOutlet weak var btnRemarkables: UIButton!
    @IBOutlet weak var btnFriendRequest: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    
    var user: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        localized()
        setupData()
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnFriends(_ sender: Any) {
    }
    
    @IBAction func btnFriendRequest(_ sender: Any) {
    }
    
    @IBAction func btnRemarkables(_ sender: Any) {
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        self.showAlert(title: "", message: "Are you sure", button1action: {
            do {
                self.showIndicator()
               try Auth.auth().signOut()
                if let userID = UserProfile.shared.userID {
                    let db = Firestore.firestore()
                    let ref = db.collection("User").document(userID)
                    ref.setData( ["isOnline": false], merge: true)
             }
               UserDefaults.resetDefaults()
               let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
               AppDelegate.shared.rootNavigationViewController.setViewControllers([vc], animated: true)
               print("signOut")
            } catch let error {
               print(error.localizedDescription)
            }
        }) {
        }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
extension ProfileViewController {
    
    
    func acceptRequest() {
    }
    func setupView(){}
    func localized(){}
    func setupData(){
        guard let user = user else {return}
        self.lblName.text = user.name
        self.lblEmail.text = user.email
        self.lblDB.text = user.Db ?? ""
        self.lblGender.text = user.gender ?? ""
    }
    func fetchData(){
        let docRef = db.collection("User").document(UserProfile.shared.userID ?? "")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Result {
                    try document.data(as: UserModel.self)
                }
                switch result {
                case .success(let user):
                    if let user = user {
                        user.type = "user"
                        self.user = user
                        self.setupData()
                    } else {
                        print("Document does not exist")
                    }
                case .failure(let error):
                    print("Error decoding user: \(error)")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}
