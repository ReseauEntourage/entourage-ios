//
//  NeighborhoodHomeViewController.swift
//  entourage
//
//  Created by Jerome on 21/04/2022.
//

import UIKit
import IHProgressHUD
import IQKeyboardManagerSwift

class NeighborhoodHomeViewController: UIViewController {
    
    @IBOutlet weak var ui_view_selector: UIView!
    @IBOutlet weak var ui_image_inside_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_image_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    
    @IBOutlet weak var ui_constraint_bottom_label: NSLayoutConstraint!
    
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_label_groups: UILabel!
    @IBOutlet weak var ui_view_indicator_groups: UIView!
    @IBOutlet weak var ui_label_discover: UILabel!
    @IBOutlet weak var ui_view_indicator_discover: UIView!
    
    //Views empty
    @IBOutlet weak var ui_view_empty: UIView!
    //GRoup
    @IBOutlet weak var ui_view_empty_groups: UIView!
    @IBOutlet weak var ui_bt_empty_group: UIButton!
    @IBOutlet weak var ui_lbl_empty_group: UILabel!
    //Search
    @IBOutlet weak var ui_view_empty_search: UIView!
    @IBOutlet weak var ui_lbl_empty_title_search: UILabel!
    @IBOutlet weak var ui_lbl_empty_subtitle_search: UILabel!
    
    @IBOutlet weak var ui_arrow_show_empty: UIImageView!
    @IBOutlet weak var ui_view_empty_discover: UIView!
    @IBOutlet weak var ui_lbl_empty_title_discover: UILabel!
    @IBOutlet weak var ui_lbl_empty_subtitle_discover: UILabel!
    
    var maxViewHeight:CGFloat = 134
    var minViewHeight:CGFloat = 92//108
    
    var minLabelBottomConstraint:CGFloat = 9
    var maxLabelBottomConstraint:CGFloat = 20
    
    var minLabelFont:CGFloat = 16//18
    var maxLabelFont:CGFloat = 23
    
    var minImageHeight:CGFloat = 0
    var maxImageHeight:CGFloat = 73
    
    var viewNormalHeight:CGFloat = 0
    var labelNormalConstraintBottom:CGFloat = 0
    var labelNormalFontHeight:CGFloat = 0
    var imageNormalHeight:CGFloat = 0
    
    var topSafeAreaInsets:CGFloat = 0
    
    var myNeighborhoods = [Neighborhood]()
    var neighborhoodsDiscovered = [Neighborhood]()
    var neighborhoodsSearch = [Neighborhood]()
    var isSearch = false
    var isAlreadyClearRows = false //Use to prevent reload tableview when click on close searchview
    
    private var isGroupsSelected = false//true
    private var currentSelectedIsGroup = true//false // Use to prevent reloading tabs on view appears + Tap selection bar
    private var isfirstLoadingMyGroup = true
    
    var isLoading = false
    var isSendedSearch = false // Use to show empty search view only if we start search ;)
    
    var currentPageMy = 1
    var currentPageDiscover = 1
    let numberOfItemsForWS = 20 // Arbitrary nb of items used for pagging
    let nbOfItemsBeforePagingReload = 5 // Arbitrary nb of items from the end of the list to send new call
    
    var pullRefreshControl = UIRefreshControl()
    
    //MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        
        setupEmptyViews()
        
        setupViews()
        
