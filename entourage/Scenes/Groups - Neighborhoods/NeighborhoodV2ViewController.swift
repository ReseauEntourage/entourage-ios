//
//  NeighborhoodV2ViewController.swift
//  entourage
//
//  Created by Clement entourage on 14/12/2023.
//

import Foundation
import UIKit
import IHProgressHUD
import MapKit

private enum GroupListTableDTO{
    case filterCell(numberOfFilter:Int)
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
    private var numberOfItemsForWS = 10
    var pullRefreshControl = UIRefreshControl()
    var numberOfFilter = 0 
    var selectedItemsFilter = [String: Bool]()
    var selectedAddress:String = ""
    var selectedRadius:Float = 0
    var selectedCoordinate:CLLocationCoordinate2D?


    
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
        ui_table_view.register(UINib(nibName: CellMainFilter.identifier, bundle: nil), forCellReuseIdentifier: CellMainFilter.identifier)
        configureUserLocationAndRadius()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadForInit()

    }
    
    @objc func refreshDatas() {
        loadForInit()
    }
    
    func configureUserLocationAndRadius(){
        if let user = UserDefaults.currentUser {
            self.selectedRadius = Float(user.radiusDistance ?? 40)
            self.selectedCoordinate = CLLocationCoordinate2D(latitude: user.addressPrimary?.latitude ?? 0, longitude: user.addressPrimary?.longitude ?? 0)
            self.selectedAddress = user.addressPrimary?.displayAddress ?? ""
            
        }
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

        NeighborhoodService.getNeighborhoodsForUserId(token,currentPage: currentPageMy, per: 50, completion: { groups, error in
            self.pullRefreshControl.endRefreshing()
            if let groups = groups {
                self.myGroups.append(contentsOf: groups)
                self.getDiscoverGroup()
            }
        })
    }
    
    func getDiscoverGroup() {
        // Filtrer pour obtenir les clés des éléments sélectionnés (ceux qui sont à true)
        let selectedItemsList = selectedItemsFilter.filter { $0.value }.map { $0.key }
        
        NeighborhoodService.getSuggestFilteredNeighborhoods(
            currentPage: currentPageDiscover,
            per: numberOfItemsForWS,
            radius: self.selectedRadius,
            latitude: Float(self.selectedCoordinate?.latitude ?? 0.0),
            longitude: Float(self.selectedCoordinate?.longitude ?? 0.0),
            selectedItem: selectedItemsList
        ) { groups, error in
            if let groups = groups {
                self.groups.append(contentsOf: groups)
                self.configureDTO()
            }
        }
    }

    
    func getFilteredGroup(){
        self.tableDTO.removeAll()
        self.groups.removeAll()
        self.ui_table_view.reloadData()
        self.currentPageDiscover = 0
        DispatchQueue.main.async {
            self.getDiscoverGroup()
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
    
    func showFilter(){
        let sb = UIStoryboard.init(name: StoryboardName.filterMain, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MainFilter") as? MainFilter {
            vc.mod = .group
            vc.delegate = self
            vc.selectedItems = self.selectedItemsFilter
            vc.selectedAdressTitle = self.selectedAddress
            vc.selectedRadius = Int(self.selectedRadius)
            vc.selectedAdress = self.selectedCoordinate
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
    
    
    func loadForPaginationDiscover(){
        isLoading = true
        self.currentPageDiscover += 1
        getDiscoverGroup()
    }
    
    func configureDTO(){
        tableDTO.removeAll()
        tableDTO.append(.filterCell(numberOfFilter: self.numberOfFilter))
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
                cell.configureForGroup()
                return cell
            }
        case .filterCell(let numberOfFilter):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "CellMainFilter") as? CellMainFilter{
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(selected: numberOfFilter != 0, numberOfFilter: self.numberOfFilter)
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
            return 152
        case .secondHeader:
            return UITableView.automaticDimension
        case .discoverGroupCell(_):
            return UITableView.automaticDimension
        case .emptyCell:
            return 500
        case .filterCell(_):
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
        case .filterCell(_):
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

extension NeighborhoodV2ViewController:CellMainFilterDelegate{
    func didUpdateText(_ cell: CellMainFilter, text: String) {
        
    }
    
    func didClickButton(_ cell: CellMainFilter) {
        self.showFilter()
    }
}

extension NeighborhoodV2ViewController: MainFilterDelegate {
    func didUpdateFilter(selectedItems: [String: Bool], radius: Float?, coordinate: CLLocationCoordinate2D?, adressTitle:String) {
        // Compter le nombre de filtres sélectionnés (ceux qui sont à true)
        let selectedCount = selectedItems.values.filter { $0 }.count
        
        // Mettre à jour le nombre de filtres
        self.numberOfFilter = selectedCount
        self.selectedItemsFilter = selectedItems
        if let _radius = radius{
            self.selectedRadius = _radius
        }
        self.selectedAddress = adressTitle
        self.selectedCoordinate = coordinate
        
        if selectedCoordinate?.latitude == 0 || selectedCoordinate?.longitude == 0 {
            self.configureUserLocationAndRadius()
        }
        
        // Mettre à jour le premier élément de tableDTO
        if !tableDTO.isEmpty {
            tableDTO[0] = .filterCell(numberOfFilter: selectedCount)
        }
        
        // Recharger uniquement la première cellule de la table
        let indexPath = IndexPath(row: 0, section: 0)
        self.ui_table_view.reloadRows(at: [indexPath], with: .automatic)
        self.getFilteredGroup()
        
    }
}
