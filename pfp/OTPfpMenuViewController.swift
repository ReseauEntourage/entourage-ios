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
    private var menuItems = [OTMenuItem]()
    
    //MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - Private Functions
    
    private func setupUI() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.backgroundColor = UIColor.pfpTableBackground()
        tableView.separatorColor = .white
        customizeHeader()
        createMenuItems()
        tableView.register(OTItemTableViewCell.self, forCellReuseIdentifier: "ItemCellIdentifier")
        tableView.register(OTLogoutViewCell.self, forCellReuseIdentifier: "LogoutItemCellIdentifier")
    }
    
    private func customizeHeader() {
        headerView.editLabel.text = "Modifier mon profil"
        headerView.nameLabel.text = "Nom prenom"
        headerView.profileBtn.setImage(UIImage(named: "user"), for: .normal)
    }
    
    private func createMenuItems() {
        let contactItem = OTMenuItem(title: "Contacter l'équipe Voisin-Age", iconName:"contact")
        let howIsUsedItem = OTMenuItem(title: "Mode d'emploi de l'application", iconName: "howIsUsed")
        let ethicalChartItem = OTMenuItem(title: "Charte éthique de Voisin-Age", iconName: "ethicalChart")
        let logoutItem = OTMenuItem(title: "déconnexion", iconName: "")
        
        guard let item1 = contactItem,
            let item2 = howIsUsedItem,
            let item3 = ethicalChartItem,
            let item4 = logoutItem else {
            return
        }
        
        menuItems.append(item1)
        menuItems.append(item2)
        menuItems.append(item3)
        menuItems.append(item4)
    }
}

extension OTPfpMenuViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.editLabel.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
}

extension OTPfpMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != menuItems.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCellIdentifier") as! OTItemTableViewCell
            cell.view.iconImageView.image = UIImage(named: menuItems[indexPath.row].iconName)
            cell.view.itemLabel.text = menuItems[indexPath.row].title
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutItemCellIdentifier") as! OTLogoutViewCell
            cell.logoutButton.setTitle(menuItems[indexPath.row].title.capitalized, for: .normal)
            return cell
        }
    }
}