        //Notif for updating when create new neighborhood
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationNeighborhoodCreateEnd), object: nil)
        
        //Notif for updating neighborhood infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
        
        //Notif for show new created group
        NotificationCenter.default.addObserver(self, selector: #selector(showNewNeighborhood(_:)), name: NSNotification.Name(rawValue: kNotificationNeighborhoodShowNew), object: nil)
        
        //Notif for show create new post for newly created group
        NotificationCenter.default.addObserver(self, selector: #selector(showCreatePostNewNeighborhood(_:)), name: NSNotification.Name(rawValue: kNotificationCreatePostNewNeighborhood), object: nil)
        
        //Notif for updating neighborhoods after tabbar selected
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatasFromTab), name: NSNotification.Name(rawValue: kNotificationNeighborhoodsUpdate), object: nil)
        getUserInfo()
    }
    
    @objc func showNewNeighborhood(_ notification:Notification) {
        if let neighId = notification.userInfo?["neighborhoodId"] as? Int {
            self.showNeighborhood(neighborhoodId: neighId, isAfterCreation:true)
        }
    }
    
    @objc func showCreatePostNewNeighborhood(_ notification:Notification) {
        if let neighId = notification.userInfo?["neighborhoodId"] as? Int {
            self.showNeighborhood(neighborhoodId: neighId, isAfterCreation:true, isShowCreatePost:true)
        }
    }
    
    @objc func refreshDatasFromTab() {
        currentPageMy = 1
        currentPageDiscover = 1
        isSearch = false
        
        if isGroupsSelected {
            currentSelectedIsGroup = true
            if self.myNeighborhoods.count > 0 {
                self.gotoTop(isAnimated:false)
            }
            getNeighborhoods(reloadOther:true)
        }
        else {
            currentSelectedIsGroup = false
            if self.neighborhoodsDiscovered.count > 0 {
                self.gotoTop(isAnimated:false)
            }
            getNeighborhoodsSuggestions(reloadOther:true)
        }
        getUserInfo()
    }
    
    @objc func refreshDatas() {
        updateFromCreate()
        getUserInfo()
    }
    
    @objc func updateFromCreate() {
        if isGroupsSelected {
            currentPageMy = 1
            currentSelectedIsGroup = true
            getNeighborhoods()
        }
        else {
            currentPageDiscover = 1
            currentSelectedIsGroup = false
            getNeighborhoodsSuggestions()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isGroupsSelected {
            if !currentSelectedIsGroup {
                currentSelectedIsGroup = true
                getNeighborhoods()
            }
        }
        else if currentSelectedIsGroup {
            currentSelectedIsGroup = false
            getNeighborhoodsSuggestions()
        }
        changeTabSelection()
        //Analytics
        if isGroupsSelected {
            AnalyticsLoggerManager.logEvent(name: View_Group_Show)
        }
        else {
            AnalyticsLoggerManager.logEvent(name: View_Group_ShowDiscover)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Use to change tab selection from other place
    func setDiscoverFirst() {
        self.isGroupsSelected = false
        self.currentSelectedIsGroup = true
    }
    //Use to change tab selection from other place
    func setMyFirst() {
        self.isGroupsSelected = true
        self.currentSelectedIsGroup = false
    }
    
    //MARK: - Network -
    func getNeighborhoods(isReloadFromTab:Bool = false, reloadOther:Bool = false) {
        if self.isLoading { return }
        
        guard let token = UserDefaults.currentUser?.uuid else { return }
        if self.myNeighborhoods.isEmpty { self.ui_tableview.reloadData() }
        
        if !isReloadFromTab {
            IHProgressHUD.show()
        }
            
        self.isSearch = false
        self.isLoading = true
        NeighborhoodService.getNeighborhoodsForUserId(token,currentPage: currentPageMy, per: numberOfItemsForWS, completion: { groups, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            self.isfirstLoadingMyGroup = false
            if let groups = groups {
                if self.currentPageMy > 1 {
                    self.myNeighborhoods.append(contentsOf: groups)
                }
                else {
                    self.myNeighborhoods = groups
                }
                if !isReloadFromTab {
                    self.ui_tableview.reloadData()
                    if self.myNeighborhoods.count > 0 && self.currentPageMy == 1 {
                        self.gotoTop()
                    }
                }
            }
            if !isReloadFromTab {
                if self.myNeighborhoods.count == 0 {
                    self.showEmptyView()
                }
                else {
                    self.hideEmptyView()
                }
                
                self.ui_tableview.reloadData()
            }
            self.isLoading = false
            if reloadOther {
                self.getNeighborhoodsSuggestions(isReloadFromTab: true)
            }
        })
    }
    
    func getNeighborhoodsSuggestions(isReloadFromTab:Bool = false, reloadOther:Bool = false) {
        if self.isLoading { return }
        
        if !isReloadFromTab {
            IHProgressHUD.show()
        }
        
        self.isSearch = false
        self.isLoading = true
        NeighborhoodService.getSuggestNeighborhoods(currentPage: currentPageDiscover, per: numberOfItemsForWS) { groups, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            if let groups = groups {
                if self.currentPageDiscover > 1 {
                    self.neighborhoodsDiscovered.append(contentsOf: groups)
                }
                else {
                    self.neighborhoodsDiscovered = groups
                }
                // self.ui_tableview.reloadData()
                if self.neighborhoodsDiscovered.count > 0 && self.currentPageDiscover == 1 && !isReloadFromTab {
                    self.gotoTop()
                }
                
            }
            if !isReloadFromTab {
                if self.neighborhoodsDiscovered.count == 0 {
                    self.showEmptyView()
                }
                else {
                    self.hideEmptyView()
                }
                self.ui_tableview.reloadData()
            }
            self.isLoading = false
            if reloadOther {
                self.getNeighborhoods(isReloadFromTab: true)
            }
        }
    }
    
    func getNeighborhoodsSearch(text:String) {
        if self.isLoading { return }
        IHProgressHUD.show()
        
        self.neighborhoodsSearch.removeAll()
        self.ui_tableview.reloadData()
        
        isAlreadyClearRows = false
        self.isLoading = true
        let encodedString = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        NeighborhoodService.getSearchNeighborhoods(text: encodedString, completion: { groups, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            self.isSearch = true
            self.isLoading = false
            self.isSendedSearch = true
            if let groups = groups {
                self.neighborhoodsSearch = groups
                self.ui_tableview.reloadData()
                self.gotoTop()
            }
            
            if self.neighborhoodsSearch.count == 0 {
                self.showEmptyView()
            }
            else {
                self.hideEmptyView()
            }
            self.ui_tableview.reloadData()
        })
    }
    
    func getUserInfo() {
        guard let _userid = UserDefaults.currentUser?.uuid else {return}
        UserService.getUnreadCountForUser { unreadCount, error in
            if let unreadCount = unreadCount {
                UserDefaults.badgeCount = unreadCount
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdateCount), object: nil)
            }
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_myGroups(_ sender: Any?) {
        isGroupsSelected = true
        isfirstLoadingMyGroup = true
        
        //Analytics
        if isGroupsSelected != currentSelectedIsGroup {
            AnalyticsLoggerManager.logEvent(name: Action_Group_MyGroup)
        }
        
        if isGroupsSelected != currentSelectedIsGroup && myNeighborhoods.count == 0 {
            currentPageMy = 1
            myNeighborhoods.removeAll()
            getNeighborhoods()
        }
        currentSelectedIsGroup = true
        isSendedSearch = false
        if neighborhoodsSearch.count == 0 {
            isSearch = false
        }
        isLoading = false
        changeTabSelection()
        if self.myNeighborhoods.count > 0 {
            self.gotoTop()
        }
    }
    
    @IBAction func action_discover(_ sender: Any?) {
        isGroupsSelected = false
        
        //Analytics
        if isGroupsSelected != currentSelectedIsGroup {
            AnalyticsLoggerManager.logEvent(name: Action_Group_Discover)
        }
        
        if isGroupsSelected != currentSelectedIsGroup && self.neighborhoodsDiscovered.count == 0 {
            currentPageDiscover = 1
            self.neighborhoodsDiscovered.removeAll()
            getNeighborhoodsSuggestions()
        }
        isSendedSearch = false
        currentSelectedIsGroup = false
        isLoading = false
        changeTabSelection()
        if self.neighborhoodsDiscovered.count > 0 {
            self.gotoTop()
        }
    }
    
    @IBAction func action_create_group(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_Group_Plus)
        let navVC = UIStoryboard.init(name: StoryboardName.neighborhoodCreate, bundle: nil).instantiateViewController(withIdentifier: "groupCreateVCMain") as! NeighborhoodCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    @IBAction func action_show_suggestions(_ sender: Any) {
        self.action_discover(sender)
    }
    
    //MARK: - Methods -
    func changeTabSelection() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        self.ui_view_empty_groups.isHidden = true
        self.ui_view_empty_search.isHidden = true
        self.ui_view_empty_discover.isHidden = true
        
        if isGroupsSelected {
            ui_label_groups.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_label_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOff())
            
            ui_view_indicator_groups.isHidden = false
            ui_view_indicator_discover.isHidden = true
        }
        else {
            ui_label_groups.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOff())
            
            ui_label_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_view_indicator_groups.isHidden = true
            ui_view_indicator_discover.isHidden = false
        }
        self.ui_tableview.reloadData()
    }
    
    func gotoTop(isAnimated:Bool = true) {
        if isGroupsSelected && myNeighborhoods.count == 0 { return }
        else if neighborhoodsDiscovered.count == 0 { return }
        
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
        }
    }
    
    func setupViews() {
        ui_label_title.text = "neighborhood_main_page_title".localized
        ui_label_groups.text = "neighborhood_main_page_button_myGroups".localized
        ui_label_discover.text = "neighborhood_main_page_button_discover".localized
        
        ui_view_selector.addRadiusTopOnly(radius: ApplicationTheme.bigCornerRadius)
        
        maxImageHeight = ui_image_constraint_height.constant
        imageNormalHeight = maxImageHeight
        
        ui_label_title.font = UIFont.systemFont(ofSize: maxLabelFont)
        labelNormalFontHeight = maxLabelFont
        
        ui_constraint_bottom_label.constant = maxLabelBottomConstraint
        labelNormalConstraintBottom = ui_constraint_bottom_label.constant
        
        ui_view_height_constraint.constant = maxViewHeight
        viewNormalHeight = ui_view_height_constraint.constant
        
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            if let topPadding = window?.safeAreaInsets.top {
                topSafeAreaInsets = topPadding
            }
        }
        else {
            let window = UIApplication.shared.keyWindow
            if let topPadding = window?.safeAreaInsets.top {
                topSafeAreaInsets = topPadding
            }
        }
        
        ui_image_inside_top_constraint.constant = ui_image_inside_top_constraint.constant - topSafeAreaInsets
        
        ui_tableview.contentInset = UIEdgeInsets(top: viewNormalHeight ,left: 0,bottom: 0,right: 0)
        ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: viewNormalHeight ,left: 0,bottom: 0,right: 0)
        
        changeTabSelection()
        
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
    }
    
    func setupEmptyViews() {
        ui_bt_empty_group.titleLabel?.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_bt_empty_group.layer.cornerRadius = ui_bt_empty_group.frame.height / 2
        ui_bt_empty_group.backgroundColor = .appOrange
        
        ui_lbl_empty_group.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_lbl_empty_title_search.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        
        ui_lbl_empty_subtitle_search.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_lbl_empty_title_discover.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        
        ui_lbl_empty_subtitle_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_bt_empty_group.setTitle("neighborhood_group_my_empty_button".localized, for: .normal)
        ui_lbl_empty_group.text = "neighborhood_group_my_empty_title".localized
        
        ui_lbl_empty_title_search.text = "neighborhood_group_search_empty_title".localized
        ui_lbl_empty_subtitle_search.text = "neighborhood_group_search_empty_subtitle".localized
        
        ui_lbl_empty_title_discover.text = "neighborhood_group_discover_empty_title".localized
        ui_lbl_empty_subtitle_discover.text = "neighborhood_group_discover_empty_subtitle".localized
        
        hideEmptyView()
    }
    
    func showEmptyView() {
        if isGroupsSelected {
            self.ui_view_empty.isHidden = false
            ui_arrow_show_empty.isHidden = false
            self.ui_view_empty_groups.isHidden = false
            self.ui_view_empty_search.isHidden = true
            self.ui_view_empty_discover.isHidden = true
        }
        else {
            if isSearch {
                self.ui_view_empty.isHidden = false
                self.ui_view_empty_groups.isHidden = true
                self.ui_view_empty_search.isHidden = false
                self.ui_view_empty_discover.isHidden = true
                ui_arrow_show_empty.isHidden = false
            }
            else {
                self.ui_view_empty.isHidden = false
                self.ui_view_empty_groups.isHidden = true
                self.ui_view_empty_search.isHidden = true
                self.ui_view_empty_discover.isHidden = false
                ui_arrow_show_empty.isHidden = false
            }
        }
    }
    
    func hideEmptyView() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        ui_view_empty_groups.isHidden = true
        ui_view_empty_search.isHidden = true
        ui_view_empty_discover.isHidden = true
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
}

