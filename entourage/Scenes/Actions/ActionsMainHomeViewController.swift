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
    case myActions
}

class ActionsMainHomeViewController: UIViewController {
    
    @IBOutlet weak var ui_view_selector: UIView!
    @IBOutlet weak var ui_image_inside_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_constraint_bottom_label: NSLayoutConstraint!
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_label_contribs: UILabel!
    @IBOutlet weak var ui_view_indicator_contribs: UIView!
    @IBOutlet weak var ui_label_solicitations: UILabel!
    @IBOutlet weak var ui_view_indicator_solicitations: UIView!
    @IBOutlet weak var ui_label_myActions: UILabel!
    @IBOutlet weak var ui_view_indicator_myActions: UIView!
    @IBOutlet weak var ui_floaty_button: Floaty!
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_arrow_show_empty: UIImageView!
    @IBOutlet weak var ui_view_empty_discover: UIView!
    @IBOutlet weak var ui_lbl_empty_title_discover: UILabel!
    @IBOutlet weak var ui_lbl_empty_subtitle_discover: UILabel!
    @IBOutlet weak var ui_view_bt_clear_filters: UIView!
    @IBOutlet weak var ui_title_bt_clear_filters: UILabel!
    @IBOutlet weak var ui_search_textfield: UITextField!
    @IBOutlet weak var ui_contrainst_textfield_height: NSLayoutConstraint!
    @IBOutlet weak var ui_view_search: UIView!
    @IBOutlet weak var ui_view_filter: UIView!
    @IBOutlet weak var ui_tv_number_filter: UILabel!
    
    @IBOutlet weak var btn_constraint: NSLayoutConstraint!
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
    var currentPageMyActions = 1
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
    private var isTabDemandClicked = false
    private var isTabContribClicked = false
    
    var contribs = [Action]()
    var solicitations = [Action]()
    var myActions = [Action]()
    
    var currentLocationFilter = EventActionLocationFilters()
    var currentSectionsFilter: Sections = Sections()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_contrainst_textfield_height.constant = 0
        ui_search_textfield.isHidden = true
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
        // Vous n'avez pas besoin d'enregistrer ActionMineCell si elle est définie comme prototype dans le storyboard
        setupEmptyViews()
        configureUserLocationAndRadius()
        
        setupViews()
        
