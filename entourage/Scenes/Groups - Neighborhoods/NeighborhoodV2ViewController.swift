import Foundation
import UIKit
import IHProgressHUD
import MapKit

private enum GroupListTableDTO {
    case firstHeader
    case myGroupCell
    case secondHeader
    case discoverGroupCell(group: Neighborhood)
    case emptyCell
}

enum DisplayMode {
    case normal
    case filtered
    case searching
}

class NeighborhoodV2ViewController: UIViewController {
    
    // OUTLET
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_btn_create_group: UIButton!
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_tableview_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_bottom_title_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_expanded_btn: UIButton!
    @IBOutlet weak var ui_retracted_btn: UIButton!
    @IBOutlet weak var contraint_table_view_top: NSLayoutConstraint!
    
    @IBOutlet weak var uiBtnFilter: UIView!
    @IBOutlet weak var uiBtnSearch: UIView!
    @IBOutlet weak var ui_tv_number_filter: UILabel!
    // VARIABLES
    private var tabBarCoverView: UIView?

    
    private var allGroups = [Neighborhood]()
    private var myGroups = [Neighborhood]()
    private var filteredAllGroups = [Neighborhood]()
    private var filteredMyGroups = [Neighborhood]()
    private var searchGroups = [Neighborhood]()
    
    private var tableDTO = [GroupListTableDTO]()
    private var isLoading = false
    private let nbOfItemsBeforePagingReload = 2
    private var currentPageDiscover = 0
    private var currentPageMy = 0
    private var numberOfItemsForWS = 10
    var pullRefreshControl = UIRefreshControl()
    var numberOfFilter = 0
    var selectedItemsFilter = [String: Bool]()
    var selectedAddress: String = ""
    var selectedRadius: Float = 0
    var selectedCoordinate: CLLocationCoordinate2D?
    private var isSearching = false
    private var searchText = ""
    private var displayMode: DisplayMode = .normal
    private var startSearching = false
    private var isFromSearch = false
    
