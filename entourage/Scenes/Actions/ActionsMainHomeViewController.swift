import UIKit
import IQKeyboardManagerSwift
import IHProgressHUD
import MapKit

enum ActionMode {
    case contribNormal
    case contribFiltered
    case contribSearch
    case solicitationNormal
    case solicitationFiltered
    case solicitationSearch
}

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
    @IBOutlet weak var ui_label_nb_cat_filter: UILabel!
    
    @IBOutlet weak var ui_floaty_button: Floaty!
    
    @IBOutlet weak var ui_view_filter_button: UIView!
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_arrow_show_empty: UIImageView!
    @IBOutlet weak var ui_view_empty_discover: UIView!
    @IBOutlet weak var ui_lbl_empty_title_discover: UILabel!
    @IBOutlet weak var ui_lbl_empty_subtitle_discover: UILabel!
    @IBOutlet weak var ui_view_bt_clear_filters: UIView!
    @IBOutlet weak var ui_title_bt_clear_filters: UILabel!
    
    @IBOutlet weak var ui_constraint_bt_location_width: NSLayoutConstraint!
    @IBOutlet weak var ui_label_my_announce_btn: UILabel!
    
    @IBOutlet weak var ui_view_filter: UIView!
    @IBOutlet weak var ui_tv_filter: UILabel!
    @IBOutlet weak var ui_search_textfield: UITextField!
    
    var maxViewHeight: CGFloat = 134
    var minViewHeight: CGFloat = 92
    
    var minLabelBottomConstraint: CGFloat = 9
    var maxLabelBottomConstraint: CGFloat = 20
    
    var minLabelFont: CGFloat = 16
    var maxLabelFont: CGFloat = 23
    
    var minImageHeight: CGFloat = 0
    var maxImageHeight: CGFloat = 73
    
    var viewNormalHeight: CGFloat = 0
    var labelNormalConstraintBottom: CGFloat = 0
    var labelNormalFontHeight: CGFloat = 0
    var imageNormalHeight: CGFloat = 0
    
    var topSafeAreaInsets: CGFloat = 0
    
    var pullRefreshControl = UIRefreshControl()
    
    private var isfirstLoadingContrib = true
    
    var isLoading = false
    
    var currentPageContribs = 1
    var currentPageSolicitations = 1
    let numberOfItemsForWS = 20
    let nbOfItemsBeforePagingReload = 5
    
    var numberOfFilter = 0
    var selectedItemsFilter = [String: Bool]()
    var selectedAddress: String = ""
    var selectedRadius: Float = 0
    var selectedCoordinate: CLLocationCoordinate2D?
    private var isSearching = false
    private var searchText = ""
    var currentMode: ActionMode = .solicitationNormal
    private var haveFilter = false
    private var textChangeTimer: Timer?
    private var isContribSelected = false
    
    var contribs = [Action]()
    var solicitations = [Action]()
    
    var currentLocationFilter = EventActionLocationFilters()
    var currentSectionsFilter: Sections = Sections()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentMode = .solicitationNormal // Set default to solicitations

        if let _sections = Metadatas.sharedInstance.tagsSections {
            currentSectionsFilter = _sections
        }
        
        IQKeyboardManager.shared.enable = false
        setupFloatingButton()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        ui_tableview.register(UINib(nibName: ActionContribDetailHomeCell.identifier, bundle: nil), forCellReuseIdentifier: ActionContribDetailHomeCell.identifier)
        ui_tableview.register(UINib(nibName: ActionSolicitationDetailHomeCell.identifier, bundle: nil), forCellReuseIdentifier: ActionSolicitationDetailHomeCell.identifier)
        setupEmptyViews()
        configureUserLocationAndRadius()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationActionCreateEnd), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNewAction(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewAction), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatasFromTab), name: NSNotification.Name(rawValue: kNotificationActionsUpdate), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeSectionFiltersCount()
        changeTabSelection()
        
        loadDataBasedOnMode()
        getUserInfo()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setSolicitationsFirst() {
        self.currentMode = .solicitationNormal
        AppManager.shared.isContributionPreference = false
    }
    
    func setContributionsFirst() {
        self.currentMode = .contribNormal
        AppManager.shared.isContributionPreference = true
    }
    
    func setupFloatingButton() {
        let floatItem2 = createButtonItem(title: "\("action_menu_demand".localized)  ", iconName: "ic_menu_button_create_solicitation") { item in
            self.createAction(isContrib: false)
        }
        
        let floatItem1 = createButtonItem(title: "\("action_menu_contrib".localized)  ", iconName: "ic_menu_button_create_contrib") { item in
            self.createAction(isContrib: true)
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
    
    func setCellMainFilter() {
        self.ui_search_textfield.delegate = self
        ui_view_filter.layer.borderWidth = 1
        ui_view_filter.layer.borderColor = UIColor.appGreyOff.cgColor
        ui_search_textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupTextFieldIcons()
    }
    
    private func setupTextFieldIcons() {
        // Setup left view with arrow button
        let arrowButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            arrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        arrowButton.tintColor = UIColor.appOrange
        arrowButton.addTarget(self, action: #selector(closeTextField), for: .touchUpInside)
        arrowButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        // Add padding
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        leftPaddingView.addSubview(arrowButton)
        arrowButton.center = leftPaddingView.center
        ui_search_textfield.leftView = leftPaddingView
        
        // Setup right view with cross button
        let crossButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            crossButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        crossButton.tintColor = UIColor.appOrange
        crossButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        crossButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        // Add padding
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        rightPaddingView.addSubview(crossButton)
        crossButton.center = rightPaddingView.center
        ui_search_textfield.rightView = rightPaddingView
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ui_search_textfield.leftViewMode = .always
        ui_search_textfield.rightViewMode = .always
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        ui_search_textfield.leftViewMode = .never
        ui_search_textfield.rightViewMode = .never
    }
    
    @objc private func closeTextField() {
        ui_search_textfield.resignFirstResponder()
    }
    
    @objc private func clearTextField() {
        ui_search_textfield.text = ""
        loadDataBasedOnMode()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            return
        }
        textChangeTimer?.invalidate()
        textChangeTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(notifyTextChange), userInfo: ui_search_textfield.text, repeats: false)
    }
    
    @objc private func notifyTextChange(_ timer: Timer) {
        if let text = timer.userInfo as? String {
            self.searchText = text
            self.currentMode = isContribSelected ? .contribSearch : .solicitationSearch
            self.loadDataBasedOnMode()
        }
    }
    
    func switchCellMainFilter() {
        if haveFilter {
            ui_view_filter.backgroundColor = UIColor.appBeige
            ui_view_filter.layer.borderColor = UIColor.appOrange.cgColor
            ui_tv_filter.isHidden = false
        } else {
            ui_view_filter.backgroundColor = UIColor.white
            ui_view_filter.layer.borderColor = UIColor.appGreyOff.cgColor
            ui_tv_filter.isHidden = true
        }
    }
    
    func createAction(isContrib: Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actionCreate, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "actionCreateVCMain") as? ActionCreateMainViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isContrib = isContrib
            vc.parentController = self
            self.tabBarController?.present(vc, animated: true)
        }
    }
    
    @objc func refreshDatasFromTab() {
        currentLocationFilter.resetToDefault()
        ui_location_filter.text = currentLocationFilter.getFilterButtonString()
        
        currentSectionsFilter.resetToDefault()
        changeSectionFiltersCount()
        
        currentPageContribs = 1
        currentPageSolicitations = 1
        loadDataBasedOnMode()
        getUserInfo()
    }
    
    @objc func refreshDatas() {
        updateFromCreate()
        getUserInfo()
    }
    
    @objc func updateFromCreate() {
        currentPageContribs = 1
        currentPageSolicitations = 1
        loadDataBasedOnMode()
    }
    
    @objc func showNewAction(_ notification: Notification) {
        if let actionId = notification.userInfo?[kNotificationActionShowId] as? Int, let isContrib = notification.userInfo?[kNotificationActionIsContrib] as? Bool {
            DispatchQueue.main.async {
                self.showAction(actionId: actionId, isContrib: isContrib, isAfterCreation: true)
            }
        }
    }
    
    //MARK: - Network -
    func loadDataBasedOnMode(isReloadFromTab: Bool = false, reloadOther: Bool = false) {
        if self.isLoading { return }
        
        if self.contribs.isEmpty { self.ui_tableview.reloadData() }
        
        if !isReloadFromTab {
            IHProgressHUD.show()
        }
        
        self.isLoading = true
        
        let selectedFilterIds = selectedItemsFilter.filter { $0.value }.map { $0.key }.joined(separator: ",")
        
        switch currentMode {
        case .contribNormal:
            ActionsService.getAllActions(isContrib: true, currentPage: currentPageContribs, per: numberOfItemsForWS, filtersLocation: currentLocationFilter.getfiltersForWS(), filtersSections: currentSectionsFilter.getallSectionforWS(), completion: handleActionsResponse(isReloadFromTab: isReloadFromTab, reloadOther: reloadOther))
        case .contribFiltered:
            ActionsService.getAllContribsWithFilter(currentPage: currentPageContribs, per: numberOfItemsForWS, travelDistance: selectedRadius, latitude: Float(selectedCoordinate?.latitude ?? 0), longitude: Float(selectedCoordinate?.longitude ?? 0), sectionList: selectedFilterIds, completion: handleActionsResponse(isReloadFromTab: isReloadFromTab, reloadOther: reloadOther))
        case .contribSearch:
            ActionsService.getAllContribsWithSearch(currentPage: currentPageContribs, per: numberOfItemsForWS, searchText: searchText, completion: handleActionsResponse(isReloadFromTab: isReloadFromTab, reloadOther: reloadOther))
        case .solicitationNormal:
            ActionsService.getAllActions(isContrib: false, currentPage: currentPageSolicitations, per: numberOfItemsForWS, filtersLocation: currentLocationFilter.getfiltersForWS(), filtersSections: currentSectionsFilter.getallSectionforWS(), completion: handleSolicitationsResponse(isReloadFromTab: isReloadFromTab, reloadOther: reloadOther))
        case .solicitationFiltered:
            ActionsService.getAllSolicitationsWithFilter(currentPage: currentPageSolicitations, per: numberOfItemsForWS, travelDistance: selectedRadius, latitude: Float(selectedCoordinate?.latitude ?? 0), longitude: Float(selectedCoordinate?.longitude ?? 0), sectionList: selectedFilterIds, completion: handleSolicitationsResponse(isReloadFromTab: isReloadFromTab, reloadOther: reloadOther))
        case .solicitationSearch:
            ActionsService.getAllSolicitationsWithSearch(currentPage: currentPageSolicitations, per: numberOfItemsForWS, searchText: searchText, completion: handleSolicitationsResponse(isReloadFromTab: isReloadFromTab, reloadOther: reloadOther))
        }
    }
    
    func handleActionsResponse(isReloadFromTab: Bool, reloadOther: Bool) -> ([Action]?, EntourageNetworkError?) -> Void {
        return { actions, error in
            IHProgressHUD.dismiss()
            self.isfirstLoadingContrib = false
            self.pullRefreshControl.endRefreshing()
            if let actions = actions {
                if self.currentPageContribs > 1 {
                    self.contribs.append(contentsOf: actions)
                } else {
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
                } else {
                    self.hideEmptyView()
                }
                self.ui_tableview.reloadData()
            }
            
            self.isLoading = false
            if reloadOther {
                self.loadDataBasedOnMode(isReloadFromTab: true)
            }
        }
    }
    
    func handleSolicitationsResponse(isReloadFromTab: Bool, reloadOther: Bool) -> ([Action]?, EntourageNetworkError?) -> Void {
        return { actions, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            
            if let actions = actions {
                if self.currentPageSolicitations > 1 {
                    self.solicitations.append(contentsOf: actions)
                } else {
                    self.solicitations = actions
                }
                
                if self.solicitations.count > 0 && self.currentPageSolicitations == 1 && !isReloadFromTab {
                    self.gotoTop()
                }
            }
            
            if !isReloadFromTab {
                if self.solicitations.count == 0 {
                    self.showEmptyView()
                } else {
                    self.hideEmptyView()
                }
                self.ui_tableview.reloadData()
            }
            self.isLoading = false
            if reloadOther {
                self.loadDataBasedOnMode(isReloadFromTab: true)
            }
        }
    }
    
    func getUserInfo() {
        guard let _userid = UserDefaults.currentUser?.uuid else { return }
        UserService.getUnreadCountForUser { unreadCount, error in
            if let unreadCount = unreadCount {
                UserDefaults.badgeCount = unreadCount
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdateCount), object: nil)
            }
        }
    }
    
    @IBAction func action_contribs(_ sender: Any?) {
        currentMode = .contribNormal
        if self.numberOfFilter != 0 {
            currentMode = .contribFiltered
        }
        self.contribs.removeAll()
        self.solicitations.removeAll()
        self.ui_tableview.reloadData()
        isfirstLoadingContrib = true
        
        if contribs.isEmpty {
            currentPageContribs = 1
            contribs.removeAll()
            self.ui_tableview.reloadData()
            loadDataBasedOnMode()
        }
        isLoading = false
        
        changeTabSelection()
        
        if self.contribs.count > 0 {
            self.gotoTop()
        }
        self.ui_tableview.reloadData()
    }
    
    @IBAction func action_solicitations(_ sender: Any?) {
        currentMode = .solicitationNormal
        if self.numberOfFilter != 0 {
            currentMode = .solicitationFiltered
        }
        self.contribs.removeAll()
        self.solicitations.removeAll()
        self.ui_tableview.reloadData()
        
        if solicitations.isEmpty {
            currentPageSolicitations = 1
            self.solicitations.removeAll()
            loadDataBasedOnMode()
        }
        isLoading = false
        changeTabSelection()
        self.ui_tableview.reloadData()
        
        if self.solicitations.count > 0 {
            self.gotoTop()
        }
    }
    
    @IBAction func action_show_filters_categories(_ sender: Any) {
        let sb = UIStoryboard.init(name: StoryboardName.filterMain, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MainFilter") as? MainFilter {
            vc.mod = .action
            vc.delegate = self
            vc.selectedItemsAction = self.selectedItemsFilter
            vc.selectedAdressTitle = self.selectedAddress
            vc.selectedRadius = Int(self.selectedRadius)
            vc.selectedAdress = self.selectedCoordinate
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
    
    @IBAction func action_show_filters_location(_ sender: Any) {
        if let vc = UIStoryboard.init(name: StoryboardName.actions, bundle: nil).instantiateViewController(withIdentifier: "event_filters") as? EventFiltersViewController {
            AnalyticsLoggerManager.logEvent(name: Help_action_location)
            vc.currentFilter = self.currentLocationFilter
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            vc.isAction = true
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    @IBAction func action_clear_filters(_ sender: Any) {
        self.currentLocationFilter.resetToDefault()
        self.ui_location_filter.text = currentLocationFilter.getFilterButtonString()
        
        currentPageContribs = 1
        currentPageSolicitations = 1
        loadDataBasedOnMode()
    }
    
    @IBAction func action_show_my_actions(_ sender: Any) {
        if let navvc = storyboard?.instantiateViewController(withIdentifier: "action_myNav") {
            AnalyticsLoggerManager.logEvent(name: Help_view_myactions)
            self.tabBarController?.present(navvc, animated: true)
        }
    }
    
    func changeTabSelection() {
        isContribSelected = !isContribSelected
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        self.ui_view_empty_discover.isHidden = true
        
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            AnalyticsLoggerManager.logEvent(name: Help_view_contrib)
            ui_label_contribs.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_label_solicitations.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOff())
            
            ui_view_indicator_contribs.isHidden = false
            ui_view_indicator_solicitations.isHidden = true
        } else {
            AnalyticsLoggerManager.logEvent(name: Help_view_demand)
            ui_label_contribs.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOff())
            
            ui_label_solicitations.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_view_indicator_contribs.isHidden = true
            ui_view_indicator_solicitations.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.ui_tableview.reloadData()
        })
    }
    
    func gotoTop(isAnimated: Bool = true) {
        let section = 0
        let numberOfRows = ui_tableview.numberOfRows(inSection: section)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: 0, section: section)
            DispatchQueue.main.async {
                self.ui_tableview.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
            }
        }
    }

    func setupViews() {
        self.setCellMainFilter()
        self.switchCellMainFilter()
        ui_location_filter.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: .white))
        ui_location_filter.text = currentLocationFilter.getFilterButtonString()
        
        ui_categories_filter.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: .white))
        ui_categories_filter.text = "action_filter_category".localized
        
        ui_constraint_bt_location_width.constant = view.frame.width / 1.7
        
        ui_label_nb_cat_filter.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoBold(size: 12), color: .appOrange))
        ui_label_nb_cat_filter.layer.cornerRadius = ui_label_nb_cat_filter.frame.height / 2
        ui_label_nb_cat_filter.isHidden = true
        
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
        
        ui_label_my_announce_btn.text = "actions_my_title".localized
        
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            if let topPadding = window?.safeAreaInsets.top {
                topSafeAreaInsets = topPadding
            }
        } else {
            let window = UIApplication.shared.keyWindow
            if let topPadding = window?.safeAreaInsets.top {
                topSafeAreaInsets = topPadding
            }
        }
        
        ui_image_inside_top_constraint.constant = ui_image_inside_top_constraint.constant - topSafeAreaInsets
        
        ui_tableview.contentInset = UIEdgeInsets(top: viewNormalHeight + ui_view_filter_button.frame.height, left: 0, bottom: 0, right: 0)
        ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: viewNormalHeight + ui_view_filter_button.frame.height, left: 0, bottom: 0, right: 0)
        
        changeTabSelection()
        
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
        
        changeSectionFiltersCount()
    }
    
    func changeSectionFiltersCount() {
        if currentSectionsFilter.getnumberSectionsSelected() > 0 {
            ui_label_nb_cat_filter.isHidden = false
            ui_label_nb_cat_filter.text = "\(currentSectionsFilter.getnumberSectionsSelected())"
            ui_categories_filter.text = currentSectionsFilter.getnumberSectionsSelected() > 1 ? "action_filter_categories".localized : "action_filter_category".localized
        } else {
            ui_label_nb_cat_filter.isHidden = true
        }
    }
    
    func configureUserLocationAndRadius() {
        if let user = UserDefaults.currentUser {
            self.selectedRadius = Float(user.radiusDistance ?? 40)
            self.selectedCoordinate = CLLocationCoordinate2D(latitude: user.addressPrimary?.latitude ?? 0, longitude: user.addressPrimary?.longitude ?? 0)
            self.selectedAddress = user.addressPrimary?.displayAddress ?? ""
        }
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
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            ui_lbl_empty_title_discover.text = "action_contrib_empty_title".localized
            ui_lbl_empty_subtitle_discover.text = "action_contrib_empty_subtitle".localized
        } else {
            ui_lbl_empty_title_discover.text = "action_solicitation_empty_title".localized
            ui_lbl_empty_subtitle_discover.text = "action_solicitation_empty_subtitle".localized
        }
    }
    
    func showEmptyView() {
        self.ui_view_empty.isHidden = false
        self.ui_view_empty_discover.isHidden = false
        ui_arrow_show_empty.isHidden = false
        changeTextsEmpty()
    }
    
    func hideEmptyView() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        ui_view_empty_discover.isHidden = true
    }
    
    func showAction(actionId: Int, isContrib: Bool, isAfterCreation: Bool = false, action: Action? = nil) {
        if let navvc = storyboard?.instantiateViewController(withIdentifier: "actionDetailFullNav") as? UINavigationController, let vc = navvc.topViewController as? ActionDetailFullViewController {
            vc.actionId = actionId
            vc.action = action
            vc.isContrib = isContrib
            self.tabBarController?.present(navvc, animated: true)
        }
    }
}

