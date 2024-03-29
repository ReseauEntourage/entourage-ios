//
//  NeighborhoodV2ViewController.swift
//  entourage
//
//  Created by Clement entourage on 14/12/2023.
//

import Foundation
import UIKit
import IHProgressHUD


private enum GroupListTableDTO{
    case firstHeader
    case myGroupCell
    case secondHeader
    case discoverGroupCell(group:Neighborhood)
    case emptyCell
}

class NeighborhoodV2ViewController:UIViewController {
    
    
    //OUTLET
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_btn_create_group: UIButton!
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_tableview_top_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var ui_bottom_title_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var ui_expanded_btn: UIButton!
    @IBOutlet weak var ui_retracted_btn: UIButton!
    //VARIABLE
    private var groups = [Neighborhood]()
    private var myGroups = [Neighborhood]()
    private var tableDTO = [GroupListTableDTO]()
    private var isLoading = false
    private let nbOfItemsBeforePagingReload = 2
    private var currentPageDiscover = 0
    private var currentPageMy = 0
    private var numberOfItemsForWS = 100
    var pullRefreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        AnalyticsLoggerManager.logEvent(name: View_Group_Show)
        ui_title.text = "mainTitleGroup".localized
        ui_expanded_btn.setTitle("create_group_btn_title".localized, for: .normal) 
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_table_view.refreshControl = pullRefreshControl
        ui_table_view.delegate = self
        ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: DividerCell.identifier, bundle: nil), forCellReuseIdentifier: DividerCell.identifier)
        ui_table_view.register(UINib(nibName: HomeGroupHorizontalCollectionCell.identifier, bundle: nil), forCellReuseIdentifier: HomeGroupHorizontalCollectionCell.identifier)
        ui_table_view.register(UINib(nibName: EmptyListCell.identifier, bundle: nil), forCellReuseIdentifier: EmptyListCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadForInit()

    }
    
    @objc func refreshDatas() {
        loadForInit()
    }
    
    @IBAction func create_group(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_Group_Plus)
        let navVC = UIStoryboard.init(name: StoryboardName.neighborhoodCreate, bundle: nil).instantiateViewController(withIdentifier: "groupCreateVCMain") as! NeighborhoodCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    @IBAction func createGroupexpanded(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_Group_Plus)
        let navVC = UIStoryboard.init(name: StoryboardName.neighborhoodCreate, bundle: nil).instantiateViewController(withIdentifier: "groupCreateVCMain") as! NeighborhoodCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    
    func loadForInit(){
        isLoading = true
        IHProgressHUD.show()
        self.currentPageMy = 0
        self.currentPageDiscover = 0
        self.myGroups.removeAll()
        self.groups.removeAll()
        self.getMyGroup()
    }
    
    func getMyGroup(){
        guard let token = UserDefaults.currentUser?.uuid else { return }

        NeighborhoodService.getNeighborhoodsForUserId(token,currentPage: currentPageMy, per: numberOfItemsForWS, completion: { groups, error in
            self.pullRefreshControl.endRefreshing()
            if let groups = groups {
                self.myGroups.append(contentsOf: groups)
                self.getDiscoverGroup()
            }
        })
    }
    
    func getDiscoverGroup(){
        NeighborhoodService.getSuggestNeighborhoods(currentPage: currentPageDiscover, per: numberOfItemsForWS) { groups, error in
            self.pullRefreshControl.endRefreshing()
            if let groups = groups {
                self.groups.append(contentsOf: groups)
                self.configureDTO()
            }
        }
    }
    
    func showNeighborhood(neighborhoodId:Int, isAfterCreation:Bool = false, isShowCreatePost:Bool = false, neighborhood:Neighborhood? = nil) {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
        if let nav = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = nav.topViewController as? NeighborhoodDetailViewController {
            vc.isAfterCreation = isAfterCreation
            vc.neighborhoodId = neighborhoodId
            vc.isShowCreatePost = isShowCreatePost
            vc.neighborhood = neighborhood
            self.navigationController?.present(nav, animated: true)
        }
    }
    
    func loadForPaginationDiscover(){
        isLoading = true
        self.currentPageDiscover += 1
    }
    
    func configureDTO(){
        tableDTO.removeAll()
        if myGroups.count > 0 {
            tableDTO.append(.firstHeader)
            tableDTO.append(.myGroupCell)
        }
        if groups.count > 0 {
            tableDTO.append(.secondHeader)
            for group in groups{
                tableDTO.append(.discoverGroupCell(group: group))
            }
        }else{
            tableDTO.append(.secondHeader)
            tableDTO.append(.emptyCell)
        }
        self.ui_table_view.reloadData()
        self.pullRefreshControl.endRefreshing()
        isLoading = false
        IHProgressHUD.dismiss()
    }
    
    
}

