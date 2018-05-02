//
//  OTPfpMenuViewController.swift
//  pfp
//
//  Created by Veronica on 24/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

final class OTPfpMenuViewController: UIViewController {
    var tableView = UITableView()
    var headerView = OTMenuHeaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - private functions
    private func setupUI() {
        self.view.addSubview(tableView)
        self.view.addSubview(headerView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.tableHeaderView = headerView
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        customizeHeader()
    }
    
    //MARK: - init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func customizeHeader() {
        headerView.editLabel.text = "Modifier mon profil"
        headerView.nameLabel.text = "Nom prenom"
        headerView.nameLabel.textColor = .blue
        headerView.profileBtn.setImage(UIImage(named: "user"), for: .normal)
    }
}