//MARK: - TableView DataSource/ Delegate  -
extension NeighborhoodHomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isGroupsSelected && myNeighborhoods.isEmpty && !isfirstLoadingMyGroup) || (isSearch && neighborhoodsSearch.isEmpty && isSendedSearch) || (!isGroupsSelected && neighborhoodsDiscovered.isEmpty) {
          //  showEmptyView()
        }
        else {
            hideEmptyView()
        }
        
        return isGroupsSelected ? myNeighborhoods.count : isSearch ? neighborhoodsSearch.count + 1 : neighborhoodsDiscovered.count + 1 //Search
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isGroupsSelected {
            let neighborhood = myNeighborhoods[indexPath.row]
            
            var cellName = "cellGroup"
            
            if neighborhood.creator.uid == UserDefaults.currentUser?.sid {
                cellName = "cellGroupMy"
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! NeighborhoodHomeGroupCell
            
            cell.populateCell(neighborhood: neighborhood)
            
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearch", for: indexPath) as! NeighborhoodHomeSearchCell
            
            cell.populateCell(delegate: self, isSearch:isSearch,isCellUserSearch: false)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroup", for: indexPath)as! NeighborhoodHomeGroupCell
        let neighborhood = isSearch ? neighborhoodsSearch[indexPath.row - 1] : neighborhoodsDiscovered[indexPath.row - 1]
        cell.populateCell(neighborhood: neighborhood)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var neighborhood:Neighborhood
        
        if isGroupsSelected {
            neighborhood = myNeighborhoods[indexPath.row]
            AnalyticsLoggerManager.logEvent(name: Action_Group_MyGroup_Card)
        }
        else {
            if indexPath.row == 0 { return }
            neighborhood = isSearch ? neighborhoodsSearch[indexPath.row - 1] : neighborhoodsDiscovered[indexPath.row - 1]
            
            if isSearch {
                AnalyticsLoggerManager.logEvent(name: Action_Group_Search_SeeResult)
            }
            else {
                AnalyticsLoggerManager.logEvent(name: Action_Group_Discover_Card)
            }
        }
        
        self.showNeighborhood(neighborhoodId: neighborhood.uid,neighborhood:neighborhood)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        if isGroupsSelected {
            let lastIndex = myNeighborhoods.count - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex && self.myNeighborhoods.count >= numberOfItemsForWS * currentPageMy {
                self.currentPageMy = self.currentPageMy + 1
                self.getNeighborhoods()
            }
        }
        else if !isSearch {
            let lastIndex = neighborhoodsDiscovered.count - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex && self.neighborhoodsDiscovered.count >= numberOfItemsForWS * currentPageDiscover {
                self.currentPageDiscover = self.currentPageDiscover + 1
                self.getNeighborhoodsSuggestions()
            }
        }
    }
    
    func scrollViewDidScroll( _ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0) {
            
            let yImage = self.imageNormalHeight - (scrollView.contentOffset.y+self.imageNormalHeight)
            let diffImage = (self.maxViewHeight - self.maxImageHeight)
            let heightImage = min(max (yImage -  diffImage,self.minImageHeight),self.maxImageHeight)
            
            self.ui_image.alpha = heightImage / self.maxImageHeight
            
            let yView = self.viewNormalHeight - (scrollView.contentOffset.y + self.viewNormalHeight)
            let heightView = min(max (yView,self.minViewHeight),self.maxViewHeight)
            self.ui_view_height_constraint.constant = heightView
            
            //On évite de calculer et repositionner les vues inutiliement.
            if self.ui_view_height_constraint.constant <= self.minViewHeight {
              //  self.ui_image.isHidden = true
                self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.minLabelFont)
                // self.ui_constraint_bottom_label.constant = self.minLabelBottomConstraint
                return
            }
            
            self.ui_image.isHidden = false
            
            let yLabel = self.labelNormalConstraintBottom - (scrollView.contentOffset.y + self.labelNormalConstraintBottom)
            let heightLabel = min(max (yLabel,self.minLabelBottomConstraint),self.maxLabelBottomConstraint)
            self.ui_constraint_bottom_label.constant = heightLabel
            
            let yLabelFont = self.labelNormalFontHeight - (scrollView.contentOffset.y + self.labelNormalFontHeight)
            let heightCalculated = (self.minLabelFont * yLabelFont) / self.minViewHeight
            let heightLabelFont = min(max (heightCalculated,self.minLabelFont),self.maxLabelFont)
            self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: heightLabelFont)
            
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - NeighborhoodHomeSearchDelegate  -
extension NeighborhoodHomeViewController: NeighborhoodHomeSearchDelegate {
    func goSearch(_ text: String?) {
        if let text = text, !text.isEmpty {
            AnalyticsLoggerManager.logEvent(name: Action_Group_Search_Validate)
            self.getNeighborhoodsSearch(text: text)
        }
        else {
            self.neighborhoodsSearch.removeAll()
            self.isAlreadyClearRows = false
            self.currentPageDiscover = 1
            self.isSendedSearch = false
            self.getNeighborhoodsSuggestions()
        }
    }
    
    func showEmptySearch() {
        isSearch = true
        isLoading = false
        self.isSendedSearch = false
        if !isAlreadyClearRows {
            isAlreadyClearRows = true
            self.ui_tableview.reloadData()
        }
        else {
            isAlreadyClearRows = false
        }
    }
}