//MARK: - Tableview datasource / delegate -
extension ActionsMainHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch) && contribs.isEmpty && !isfirstLoadingContrib || (currentMode == .solicitationNormal || currentMode == .solicitationFiltered || currentMode == .solicitationSearch) && solicitations.isEmpty {
            // showEmptyView()
        } else {
            hideEmptyView()
        }
        
        return currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch ? contribs.count : solicitations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action = currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch ? contribs[indexPath.row] : solicitations[indexPath.row]
        
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionContribDetailHomeCell.identifier, for: indexPath) as! ActionContribDetailHomeCell
            cell.populateCell(action: action, hideSeparator: false)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSolicitationDetailHomeCell.identifier, for: indexPath) as! ActionSolicitationDetailHomeCell
            cell.populateCell(action: action, hideSeparator: false)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch ? contribs[indexPath.row] : solicitations[indexPath.row]
        self.showAction(actionId: action.id, isContrib: currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch, action: action)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            let lastIndex = contribs.count - nbOfItemsBeforePagingReload
            
            if indexPath.row == lastIndex && self.contribs.count >= numberOfItemsForWS * currentPageContribs {
                self.currentPageContribs += 1
                loadDataBasedOnMode()
            }
        } else {
            let lastIndex = solicitations.count - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex && self.solicitations.count >= numberOfItemsForWS * currentPageSolicitations {
                self.currentPageSolicitations += 1
                loadDataBasedOnMode()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0) {
            let yImage = self.imageNormalHeight - (scrollView.contentOffset.y + self.imageNormalHeight)
            let diffImage = (self.maxViewHeight - self.maxImageHeight)
            let heightImage = min(max(yImage - diffImage, self.minImageHeight), self.maxImageHeight)
            
            self.ui_image.alpha = heightImage / self.maxImageHeight
            
            let yView = self.viewNormalHeight - (scrollView.contentOffset.y + self.viewNormalHeight)
            let heightView = min(max(yView, self.minViewHeight), self.maxViewHeight)
            self.ui_view_height_constraint.constant = heightView
            
            if self.ui_view_height_constraint.constant <= self.minViewHeight {
                self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.minLabelFont)
                return
            }
            
            self.ui_image.isHidden = false
            
            let yLabel = self.labelNormalConstraintBottom - (scrollView.contentOffset.y + self.labelNormalConstraintBottom)
            let heightLabel = min(max(yLabel, self.minLabelBottomConstraint), self.maxLabelBottomConstraint)
            self.ui_constraint_bottom_label.constant = heightLabel
            
            let yLabelFont = self.labelNormalFontHeight - (scrollView.contentOffset.y + self.labelNormalFontHeight)
            let heightCalculated = (self.minLabelFont * yLabelFont) / self.minViewHeight
            let heightLabelFont = min(max(heightCalculated, self.minLabelFont), self.maxLabelFont)
            self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: heightLabelFont)
            
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - EventFiltersDelegate -
extension ActionsMainHomeViewController: EventFiltersDelegate {
    func updateFilters(_ filters: EventActionLocationFilters) {
        self.currentLocationFilter = filters
        
        ui_location_filter.text = currentLocationFilter.getFilterButtonString()
        
        goReloadAll()
    }
    