extension NeighborhoodV2ViewController:UITableViewDelegate, UITableViewDataSource{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        DispatchQueue.main.async {
            let yOffset = self.ui_table_view.contentOffset.y
            if yOffset > 0 {
                if yOffset <= 100 {
                    // Interpolation linéaire pour ajuster la taille de la police en fonction du déplacement
                    let fontSize = 24 - (yOffset / 100) * (24 - 18)
                    self.ui_title.font = ApplicationTheme.getFontQuickSandBold(size: fontSize)
                    self.ui_tableview_top_constraint.constant = 100 - 0.4 * yOffset
                    self.ui_bottom_title_constraint.constant = 20 - 0.1 * yOffset
                    self.ui_expanded_btn.isHidden = false
                    self.ui_retracted_btn.isHidden = true
                    self.view.layoutIfNeeded()

                } else if yOffset > 100 {
                    // Réglez sur les valeurs minimales si le déplacement dépasse 100
                    self.ui_title.font = ApplicationTheme.getFontQuickSandBold(size: 18)
                    self.ui_tableview_top_constraint.constant = 60
                    self.ui_bottom_title_constraint.constant = 10
                    self.ui_expanded_btn.isHidden = true
                    self.ui_retracted_btn.isHidden = false
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row]{
        case .firstHeader:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "DividerCell") as? DividerCell{
                cell.selectionStyle = .none
                cell.configure(title: "my_group_title".localized)
                return cell
            }
        case .myGroupCell:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeGroupHorizontalCollectionCell") as? HomeGroupHorizontalCollectionCell{
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(groups: myGroups)
                return cell
            }
        case .secondHeader:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "DividerCell") as? DividerCell{
                cell.selectionStyle = .none
                cell.configure(title: "all_group_title".localized)
                return cell
            }
        case .discoverGroupCell(let group):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroup", for: indexPath) as? NeighborhoodHomeGroupCell {
                cell.selectionStyle = .none
                cell.populateCell(neighborhood: group)
                return cell
            }
            
        case .emptyCell:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "EmptyListCell") as? EmptyListCell{
                cell.selectionStyle = .none
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    //MARK: HERE HANDLE PAGINATION
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading{
            return
        }
        let lastIndex = groups.count - nbOfItemsBeforePagingReload
        if indexPath.row == lastIndex {
            self.loadForPaginationDiscover()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row]{
        case .firstHeader:
            return UITableView.automaticDimension
        case .myGroupCell:
            return 130
        case .secondHeader:
            return UITableView.automaticDimension
        case .discoverGroupCell(_):
            return UITableView.automaticDimension
        case .emptyCell:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
            
        case .firstHeader:
            return
        case .myGroupCell:
            return
        case .secondHeader:
            return
        case .discoverGroupCell(let group):
            self.showNeighborhood(neighborhoodId: group.uid)
        case .emptyCell:
            return
        }
    }
    
    
}

extension NeighborhoodV2ViewController:EventListCollectionTableViewCellDelegate{
    func paginateForMyEvent() {
        //Here paginate my group ?
    }
    
    func goToMyEvent(event: Event) {
        //DO NOTHING
    }
    
    func goToMyGroup(group: Neighborhood) {
        showNeighborhood(neighborhoodId: group.uid)
    }
    
    
}


extension NeighborhoodV2ViewController:HomeGroupCCDelegate{
    
}
