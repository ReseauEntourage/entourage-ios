//
//  ActionMainHomeViewController.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit
import IQKeyboardManagerSwift
import IHProgressHUD

class ActionsMainHomeViewController: UIViewController {

    
    @IBOutlet weak var ui_view_selector: UIView!
    @IBOutlet weak var ui_image_inside_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_image_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    
    @IBOutlet weak var ui_constraint_bottom_label: NSLayoutConstraint!
    
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_label_contribs: UILabel!
    @IBOutlet weak var ui_view_indicator_contribs: UIView!
    @IBOutlet weak var ui_label_solicitations: UILabel!
    @IBOutlet weak var ui_view_indicator_solicitations: UIView!
    
    
    @IBOutlet weak var ui_location_filter: UILabel!
    @IBOutlet weak var ui_view_bt_location: UIView!
    
    @IBOutlet weak var ui_categories_filter: UILabel!
    @IBOutlet weak var ui_view_bt_categories: UIView!
    
    @IBOutlet weak var ui_floaty_button: Floaty!
    
    @IBOutlet weak var ui_view_filter_button: UIView!
    //Views empty
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_arrow_show_empty: UIImageView!
    @IBOutlet weak var ui_view_empty_discover: UIView!
    @IBOutlet weak var ui_lbl_empty_title_discover: UILabel!
    @IBOutlet weak var ui_lbl_empty_subtitle_discover: UILabel!
    @IBOutlet weak var ui_view_bt_clear_filters: UIView!
    @IBOutlet weak var ui_title_bt_clear_filters: UILabel!
    
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
    
    var pullRefreshControl = UIRefreshControl()
    
    private var isfirstLoadingContrib = true
    private var isContribSelected = true
    private var currentSelectedIsContribs = false // Use to prevent reloading tabs on view appears + Tap selection bar
    
    var isLoading = false
    
    var currentPageContribs = 1
    var currentPageSolicitations = 1
    let numberOfItemsForWS = 20 // Arbitrary nb of items used for pagging
    let nbOfItemsBeforePagingReload = 5 // Arbitrary nb of items from the end of the list to send new call
    
    
    var contribs = [Action]()
    var solicitations = [Action]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        setupFloatingButton()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        ui_tableview.register(UINib(nibName: ActionContribDetailHomeCell.identifier, bundle: nil), forCellReuseIdentifier: ActionContribDetailHomeCell.identifier)
        ui_tableview.register(UINib(nibName: ActionSolicitationDetailHomeCell.identifier, bundle: nil), forCellReuseIdentifier: ActionSolicitationDetailHomeCell.identifier)
        
        setupEmptyViews()
        
        setupViews()

