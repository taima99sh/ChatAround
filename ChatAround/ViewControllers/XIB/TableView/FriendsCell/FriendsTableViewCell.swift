//
//  FriendsTableViewCell.swift
//  ChatAround
//
//  Created by taima on 4/13/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    
    var object: GeneralModel?
    var index: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btnAccept(_ sender: Any) {
        guard let obj = object else {return}
        let ref = db.collection("User").document(UserProfile.shared.userID ?? "").collection("FreiendRequests").document(obj.id)
        ref.delete { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let parent = self.parentViewController as? FriendRequestsViewController {
                parent.arr.remove(at: self.index)
                parent.tableView.reloadData()
            }
        }
    }
    
    @IBAction func btnRemove(_ sender: Any) {
        guard let obj = object else {return}
        let ref = db.collection("User").document(UserProfile.shared.userID ?? "").collection("FreiendRequests").document(obj.id)
        ref.delete { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let parent = self.parentViewController as? FriendRequestsViewController {
                parent.arr.remove(at: self.index)
                parent.tableView.reloadData()
            }
        }
    }

    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell() {
        if let obj = object {
            self.lblName.text = obj.name
        }
    }
    
}