        let filterTapGesture = UITapGestureRecognizer(target: self, action: #selector(ui_view_filterTapped))
        ui_view_filter.addGestureRecognizer(filterTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationActionCreateEnd), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNewAction(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewAction), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatasFromTab), name: NSNotification.Name(rawValue: kNotificationActionsUpdate), object: nil)
        
        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(showSearch))
        ui_view_search.addGestureRecognizer(searchTapGesture)
        changeTabSelection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfo()
        if currentMode == .contribSearch || currentMode == .solicitationSearch {
            self.ui_search_textfield.becomeFirstResponder()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setCellMainFilter() {
        self.ui_search_textfield.delegate = self
        ui_search_textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupTextFieldIcons()

        // Configurer le clavier pour afficher le bouton "Rechercher"
        ui_search_textfield.returnKeyType = .search
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
        ui_search_textfield.leftViewMode = .always
        ui_search_textfield.rightViewMode = .always
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    @objc private func closeTextField() {
        ui_contrainst_textfield_height.constant = 0
        ui_search_textfield.isHidden = true
        ui_search_textfield.text = ""
        self.ui_view_search.isHidden = false
        self.ui_view_filter.isHidden = false
        ui_search_textfield.resignFirstResponder()
        searchText = ""
        self.isSearching = false
        self.currentMode = self.isContribSelected ? .contribNormal : .solicitationNormal
        if self.numberOfFilter > 0 {
            self.currentMode = self.isContribSelected ? .contribFiltered : .solicitationFiltered
        }
        
        // Réinitialiser la hauteur de la vue et la taille de la police si en haut
        if self.ui_tableview.contentOffset.y <= -500 {
            self.ui_view_height_constraint.constant = self.maxViewHeight
            self.ui_constraint_bottom_label.constant = self.maxLabelBottomConstraint
            self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.maxLabelFont)
        } else {
            self.ui_view_height_constraint.constant = self.minViewHeight
            self.ui_constraint_bottom_label.constant = self.minLabelBottomConstraint
            self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.minLabelFont)
        }

        self.view.layoutIfNeeded()
        loadDataBasedOnMode()

        // Afficher la barre de tabulation
        (self.tabBarController as? MainTabbarViewController)?.setTabBar(hidden: false, animated: true, duration: 0.3)
    }
    
    @objc private func clearTextField() {
        ui_search_textfield.text = ""
        loadDataBasedOnMode()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            self.searchText = ""
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
    
    @objc private func ui_view_filterTapped() {
        showFilter()
    }
    
    @objc private func showSearch() {
        self.ui_view_search.isHidden = true
        self.ui_view_filter.isHidden = true
        ui_contrainst_textfield_height.constant = 30
        ui_search_textfield.isHidden = false
        self.isSearching = true
        self.currentMode = isContribSelected ? .contribSearch : .solicitationSearch
        scrollViewDidScroll(self.ui_tableview)
        gotoTop(isAnimated: false)
        self.ui_search_textfield.becomeFirstResponder()

        // Cacher la barre de tabulation
        (self.tabBarController as? MainTabbarViewController)?.setTabBar(hidden: true, animated: true, duration: 0.3)
    }

    func showFilter() {
        let sb = UIStoryboard.init(name: StoryboardName.filterMain, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MainFilter") as? MainFilter {
            vc.mod = .action
            vc.delegate = self
            vc.selectedItemsAction = self.selectedItemsFilter
            vc.selectedAdressTitle = self.selectedAddress
            vc.selectedRadius = Int(self.selectedRadius)
            vc.selectedAdress = self.selectedCoordinate
            vc.modalPresentationStyle = .fullScreen
            AppState.getTopViewController()?.present(vc, animated: true)
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
        
        currentSectionsFilter.resetToDefault()
        
        currentPageContribs = 1
        currentPageSolicitations = 1
        currentPageMyActions = 1
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
        currentPageMyActions = 1
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
        case .myActions:
            getMyActions()
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
    
    func getMyActions() {

        IHProgressHUD.show()
        self.isLoading = true
        ActionsService.getAllMyActions(currentPage: currentPageMyActions, per: numberOfItemsForWS) { actions, error in
           
            IHProgressHUD.dismiss()
            self.isLoading = false
            
            if let actions = actions {
                if self.currentPageMyActions > 1 {
                    self.myActions.append(contentsOf: actions)
                } else {
                    self.myActions = actions
                }
                
                self.ui_tableview.reloadData()
                if self.myActions.count > 0 && self.currentPageMyActions == 1 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    DispatchQueue.main.async {
                        self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
            if self.myActions.count == 0 {
                self.ui_view_empty.isHidden = false
            } else {
                self.ui_view_empty.isHidden = true
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
        isTabContribClicked = true
        isTabDemandClicked = false
        currentMode = .contribNormal
        if self.numberOfFilter != 0 {
            currentMode = .contribFiltered
        }
        self.contribs.removeAll()
        self.solicitations.removeAll()
        self.myActions.removeAll()
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
        isTabContribClicked = false
        isTabDemandClicked = true
        if self.numberOfFilter != 0 {
            currentMode = .solicitationFiltered
        }
        self.contribs.removeAll()
        self.solicitations.removeAll()
        self.myActions.removeAll()
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

    @IBAction func action_myActions(_ sender: Any?) {
        currentMode = .myActions
        isTabContribClicked = false
        isTabDemandClicked = false
        self.contribs.removeAll()
        self.solicitations.removeAll()
        self.myActions.removeAll()
        self.ui_tableview.reloadData()
        
        if myActions.isEmpty {
            currentPageMyActions = 1
            self.myActions.removeAll()
            loadDataBasedOnMode()
        }
        isLoading = false
        changeTabSelection()
        self.ui_tableview.reloadData()
        
        if self.myActions.count > 0 {
            self.gotoTop()
        }
    }

    
    @IBAction func action_clear_filters(_ sender: Any) {
        self.currentLocationFilter.resetToDefault()
        
        currentPageContribs = 1
        currentPageSolicitations = 1
        currentPageMyActions = 1
        loadDataBasedOnMode()
    }
    
    func changeTabSelection() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        self.ui_view_empty_discover.isHidden = true
        if isTabDemandClicked {
            isContribSelected = false
        }
        if isTabContribClicked {
            isContribSelected = true
        }
        
        if currentMode != .myActions{
            if searchText != "" {
                currentMode = isContribSelected ? .contribSearch : .solicitationSearch
            }else if self.numberOfFilter != 0 {
                currentMode = isContribSelected ? .contribFiltered : .solicitationFiltered
            }
            else {
                currentMode = isContribSelected ? .contribNormal : .solicitationNormal
            }
        }
        
        //getFontCourantBoldOrangeSmall
        //getFontCourantBoldGreyOffSmall
        switch currentMode {
        case .contribNormal, .contribFiltered, .contribSearch:
            AnalyticsLoggerManager.logEvent(name: Help_view_contrib)
            ui_label_contribs.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeSmall())
            ui_label_solicitations.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOffSmall())
            ui_label_myActions.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOffSmall())

            ui_view_indicator_contribs.isHidden = false
            ui_view_indicator_solicitations.isHidden = true
            ui_view_indicator_myActions.isHidden = true
            self.ui_view_search.isHidden = false
            self.ui_view_filter.isHidden = false

        case .solicitationNormal, .solicitationFiltered, .solicitationSearch:
            AnalyticsLoggerManager.logEvent(name: Help_view_demand)
            ui_label_contribs.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOffSmall())
            ui_label_solicitations.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeSmall())
            ui_label_myActions.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOffSmall())

            ui_view_indicator_contribs.isHidden = true
            ui_view_indicator_solicitations.isHidden = false
            ui_view_indicator_myActions.isHidden = true
            self.ui_view_search.isHidden = false
            self.ui_view_filter.isHidden = false

        case .myActions:
            AnalyticsLoggerManager.logEvent(name: Help_view_myactions)
            ui_label_contribs.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOffSmall())
            ui_label_solicitations.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGreyOffSmall())
            ui_label_myActions.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeSmall())

            ui_view_indicator_contribs.isHidden = true
            ui_view_indicator_solicitations.isHidden = true
            ui_view_indicator_myActions.isHidden = false
            self.ui_view_search.isHidden = true
            self.ui_view_filter.isHidden = true
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.ui_tableview.reloadData()
            self.loadDataBasedOnMode()
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
        ui_label_title.text = "actions_main_page_title".localized
        ui_label_contribs.text = "actions_main_page_button_contribs".localized
        ui_label_solicitations.text = "actions_main_page_button_solicitations".localized
        ui_label_myActions.text = "actions_my_title".localized
        
        ui_view_selector.addRadiusTopOnly(radius: ApplicationTheme.bigCornerRadius)
        
        imageNormalHeight = maxImageHeight
        
        ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.minLabelFont)
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
        } else {
            let window = UIApplication.shared.keyWindow
            if let topPadding = window?.safeAreaInsets.top {
                topSafeAreaInsets = topPadding
            }
        }
        
        ui_image_inside_top_constraint.constant = ui_image_inside_top_constraint.constant - topSafeAreaInsets
        changeTabSelection()
        
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
        
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
        } else if currentMode == .solicitationNormal || currentMode == .solicitationFiltered || currentMode == .solicitationSearch {
            ui_lbl_empty_title_discover.text = "action_solicitation_empty_title".localized
            ui_lbl_empty_subtitle_discover.text = "action_solicitation_empty_subtitle".localized
        } else {
            ui_lbl_empty_title_discover.text = "action_myActions_empty_title".localized
            ui_lbl_empty_subtitle_discover.text = "action_myActions_empty_subtitle".localized
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
            print("eho vc isContrib " , isContrib)
            vc.isContrib = isContrib
            self.tabBarController?.present(navvc, animated: true)
        }
    }
}