        //Notif for updating when create new action
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationActionCreateEnd), object: nil)
        
        //Notif for showing new created action
        NotificationCenter.default.addObserver(self, selector: #selector(showNewAction(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewAction), object: nil)
        
        //Notif for updating actions after tabbar selected
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatasFromTab), name: NSNotification.Name(rawValue: kNotificationActionsUpdate), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeTabSelection()
        
        if isContribSelected {
            if !currentSelectedIsContribs {
                currentSelectedIsContribs = true
                getActions()
            }
            else if contribs.count == 0 {
                showEmptyView()
            }
        }
        else {
            if currentSelectedIsContribs {
                currentSelectedIsContribs = false
                getSolicitations()
            }
            else if solicitations.count == 0 {
                showEmptyView()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Use to change tab selection from other place
    func setDiscoverFirst() {
        self.isContribSelected = false
        self.currentSelectedIsContribs = true
    }
    //Use to change tab selection from other place
    func setMyFirst() {
        self.isContribSelected = true
        self.currentSelectedIsContribs = false
    }
    
    func setupFloatingButton() {
        let floatItem1 = createButtonItem(title: "action_menu_demand".localized, iconName: "ic_menu_button_create_solicitation") { item in
            self.createAction(isContrib:false)
        }
        
        let floatItem2 = createButtonItem(title: "action_menu_contrib".localized, iconName: "ic_menu_button_create_contrib") { item in
            self.createAction(isContrib:true)
        }
        
        ui_floaty_button.overlayColor = .white.withAlphaComponent(0.10)
        ui_floaty_button.addBlurOverlay = true
        ui_floaty_button.itemSpace = 24
        ui_floaty_button.addItem(item: floatItem2)
        ui_floaty_button.addItem(item: floatItem1)
        ui_floaty_button.sticky = true
        ui_floaty_button.animationSpeed = 0.3
        ui_floaty_button.fabDelegate = self
    }

    func createAction(isContrib:Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actions, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "actionCreateVCMain") as? ActionCreateMainViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isContrib = isContrib
            vc.parentController = self
            self.tabBarController?.present(vc, animated: true)
        }
    }
    
    //MARK: - Call from Notifications -
    @objc func refreshDatasFromTab() {
        //TODO: reset filters + title
        
        currentPageContribs = 1
        currentPageSolicitations = 1
        if isContribSelected {
            currentSelectedIsContribs = true
            if self.contribs.count > 0 {
                self.gotoTop(isAnimated:false)
            }
            getActions(reloadOther:true)
        }
        else {
            currentSelectedIsContribs = false
            if self.solicitations.count > 0 {
                self.gotoTop(isAnimated:false)
            }
            getSolicitations(reloadOther:true)
        }
    }
    
    @objc func refreshDatas() {
        updateFromCreate()
    }
    
    @objc func updateFromCreate() {
        if isContribSelected {
            currentPageContribs = 1
            currentSelectedIsContribs = true
            getActions()
        }
        else {
            currentPageSolicitations = 1
            currentSelectedIsContribs = false
            getSolicitations()
        }
    }
    
    @objc func showNewAction(_ notification:Notification) {
        if let actionId = notification.userInfo?[kNotificationActionShowId] as? Int {
            DispatchQueue.main.async {
                self.showAction(actionId: actionId, isAfterCreation: true)
            }
        }
    }
    
    //MARK: - Network -
    
    func getActions(isReloadFromTab:Bool = false, reloadOther:Bool = false) {
        if self.isLoading { return }
        
        if self.contribs.isEmpty { self.ui_tableview.reloadData() }
        
        if !isReloadFromTab {
            IHProgressHUD.show()
        }
        
        self.isLoading = true
        
        ActionsService.getAllActions(isContrib: isContribSelected, currentPage: currentPageContribs, per: numberOfItemsForWS) { actions, error in
            IHProgressHUD.dismiss()
            self.isfirstLoadingContrib = false
            self.pullRefreshControl.endRefreshing()
            if let actions = actions {
                if self.currentPageContribs > 1 {
                    self.contribs.append(contentsOf: actions)
                }
                else {
                    self.contribs = actions
                }
                
                if !isReloadFromTab {
                    self.ui_tableview.reloadData()
                    if self.contribs.count > 0 && self.currentPageContribs == 1 {
                        self.gotoTop()
                    }
                }
            }
            
            if !isReloadFromTab {
                if self.contribs.count == 0 {
                    self.showEmptyView()
                }
                else {
                    self.hideEmptyView()
                }
                self.ui_tableview.reloadData()
            }
            
            self.isLoading = false
            if reloadOther {
                self.getSolicitations(isReloadFromTab: true)
            }
        }
    }
    
    func getSolicitations(isReloadFromTab:Bool = false, reloadOther:Bool = false) {
        if self.isLoading { return }
        if !isReloadFromTab {
            IHProgressHUD.show()
        }
        
        self.isLoading = true
        
        ActionsService.getAllActions(isContrib: isContribSelected, currentPage: currentPageSolicitations, per: numberOfItemsForWS) { actions, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            
            if let actions = actions {
                if self.currentPageSolicitations > 1 {
                    self.solicitations.append(contentsOf: actions)
                }
                else {
                    self.solicitations = actions
                }
                
                if self.solicitations.count > 0 && self.currentPageSolicitations == 1 && !isReloadFromTab {
                    self.gotoTop()
                }
            }
            
            if !isReloadFromTab {
                if self.solicitations.count == 0 {
                    self.showEmptyView()
                }
                else {
                    self.hideEmptyView()
                }
                self.ui_tableview.reloadData()
            }
            self.isLoading = false
            if reloadOther {
                self.getActions(isReloadFromTab: true)
            }
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_contribs(_ sender: Any?) {
        isContribSelected = true
        isfirstLoadingContrib = true
        
        if isContribSelected != currentSelectedIsContribs && contribs.count == 0 {
            currentPageContribs = 1
            contribs.removeAll()
            self.ui_tableview.reloadData()
            getActions()
        }
        currentSelectedIsContribs = true
        isLoading = false
       
        self.ui_tableview.reloadData()
        changeTabSelection()
        
        if self.contribs.count > 0 {
            self.gotoTop()
        }
    }
    
    @IBAction func action_solicitations(_ sender: Any?) {
        isContribSelected = false
        
        
        if isContribSelected != currentSelectedIsContribs && self.solicitations.count == 0 {
            currentPageSolicitations = 1
            self.solicitations.removeAll()
            getSolicitations()
        }
        currentSelectedIsContribs = false
        isLoading = false
        changeTabSelection()
        self.ui_tableview.reloadData()
        
        if self.solicitations.count > 0 {
            self.gotoTop()
        }
    }
 
    @IBAction func action_show_filters_categories(_ sender: Any) {
        //TODO: Filters
        showWIP(parentVC: self.tabBarController)
    }
    
    @IBAction func action_show_filters_location(_ sender: Any) {
        //TODO: Filters
        showWIP(parentVC: self.tabBarController)
//        if let vc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "event_filters") as? EventFiltersViewController {
//            vc.currentFilter = self.currentFilter
//            vc.modalPresentationStyle = .fullScreen
//            vc.delegate = self
//            self.navigationController?.present(vc, animated: true)
//        }
    }
    
    @IBAction func action_clear_filters(_ sender: Any) {
        //TODO: Filters
        showWIP(parentVC: self.tabBarController)
//        self.currentFilter.resetToDefault()
//        self.ui_location_filter.text = currentFilter.getFilterButtonString()
//        self.getEventsDiscovered(isReloadFromTab: false, reloadOther: false)
    }
    
    @IBAction func action_show_my_actions(_ sender: Any) {
        //TODO: Show my actions
        showWIP(parentVC: self.tabBarController)
    }
    
    //MARK: - Methods -
    func changeTabSelection() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        self.ui_view_empty_discover.isHidden = true
        
        if isContribSelected {
            ui_label_contribs.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_label_solicitations.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
            
            ui_view_indicator_contribs.isHidden = false
            ui_view_indicator_solicitations.isHidden = true
        }
        else {
            ui_label_contribs.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
            
            ui_label_solicitations.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_view_indicator_contribs.isHidden = true
            ui_view_indicator_solicitations.isHidden = false
        }
        self.ui_tableview.reloadData()
    }
    
    func gotoTop(isAnimated:Bool = true) {
        if isContribSelected && contribs.count == 0 { return }
        else if !isContribSelected && solicitations.count == 0 { return }
        Logger.print("***** event Discovered hzereeeee: \(self.solicitations.count)")
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
        }
    }
    
    func setupViews() {
        //TODO: setup filters title
        ui_location_filter.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: .white))
        
        ui_label_title.text = "actions_main_page_title".localized
        ui_label_contribs.text = "actions_main_page_button_contribs".localized
        ui_label_solicitations.text = "actions_main_page_button_solicitations".localized
        
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
        
        ui_tableview.contentInset = UIEdgeInsets(top: viewNormalHeight + ui_view_filter_button.frame.height ,left: 0,bottom: 0,right: 0)
        ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: viewNormalHeight + ui_view_filter_button.frame.height ,left: 0,bottom: 0,right: 0)
        
        changeTabSelection()
        
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
    }
    
    func setupEmptyViews() {
        
        ui_lbl_empty_title_discover.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lbl_empty_subtitle_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_lbl_empty_title_discover.text = "action_contrib_empty_title".localized
        ui_lbl_empty_subtitle_discover.text = "action_contrib_empty_subtitle".localized
        
        ui_view_bt_clear_filters.layer.cornerRadius = ui_view_bt_clear_filters.frame.height / 2
        ui_title_bt_clear_filters.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_title_bt_clear_filters.text = "event_event_discover_clear_filters".localized
        
        hideEmptyView()
    }
    
    func changeTextsEmpty() {
        if isContribSelected {
            ui_lbl_empty_title_discover.text = "action_contrib_empty_title".localized
            ui_lbl_empty_subtitle_discover.text = "action_contrib_empty_subtitle".localized
        }
        else {
            ui_lbl_empty_title_discover.text = "action_solicitation_empty_title".localized
            ui_lbl_empty_subtitle_discover.text = "action_solicitation_empty_subtitle".localized
        }
    }
    
    func showEmptyView() {
        
        self.ui_view_empty.isHidden = false
        self.ui_view_empty_discover.isHidden = false
        ui_arrow_show_empty.isHidden = false
        changeTextsEmpty()
        
        //TODO: check search
        
//        if currentFilter.filterType != .profile || currentFilter.radius != UserDefaults.currentUser?.radiusDistance {
//            ui_view_bt_clear_filters.isHidden = false
//            ui_lbl_empty_title_discover.text = "event_event_discover_empty_search_title".localized
//            ui_lbl_empty_subtitle_discover.text = "event_event_discover_empty_search_subtitle".localized
//        }
//        else {
//            ui_view_bt_clear_filters.isHidden = true
//            ui_lbl_empty_title_discover.text = "event_event_discover_empty_title".localized
//            ui_lbl_empty_subtitle_discover.text = "event_event_discover_empty_subtitle".localized
//        }
    }
    
    func hideEmptyView() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        ui_view_empty_discover.isHidden = true
    }
    
    func showAction(actionId:Int, isAfterCreation:Bool = false, action:Action? = nil) {
        showWIP(parentVC: self.tabBarController)
    }
}

