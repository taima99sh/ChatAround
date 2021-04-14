//
//  RemarkablesViewController.swift
//  ChatAround
//
//  Created by taima on 4/13/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit

class RemarkablesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

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
}
extension RemarkablesViewController {
    func setupView(){}
    func localized(){}
    func setupData(){}
    func fetchData(){}
}