    func goReloadAll() {
        currentPageContribs = 1
        currentPageSolicitations = 1
        
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            if self.contribs.count > 0 {
                self.gotoTop(isAnimated: false)
            }
            loadDataBasedOnMode(reloadOther: true)
        } else {
            if self.solicitations.count > 0 {
                self.gotoTop(isAnimated: false)
            }
            loadDataBasedOnMode(reloadOther: true)
        }
    }
}

//MARK: - FloatyDelegate -
extension ActionsMainHomeViewController: FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        AnalyticsLoggerManager.logEvent(name: Help_action_create)
    }
    
    private func createButtonItem(title: String, iconName: String, handler: @escaping ((FloatyItem) -> Void)) -> FloatyItem {
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

extension ActionsMainHomeViewController: EventSectionFiltersDelegate {
    func updateSectionFilters(_ filters: Sections) {
        self.currentSectionsFilter = filters
        
        changeSectionFiltersCount()
        
        goReloadAll()
    }
}

extension ActionsMainHomeViewController: MainFilterDelegate {
    func didUpdateFilter(selectedItems: [String : Bool], radius: Float?, coordinate: CLLocationCoordinate2D?, adressTitle: String) {
        let selectedCount = selectedItems.values.filter { $0 }.count
        self.numberOfFilter = selectedCount
        self.ui_tv_filter.text = String(self.numberOfFilter)
        
        if self.numberOfFilter == 0 {
            haveFilter = false
        } else {
            haveFilter = true
        }
        self.switchCellMainFilter()
        self.selectedItemsFilter = selectedItems
        if let _radius = radius {
            self.selectedRadius = _radius
        }
        self.selectedAddress = adressTitle
        self.selectedCoordinate = coordinate
        
        if selectedCoordinate?.latitude == 0 || selectedCoordinate?.longitude == 0 {
            self.configureUserLocationAndRadius()
        }
        if isContribSelected {
            currentMode = .contribFiltered
        }else{
            currentMode = .solicitationFiltered
        }
        loadDataBasedOnMode()
    }
}

extension ActionsMainHomeViewController: UITextFieldDelegate {
    func setPlaceholder(text: String, font: UIFont) {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: font
        ]
        self.ui_search_textfield.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }
}
