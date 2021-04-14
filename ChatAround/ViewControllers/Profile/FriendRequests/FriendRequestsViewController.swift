//
//  FriendRequestsViewController.swift
//  ChatAround
//
//  Created by taima on 4/13/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FriendRequestsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var arr: [GeneralModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getFriendsRequests()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
extension FriendRequestsViewController {
    func getFriendsRequests() {
        let ref = db.collection("User").document(UserProfile.shared.userID ?? "").collection(UserProfile.shared.userID ?? "")
        self.showIndicator()
        ref.getDocuments { (querySnapshot, error) in
            self.hideIndicator()
            if let error = error {
                self.ErrorMessage(title: "", errorbody: error.localizedDescription)
                return
            }
            
            if let querySnapshot = querySnapshot {
                self.arr.removeAll()
                for doc in querySnapshot.documents {
                    let result = Result {
                        try doc.data(as: GeneralModel.self)
                    }
                    switch result {
                    case .success(let obj):
                        if let obj = obj {
                            self.arr.append(obj)
                            
                        } else {
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
}

extension FriendRequestsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell")as! FriendsTableViewCell
//        cell.object = messages[indexPath.row]
//        cell.configureCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = InfoSheetViewController(nibName: "InfoSheetViewController",bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        <#code#>
//    }
}


