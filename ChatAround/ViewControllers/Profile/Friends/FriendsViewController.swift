//
//  FriendsViewController.swift
//  ChatAround
//
//  Created by taima on 4/13/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FriendsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dicArr: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
extension FriendsViewController {

    func fetchData(){
        let ref = db.collection("User").document(UserProfile.shared.userID ?? "").collection("Remarkables")
        self.showIndicator()
        ref.getDocuments { (querySnapshot, error) in
            self.hideIndicator()
            if let error = error {
                self.ErrorMessage(title: "", errorbody: error.localizedDescription)
                return
            }
            if let querySnapshot = querySnapshot {
                for doc in querySnapshot.documents {
                    print(doc.data())
                    self.dicArr.append(doc.data())
                }
                self.tableView.reloadData()
            }
        }
    }
}