//MARK: - Tableview datasource / delegate -
extension ActionsMainHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isContribSelected && contribs.isEmpty && !isfirstLoadingContrib) || (!isContribSelected && solicitations.isEmpty) {
            //  showEmptyView()
        }
        else {
            hideEmptyView()
        }
        
        return isContribSelected ? contribs.count : solicitations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _value = isContribSelected ? contribs[indexPath.row] : solicitations[indexPath.row]
        
        if isContribSelected {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionContribDetailHomeCell.identifier, for: indexPath) as! ActionContribDetailHomeCell
            cell.populateCell(action: _value, hideSeparator: false)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSolicitationDetailHomeCell.identifier, for: indexPath) as! ActionSolicitationDetailHomeCell
            cell.populateCell(action: _value, hideSeparator: false)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var action:Action? = nil
        
        if isContribSelected {
            action = contribs[indexPath.row]
        }
        else {
            action = solicitations[indexPath.row]
        }
        
        guard let action = action else {
            return
        }
        
        self.showAction(actionId: action.id,action: action)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        if isContribSelected {
            let lastIndex = contribs.count - nbOfItemsBeforePagingReload
            
            if indexPath.row == lastIndex && self.contribs.count >= numberOfItemsForWS * currentPageContribs {
                self.currentPageContribs = self.currentPageContribs + 1
                self.getActions()
            }
        }
        else {
            let lastIndex = solicitations.count - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex  && self.solicitations.count >= numberOfItemsForWS * currentPageSolicitations {
                self.currentPageSolicitations = self.currentPageSolicitations + 1
                self.getSolicitations()
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
                self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.minLabelFont)
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

//MARK: - EventFiltersDelegate -
extension ActionsMainHomeViewController:EventFiltersDelegate {
    func updateFilters(_ filters: EventFilters) {
        //TODO: Update filters
//        self.currentFilter = filters
//
//        ui_location_filter.text = currentFilter.getFilterButtonString()
//        if self.solicitations.count > 0 {
//            self.gotoTop(isAnimated:false)
//        }
//        getEventsDiscovered(reloadOther:false)
    }
}

//MARK: - FloatyDelegate -
extension ActionsMainHomeViewController:FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        
    }
    
    private func createButtonItem(title:String, iconName:String, handler:@escaping ((FloatyItem) -> Void)) -> FloatyItem {
        let floatyItem = FloatyItem()
        floatyItem.buttonColor = .clear
        floatyItem.icon = UIImage(named: iconName)
        floatyItem.titleLabel.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
        floatyItem.titleShadowColor = .clear
        floatyItem.title = title
        floatyItem.imageSize = CGSize(width: 62, height: 62)
        floatyItem.handler = handler
        return floatyItem
    }
}