//MARK: - Tableview datasource / delegate -
extension ActionsMainHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch) && contribs.isEmpty && !isfirstLoadingContrib || (currentMode == .solicitationNormal || currentMode == .solicitationFiltered || currentMode == .solicitationSearch) && solicitations.isEmpty || (currentMode == .myActions) && myActions.isEmpty {
            // showEmptyView()
        } else {
            hideEmptyView()
        }
        
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            return contribs.count
        } else if currentMode == .solicitationNormal || currentMode == .solicitationFiltered || currentMode == .solicitationSearch {
            return solicitations.count
        } else {
            return myActions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action: Action
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            action = contribs[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionContribDetailHomeCell.identifier, for: indexPath) as! ActionContribDetailHomeCell
            cell.populateCell(action: action, hideSeparator: false)
            return cell
        } else if currentMode == .solicitationNormal || currentMode == .solicitationFiltered || currentMode == .solicitationSearch {
            action = solicitations[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSolicitationDetailHomeCell.identifier, for: indexPath) as! ActionSolicitationDetailHomeCell
            cell.populateCell(action: action, hideSeparator: false)
            return cell
        } else {
            action = myActions[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMy", for: indexPath) as! ActionMineCell
            cell.populateCell(action: action)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action: Action
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            action = contribs[indexPath.row]
        } else if currentMode == .solicitationNormal || currentMode == .solicitationFiltered || currentMode == .solicitationSearch {
            action = solicitations[indexPath.row]
        } else {
            action = myActions[indexPath.row]
        }
        
        self.showAction(actionId: action.id, isContrib: action.isContrib(), action: action)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            let lastIndex = contribs.count - nbOfItemsBeforePagingReload
            
            if indexPath.row == lastIndex && self.contribs.count >= numberOfItemsForWS * currentPageContribs {
                self.currentPageContribs += 1
                loadDataBasedOnMode()
            }
        } else if currentMode == .solicitationNormal || currentMode == .solicitationFiltered || currentMode == .solicitationSearch {
            let lastIndex = solicitations.count - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex && self.solicitations.count >= numberOfItemsForWS * currentPageSolicitations {
                self.currentPageSolicitations += 1
                loadDataBasedOnMode()
            }
        } else {
            let lastIndex = myActions.count - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex && self.myActions.count >= numberOfItemsForWS * currentPageMyActions {
                self.currentPageMyActions += 1
                loadDataBasedOnMode()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0) {
            if self.isSearching {
                if (scrollView.contentOffset.y <= 0 && (self.currentMode == .contribSearch || self.currentMode == .solicitationSearch)){
                    self.ui_search_textfield.becomeFirstResponder()
                }else{
                    self.view.endEditing(true)
                }
                // Mode recherche : toujours en taille minimale
                self.ui_view_height_constraint.constant = self.minViewHeight
                self.ui_constraint_bottom_label.constant = self.minLabelBottomConstraint
                self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.minLabelFont)
            } else {
                // Mode normal ou filtré
                if scrollView.contentOffset.y <= 0 {
                    
                    // Si le tableview est en haut du scroll
                    self.ui_view_height_constraint.constant = self.maxViewHeight
                    self.ui_constraint_bottom_label.constant = self.maxLabelBottomConstraint
                    self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.maxLabelFont)
                } else {
                    // Si le tableview est descendu
                    self.ui_view_height_constraint.constant = self.minViewHeight
                    self.ui_constraint_bottom_label.constant = self.minLabelBottomConstraint
                    self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.minLabelFont)
                }
            }
            
            // Mise à jour de la disposition de la vue
            self.view.layoutIfNeeded()
        }
    }

}