    private var filterCell: CellMainFilter?

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(onSearchClick))
        uiBtnSearch.addGestureRecognizer(searchTapGesture)

        let filterTapGesture = UITapGestureRecognizer(target: self, action: #selector(onFilterClick))
        uiBtnFilter.addGestureRecognizer(filterTapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadForInit()
    }
    
    @objc func refreshDatas() {
        loadForInit()
    }
    
    @objc func onSearchClick() {
        isSearching = true
        startSearching = true
        switchSearchMode()
    }

    @objc func onFilterClick() {
        self.showFilter()
    }

    func switchSearchMode() {
        print("nav controller ", self.navigationController)
        if isSearching {
            displayMode = .searching
            contraint_table_view_top.constant = 20
            if let tabBarController = self.tabBarController as? MainTabbarViewController {
                tabBarController.setTabBar(hidden: true, animated: true, duration: 0.3)
            }
        } else {
            if let tabBarController = self.tabBarController as? MainTabbarViewController {
                tabBarController.setTabBar(hidden: false, animated: true, duration: 0.3)
            }
            if numberOfFilter == 0 {
                displayMode = .normal
                contraint_table_view_top.constant = 100
            } else {
                displayMode = .filtered
                contraint_table_view_top.constant = 100
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.loadForInit()
        }
    }



    func configureUserLocationAndRadius() {
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
    
    func loadForInit() {
        isLoading = true
        IHProgressHUD.show()
        self.currentPageMy = 0
        self.currentPageDiscover = 0
        self.myGroups.removeAll()
        self.allGroups.removeAll()
        self.filteredMyGroups.removeAll()
        self.filteredAllGroups.removeAll()
        self.searchGroups.removeAll()
        self.getMyGroup()
    }
    
    func getMyGroup() {
        guard let token = UserDefaults.currentUser?.uuid else { return }

        switch displayMode {
        case .normal:
            NeighborhoodService.getNeighborhoodsForUserId(token, currentPage: currentPageMy, per: 50) { groups, error in
                self.pullRefreshControl.endRefreshing()
                if let groups = groups {
                    self.myGroups.append(contentsOf: groups)
                    self.getDiscoverGroup()
                }
            }
        case .filtered:
            let selectedItemsList = selectedItemsFilter.filter { $0.value }.map { $0.key }
            NeighborhoodService.getFilteredMyNeighborhoods(
                userId: token,
                currentPage: currentPageMy,
                per: 50,
                radius: self.selectedRadius,
                latitude: Float(self.selectedCoordinate?.latitude ?? 0.0),
                longitude: Float(self.selectedCoordinate?.longitude ?? 0.0),
                selectedItem: selectedItemsList
            ) { groups, error in
                self.pullRefreshControl.endRefreshing()
                if let groups = groups {
                    self.filteredMyGroups.append(contentsOf: groups)
                    self.getDiscoverGroup()
                }
            }
        case .searching:
            NeighborhoodService.searchMyNeighborhoods(userId: token, query: searchText, currentPage: currentPageMy, per: 50) { groups, error in
                self.pullRefreshControl.endRefreshing()
                if let groups = groups {
                    self.searchGroups.append(contentsOf: groups)
                    self.getDiscoverGroup()
                }
            }
        }
    }
    
    func getDiscoverGroup() {
        let selectedItemsList = selectedItemsFilter.filter { $0.value }.map { $0.key }
        
        switch displayMode {
        case .normal:
            NeighborhoodService.getSuggestNeighborhoods(currentPage: currentPageDiscover, per: numberOfItemsForWS) { groups, error in
                if let groups = groups {
                    self.allGroups.append(contentsOf: groups)
                    self.configureDTO()
                }
            }
        case .filtered:
            NeighborhoodService.getSuggestFilteredNeighborhoods(
                currentPage: currentPageDiscover,
                per: numberOfItemsForWS,
                radius: self.selectedRadius,
                latitude: Float(self.selectedCoordinate?.latitude ?? 0.0),
                longitude: Float(self.selectedCoordinate?.longitude ?? 0.0),
                selectedItem: selectedItemsList
            ) { groups, error in
                if let groups = groups {
                    self.filteredAllGroups.append(contentsOf: groups)
                    self.configureDTO()
                }
            }
        case .searching:
            NeighborhoodService.searchNeighborhoods(query: searchText, currentPage: currentPageDiscover, per: numberOfItemsForWS) { groups, error in
                if let groups = groups {
                    self.searchGroups.append(contentsOf: groups)
                    self.configureDTO()
                }
            }
        }
    }
    
    func getFilteredGroup() {
        self.tableDTO.removeAll()
        self.filteredAllGroups.removeAll()
        self.filteredMyGroups.removeAll()
        self.ui_table_view.reloadData()
        self.currentPageDiscover = 0
        self.currentPageMy = 0
        DispatchQueue.main.async {
            self.loadForInit()
        }
    }
    
    func loadForPaginationDiscover() {
        isLoading = true
        self.currentPageDiscover += 1
        getDiscoverGroup()
    }
    
    func configureDTO() {
        tableDTO.removeAll()
        if isFromSearch {
            startSearching = true
            isFromSearch = false
        }
        switch displayMode {
        case .normal:
            if myGroups.count > 0 {
                tableDTO.append(.firstHeader)
                tableDTO.append(.myGroupCell)
            }
            if allGroups.count > 0 {
                tableDTO.append(.secondHeader)
                for group in allGroups {
                    tableDTO.append(.discoverGroupCell(group: group))
                }
            } else {
                tableDTO.append(.secondHeader)
                tableDTO.append(.emptyCell)
            }
        case .filtered:
            if filteredMyGroups.count > 0 {
                tableDTO.append(.firstHeader)
                tableDTO.append(.myGroupCell)
            }
            if filteredAllGroups.count > 0 {
                tableDTO.append(.secondHeader)
                for group in filteredAllGroups {
                    tableDTO.append(.discoverGroupCell(group: group))
                }
            } else {
                tableDTO.append(.secondHeader)
                tableDTO.append(.emptyCell)
            }
        case .searching:
            if searchGroups.count > 0 {
                for group in searchGroups {
                    tableDTO.append(.discoverGroupCell(group: group))
                }
            } else {
                tableDTO.append(.emptyCell)
            }
        }
        if isSearching && startSearching {
            self.ui_table_view.reloadData()

        }else if isSearching {
            let sectionToReload = IndexSet(integer: 1)
            self.ui_table_view.reloadSections(sectionToReload, with: .automatic)
        }else {
            self.ui_table_view.reloadData()
        }
        self.pullRefreshControl.endRefreshing()
        isLoading = false
        IHProgressHUD.dismiss()
        if self.startSearching {
            self.startSearching = false
            if let filterCellIndexPath = getFilterCellIndexPath(), let filterCell = ui_table_view.cellForRow(at: filterCellIndexPath) as? CellMainFilter {
                print("eho2")
                filterCell.ui_textfield.becomeFirstResponder()
            }
        }
    }

    func showNeighborhood(neighborhoodId: Int, isAfterCreation: Bool = false, isShowCreatePost: Bool = false, neighborhood: Neighborhood? = nil) {
        if self.displayMode == .searching {
            isFromSearch = true
        }
        let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
        if let nav = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = nav.topViewController as? NeighborhoodDetailViewController {
            vc.isAfterCreation = isAfterCreation
            vc.neighborhoodId = neighborhoodId
            vc.isShowCreatePost = isShowCreatePost
            vc.neighborhood = neighborhood
            self.navigationController?.present(nav, animated: true)
        }
    }
    
    func showFilter() {
        let sb = UIStoryboard.init(name: StoryboardName.filterMain, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MainFilter") as? MainFilter {
            vc.mod = .group
            vc.delegate = self
            vc.selectedItems = self.selectedItemsFilter
            vc.selectedAdressTitle = self.selectedAddress
            vc.selectedRadius = Int(self.selectedRadius)
            vc.selectedAdress = self.selectedCoordinate
            vc.modalPresentationStyle = .fullScreen
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
}

extension NeighborhoodV2ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching && section == 0 {
            return 1
        }
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching && indexPath.section == 0 {
            if let cell = filterCell ?? tableView.dequeueReusableCell(withIdentifier: "CellMainFilter") as? CellMainFilter {
                filterCell = cell
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(selected: numberOfFilter != 0, numberOfFilter: self.numberOfFilter, mod: .group, isSearching: self.displayMode == .searching)
                
                return cell
            }
        }
        
        switch tableDTO[indexPath.row] {
        case .firstHeader:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DividerCell") as? DividerCell {
                cell.selectionStyle = .none
                cell.configure(title: "my_group_title".localized)
                return cell
            }
        case .myGroupCell:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeGroupHorizontalCollectionCell") as? HomeGroupHorizontalCollectionCell {
                cell.selectionStyle = .none
                cell.delegate = self
                switch displayMode {
                case .normal:
                    cell.configure(groups: myGroups)
                case .filtered:
                    cell.configure(groups: filteredMyGroups)
                case .searching:
                    return UITableViewCell()
                }
                return cell
            }
        case .secondHeader:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DividerCell") as? DividerCell {
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyListCell") as? EmptyListCell {
                cell.selectionStyle = .none
                cell.configureForGroup()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading {
            return
        }
        let lastIndex = (displayMode == .searching ? searchGroups.count : allGroups.count) - nbOfItemsBeforePagingReload
        if indexPath.row == lastIndex {
            self.loadForPaginationDiscover()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearching && indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        
        switch tableDTO[indexPath.row] {
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
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching && indexPath.section == 0 {
            return
        }
        
        switch tableDTO[indexPath.row] {
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if displayMode == .searching && scrollView.contentOffset.y <= 0 {
            print("eho1")

            if let filterCellIndexPath = getFilterCellIndexPath(), let filterCell = ui_table_view.cellForRow(at: filterCellIndexPath) as? CellMainFilter {
                print("eho2")
                filterCell.ui_textfield.becomeFirstResponder()
            }
        }else{
            self.view.endEditing(true)

        }
    }

    private func getFilterCellIndexPath() -> IndexPath? {
        if isSearching {
            return IndexPath(row: 0, section: 0)
        }
        return nil
    }
}

extension NeighborhoodV2ViewController: EventListCollectionTableViewCellDelegate {
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

extension NeighborhoodV2ViewController: HomeGroupCCDelegate {
    // Implement if needed
}

extension NeighborhoodV2ViewController: CellMainFilterDelegate {
    func shouldCloseSearch() {
        isSearching = false
        switchSearchMode()
    }
    
    func didUpdateText(text: String) {
        searchText = text
        self.searchGroups.removeAll()
        self.getMyGroup()  // Met à jour les données en fonction du texte de recherche
    }
    
    func didClickButton() {
        self.showFilter()
    }
}

extension NeighborhoodV2ViewController: MainFilterDelegate {
    func didUpdateFilter(selectedItems: [String: Bool], radius: Float?, coordinate: CLLocationCoordinate2D?, adressTitle: String) {
        let selectedCount = selectedItems.values.filter { $0 }.count
        print("filter ", selectedItems)
        self.numberOfFilter = selectedCount
        self.selectedItemsFilter = selectedItems
        if let _radius = radius {
            self.selectedRadius = _radius
        }
        if numberOfFilter > 0 {
            self.ui_tv_number_filter.text = String(numberOfFilter)
            self.ui_tv_number_filter.isHidden = false
        }
        else{
            self.ui_tv_number_filter.isHidden = true
        }
        self.selectedAddress = adressTitle
        self.selectedCoordinate = coordinate
        
        if selectedCoordinate?.latitude == 0 || selectedCoordinate?.longitude == 0 {
            self.configureUserLocationAndRadius()
        }
        
        if !tableDTO.isEmpty {
            tableDTO[0] = .firstHeader
        }
        
        displayMode = .filtered
        let indexPath = IndexPath(row: 0, section: 0)
        self.ui_table_view.reloadRows(at: [indexPath], with: .automatic)
        self.getFilteredGroup()
    }
}
