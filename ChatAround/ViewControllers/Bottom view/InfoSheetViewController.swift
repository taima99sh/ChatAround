//
//  InfoSheetViewController.swift
//  ChatAround
//
//  Created by taima on 3/23/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit

class InfoSheetViewController: UIViewController {
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lbFollowing: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var user: UserModel?
    var fullView: CGFloat = 100
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - (searchBar.frame.maxY + 25)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(InfoSheetViewController.panGesture))
        view.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        close()
    }
    
    @IBAction func funcToChat(_ sender: Any) {
        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.user = self.user
        
        AppDelegate.shared.rootNavigationViewController.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        view.endEditing(true)
        self.tableView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            let frame = self.view.frame
            self.view.frame = CGRect(x: 0, y: self.partialView, width: frame.width, height: frame.height)
        })
    }
    
    func open(_ isFull: Bool) {
        if isFull {
            self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
            return
        }
        self.tableView.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            let frame = self.view.frame
            self.view.frame = CGRect(x: 0, y: self.topStack.frame.maxY, width: frame.width, height: frame.height)
        })

    }
    
    func setupData() {
        if let user = self.user {
            self.lblName.text = user.name
            self.lblBio.text = user.email
            open(false)
        }
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        if ( y + translation.y >= fullView) && (y + translation.y <= partialView ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.close()
                    //self.tableView.isHidden = false
                } else {
                    self.open(true)
                }
                
                }, completion: nil)
        }
    }

}

extension InfoSheetViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let parent = parent as? ViewController  else {return 0}
            return parent.users.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if let parent = parent as? ViewController {
                cell.textLabel?.text = parent.users[indexPath.row].name
            }
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let parent = parent as? ViewController  else {return}
        self.searchBar.text = parent.users[indexPath.row].name
        filter()
        searchTapped()
    }
}


extension InfoSheetViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.open(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.open(true)
        self.tableView.isHidden = false
        filter()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTapped()
    }
    
    func filter() {
        if let parent = parent as? ViewController {
//            parent.users = self.searchBar.text == nil ? parent.cUsers : parent.cUsers.filter { $0.name.contains(self.searchBar.text ?? "") }
           parent.users = parent.cUsers.filter { user in
               return user.name.hasPrefix(searchBar.text ?? "")
           }
           self.tableView.reloadData()
        }
    }
    
    func searchTapped() {
        if let parent = parent as? ViewController {
            if self.searchBar.text?.count == 0 {
                parent.users = parent.cUsers
            }
            parent.addPins()
            close()
        }
    }
}