//MARK: - EventFiltersDelegate -
extension ActionsMainHomeViewController: EventFiltersDelegate {
    func updateFilters(_ filters: EventActionLocationFilters) {
        self.currentLocationFilter = filters
        
        
        goReloadAll()
    }
    
    func goReloadAll() {
        currentPageContribs = 1
        currentPageSolicitations = 1
        currentPageMyActions = 1
        
        if currentMode == .contribNormal || currentMode == .contribFiltered || currentMode == .contribSearch {
            if self.contribs.count > 0 {
                self.gotoTop(isAnimated: false)
            }
            loadDataBasedOnMode(reloadOther: true)
        } else if currentMode == .solicitationNormal || currentMode == .solicitationFiltered || currentMode == .solicitationSearch {
            if self.solicitations.count > 0 {
                self.gotoTop(isAnimated: false)
            }
            loadDataBasedOnMode(reloadOther: true)
        } else {
            if self.myActions.count > 0 {
                self.gotoTop(isAnimated: false)
            }
            loadDataBasedOnMode(reloadOther: true)
        }
    }
}

//MARK: - FloatyDelegate -
extension ActionsMainHomeViewController: FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        let newHeight: CGFloat = UIView.userInterfaceLayoutDirection(for: self.view.semanticContentAttribute) == .rightToLeft ? 150 : 16

        UIView.animate(withDuration: 0.3) {
            // Assurez-vous que vous modifiez bien la contrainte liée au bouton flottant
            self.btn_constraint.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }

    func floatyClosed(_ floaty: Floaty) {
        let newHeight: CGFloat = UIView.userInterfaceLayoutDirection(for: self.view.semanticContentAttribute) == .rightToLeft ? 16 : 16

        UIView.animate(withDuration: 0.3) {
            // Assurez-vous que vous modifiez bien la contrainte liée au bouton flottant
            self.btn_constraint.constant = newHeight
            self.view.layoutIfNeeded()
        }
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


extension ActionsMainHomeViewController: MainFilterDelegate {
    func didUpdateFilter(selectedItems: [String : Bool], radius: Float?, coordinate: CLLocationCoordinate2D?, adressTitle: String) {
        let selectedCount = selectedItems.values.filter { $0 }.count
        self.numberOfFilter = selectedCount
        
        if self.numberOfFilter == 0 {
            haveFilter = false
            ui_tv_number_filter.isHidden = true
        } else {
            haveFilter = true
            ui_tv_number_filter.text = "\(self.numberOfFilter)"
            ui_tv_number_filter.isHidden = false
        }
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
            currentMode = self.numberOfFilter > 0 ? .contribFiltered : .contribNormal
        } else {
            currentMode = self.numberOfFilter > 0 ? .solicitationFiltered : .solicitationNormal
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Ferme le clavier
        return true
    }
}
