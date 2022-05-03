//
//  NeighborhoodHomeViewController.swift
//  entourage
//
//  Created by Jerome on 21/04/2022.
//

import UIKit
import IHProgressHUD

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
    
    var maxViewHeight:CGFloat = 138
    var minViewHeight:CGFloat = 108//108
    
    var minLabelBottomConstraint:CGFloat = 9
    var maxLabelBottomConstraint:CGFloat = 20
    
    var minLabelFont:CGFloat = 18
    var maxLabelFont:CGFloat = 24
    
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
    
    var isGroupsSelected = true
    var currentSelectedIsGroup = false // Use to prevent reloading tabs on view appears + Tap selection bar
    var isfirstLoadingMyGroup = true
    
    var isLoading = false
    var isSendedSearch = false // Use to show empty search view only if we start search ;)
    
    var currentPage = 1
    let numberOfItemsForWS = 20 // Arbitrary nb of items used for pagging
    let nbOfItemsBeforePagingReload = 5 // Arbitrary nb of items from the end of the list to send new call
    
    //MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEmptyViews()
        
        setupViews()
        
        //Notif for updating when create new neighborhood
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationNeighborhoodCreateEnd), object: nil)
        
        //Notif for updating neighborhood infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
    }
    
    @objc func updateFromCreate() {
        currentPage = 1
        if isGroupsSelected {
            currentSelectedIsGroup = true
            getNeighborhoods()
        }
        else {
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Network -
    func getNeighborhoods() {
        if self.isLoading { return }
        
        guard let token = UserDefaults.currentUser?.uuid else { return }
        if self.myNeighborhoods.isEmpty { self.ui_tableview.reloadData() }
        
        IHProgressHUD.show()
        self.isSearch = false
        self.isLoading = true
        NeighborhoodService.getNeighborhoodsForUserId(token,currentPage: currentPage, per: numberOfItemsForWS, completion: { groups, error in
            IHProgressHUD.dismiss()
            self.isfirstLoadingMyGroup = false
            if let groups = groups {
                if self.currentPage > 1 {
                    self.myNeighborhoods.append(contentsOf: groups)
                }
                else {
                    self.myNeighborhoods = groups
                }
                
                self.ui_tableview.reloadData()
                if self.myNeighborhoods.count > 0 && self.currentPage == 1 {
                    self.gotoTop()
                }
            }
            self.ui_tableview.reloadData()
            self.isLoading = false
        })
    }
    
    func getNeighborhoodsSuggestions() {
        if self.isLoading { return }
        IHProgressHUD.show()
        self.isSearch = false
        self.isLoading = true
        NeighborhoodService.getSuggestNeighborhoods(currentPage: currentPage, per: numberOfItemsForWS) { groups, error in
            IHProgressHUD.dismiss()
            
            if let groups = groups {
                if self.currentPage > 1 {
                    self.neighborhoodsDiscovered.append(contentsOf: groups)
                }
                else {
                    self.neighborhoodsDiscovered = groups
                }
                // self.ui_tableview.reloadData()
                if self.neighborhoodsDiscovered.count > 0 && self.currentPage == 1 {
                    self.gotoTop()
                }
            }
            self.ui_tableview.reloadData()
            
            self.isLoading = false
        }
    }
    
    func getNeighborhoodsSearch(text:String) {
        if self.isLoading { return }
        IHProgressHUD.show()
        
        self.neighborhoodsSearch.removeAll()
        self.ui_tableview.reloadData()
        
        isAlreadyClearRows = false
        self.isLoading = true
        NeighborhoodService.getSearchNeighborhoods(text: text, completion: { groups, error in
            IHProgressHUD.dismiss()
            self.isSearch = true
            self.isLoading = false
            self.isSendedSearch = true
            if let groups = groups {
                self.neighborhoodsSearch = groups
                self.ui_tableview.reloadData()
                self.gotoTop()
            }
            self.ui_tableview.reloadData()
        })
    }
    
    //MARK: - IBActions -
    @IBAction func action_myGroups(_ sender: Any) {
        isGroupsSelected = true
        isfirstLoadingMyGroup = true
        if isGroupsSelected != currentSelectedIsGroup {
            currentPage = 1
            myNeighborhoods.removeAll()
            getNeighborhoods()
        }
        neighborhoodsSearch.removeAll()
        currentSelectedIsGroup = true
        isSendedSearch = false
        isSearch = false
        isLoading = false
        changeTabSelection()
    }
    
    @IBAction func action_discover(_ sender: Any) {
        isGroupsSelected = false
        if isGroupsSelected != currentSelectedIsGroup {
            currentPage = 1
            self.neighborhoodsDiscovered .removeAll()
            getNeighborhoodsSuggestions()
        }
        isSendedSearch = false
        currentSelectedIsGroup = false
        isLoading = false
        isSearch = false
        changeTabSelection()
    }
    
    @IBAction func action_create_group(_ sender: Any) {
        let  navVC = UIStoryboard.init(name: "Neighborhood_Create", bundle: nil).instantiateViewController(withIdentifier: "groupCreateVCMain") as! NeighborhoodCreateMainViewController
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
        self.ui_view_empty_groups.isHidden = true
        self.ui_view_empty_search.isHidden = true
        
        if isGroupsSelected {
            ui_label_groups.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_label_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
            
            ui_view_indicator_groups.isHidden = false
            ui_view_indicator_discover.isHidden = true
        }
        else {
            ui_label_groups.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
            
            ui_label_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_view_indicator_groups.isHidden = true
            ui_view_indicator_discover.isHidden = false
        }
        self.ui_tableview.reloadData()
    }
    
    func gotoTop() {
        if isGroupsSelected && myNeighborhoods.count == 0 { return }
        else if neighborhoodsDiscovered.count == 0 { return }
        
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: true)
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
    }
    
    func setupEmptyViews() {
        ui_bt_empty_group.titleLabel?.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_bt_empty_group.layer.cornerRadius = ui_bt_empty_group.frame.height / 2
        ui_bt_empty_group.backgroundColor = .appOrange
        
        ui_lbl_empty_group.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_lbl_empty_title_search.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        
        ui_lbl_empty_subtitle_search.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        hideEmptyView()
    }
    
    func showEmptyView() {
        if isGroupsSelected {
            self.ui_view_empty.isHidden = false
            self.ui_view_empty_groups.isHidden = false
            self.ui_view_empty_search.isHidden = true
        }
        else {
            self.ui_view_empty.isHidden = false
            self.ui_view_empty_groups.isHidden = true
            self.ui_view_empty_search.isHidden = false
        }
    }
    
    func hideEmptyView() {
        ui_view_empty.isHidden = true
        ui_view_empty_groups.isHidden = true
        ui_view_empty_search.isHidden = true
    }
}

//MARK: - TableView DataSource/ Delegate  -
extension NeighborhoodHomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isGroupsSelected && myNeighborhoods.isEmpty && !isfirstLoadingMyGroup) || (isSearch && neighborhoodsSearch.isEmpty && isSendedSearch) {
            showEmptyView()
        }
        else {
            hideEmptyView()
        }
        
        return isGroupsSelected ? myNeighborhoods.count : isSearch ? neighborhoodsSearch.count + 1 : neighborhoodsDiscovered.count + 1 //Search
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isGroupsSelected {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroup", for: indexPath) as! NeighborhoodHomeGroupCell
            let neighborhood = myNeighborhoods[indexPath.row]
            cell.populateCell(neighborhood: neighborhood)
            
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearch", for: indexPath) as! NeighborhoodHomeSearchCell
            
            cell.populateCell(delegate: self, isSearch:isSearch)
            
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
        }
        else {
            if indexPath.row == 0 { return }
            neighborhood = isSearch ? neighborhoodsSearch[indexPath.row - 1] : neighborhoodsDiscovered[indexPath.row - 1]
        }
        
        let sb = UIStoryboard.init(name: "Neighborhood", bundle: nil)
        if let nav = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = nav.topViewController as? NeighborhoodDetailViewController {
            vc.neighborhoodId = neighborhood.uid
            self.navigationController?.present(nav, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        if isGroupsSelected {
            let lastIndex = myNeighborhoods.count - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex && self.myNeighborhoods.count >= numberOfItemsForWS * currentPage {
                self.currentPage = self.currentPage + 1
                self.getNeighborhoods()
            }
        }
        else if !isSearch {
            let lastIndex = neighborhoodsDiscovered.count - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex && self.neighborhoodsDiscovered.count >= numberOfItemsForWS * currentPage {
                self.currentPage = self.currentPage + 1
                self.getNeighborhoodsSuggestions()
            }
        }
        
    }
    
    func scrollViewDidScroll( _ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0) {
            let yView = self.viewNormalHeight - (scrollView.contentOffset.y + self.viewNormalHeight)
            let heightView = min(max (yView,self.minViewHeight),self.maxViewHeight)
            self.ui_view_height_constraint.constant = heightView
            
            //On évite de calculer et repositionner les vues inutiliement.
            if self.ui_view_height_constraint.constant <= self.minViewHeight {
                self.ui_image.isHidden = true
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
            
            let yImage = self.imageNormalHeight - (scrollView.contentOffset.y+self.imageNormalHeight)
            let diffImage = (self.maxViewHeight - self.maxImageHeight)
            let heightImage = min(max (yImage -  diffImage,self.minImageHeight),self.maxImageHeight)
            self.ui_image_constraint_height.constant = heightImage
            
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - NeighborhoodHomeSearchDelegate  -
extension NeighborhoodHomeViewController: NeighborhoodHomeSearchDelegate {
    func goSearch(_ text: String?) {
        if let text = text, !text.isEmpty {
            self.getNeighborhoodsSearch(text: text)
        }
        else {
            self.neighborhoodsSearch.removeAll()
            self.isAlreadyClearRows = false
            self.currentPage = 1
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
