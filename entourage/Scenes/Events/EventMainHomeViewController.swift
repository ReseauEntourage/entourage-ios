//
//  EventMainHomeViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit
import IHProgressHUD
import IQKeyboardManagerSwift

//Use to transform events to section date with events
struct EventsSorted {
    var events = [Any]()
    var datesSections = 0
}

class EventMainHomeViewController: UIViewController {
    
    @IBOutlet weak var ui_image_inside_top_constraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    //Views empty
    @IBOutlet weak var ui_view_empty: UIView!
    //GRoup
    @IBOutlet weak var ui_view_empty_events: UIView!
    @IBOutlet weak var ui_lbl_empty_subtitle_event: UILabel!
    @IBOutlet weak var ui_lbl_empty_title_event: UILabel!
    
    @IBOutlet weak var uiBtnDiscover: UIButton!
    @IBOutlet weak var ui_arrow_show_empty: UIImageView!
    @IBOutlet weak var ui_view_empty_discover: UIView!
    @IBOutlet weak var ui_lbl_empty_title_discover: UILabel!
    @IBOutlet weak var ui_lbl_empty_subtitle_discover: UILabel!
    
    @IBOutlet weak var ui_location_filter: UILabel!
    @IBOutlet weak var ui_view_bt_clear_filters: UIView!
    @IBOutlet weak var ui_title_bt_clear_filters: UILabel!
    
    
    var currentFilter = EventActionLocationFilters()
    
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
    
    var myEvents = [Event]()
    var myEventsExtracted = EventsSorted()
    var eventsDiscovered = [Event]()
    var eventsDiscoveredExtracted = EventsSorted()
    
    private var isEventSelected = true //true
    private var currentSelectedIsEvent = true//false // Use to prevent reloading tabs on view appears + Tap selection bar
    private var isfirstLoadingMyEvents = true
    
    var isLoading = false
    
    var currentPageMy = 1
    var currentPageDiscover = 1
    let numberOfItemsForWS = 20 // Arbitrary nb of items used for pagging
    let nbOfItemsBeforePagingReload = 5 // Arbitrary nb of items from the end of the list to send new call
    
    var pullRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.register(UINib(nibName: EventListSectionCell.identifier, bundle: nil), forCellReuseIdentifier: EventListSectionCell.identifier)
        ui_tableview.register(UINib(nibName: EventListCell.identifier, bundle: nil), forCellReuseIdentifier: EventListCell.identifier)
        ui_tableview.register(UINib(nibName: EventListCell.EventlistMeIdentifier, bundle: nil), forCellReuseIdentifier: EventListCell.EventlistMeIdentifier)
        if self.isEventSelected {
            setMyFirst()
        }
        setupEmptyViews()
        setupViews()
        //Notif for updating when create new Event
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationEventCreateEnd), object: nil)
        
        //Notif for showing new created event
        NotificationCenter.default.addObserver(self, selector: #selector(showNewEvent(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewEvent), object: nil)
        
        //Notif for updating events after tabbar selected
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatasFromTab), name: NSNotification.Name(rawValue: kNotificationEventsUpdate), object: nil)
        getUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeTabSelection()
        
        if isEventSelected {
            AnalyticsLoggerManager.logEvent(name: Event_view_my)
            if !currentSelectedIsEvent {
                currentSelectedIsEvent = true
                getEvents()
            }
            else if myEventsExtracted.events.count == 0 {
                showEmptyView()
            }
        }
        else {
            AnalyticsLoggerManager.logEvent(name: Event_view_discover)
            if currentSelectedIsEvent {
                currentSelectedIsEvent = false
                getEventsDiscovered()
            }
            else if eventsDiscoveredExtracted.events.count == 0 {
                showEmptyView()
            }
        }
        ui_tableview.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Use to change tab selection from other place
    func setDiscoverFirst() {
        self.isEventSelected = false
        self.currentSelectedIsEvent = true
    }
    //Use to change tab selection from other place
    func setMyFirst() {
        self.isEventSelected = true
        self.currentSelectedIsEvent = false
    }
    
    //MARK: - Call from Notifications -
    @objc func refreshDatasFromTab() {
        currentFilter.resetToDefault()
        ui_location_filter.text = currentFilter.getFilterButtonString()

        currentPageMy = 1
        currentPageDiscover = 1
        
        if isEventSelected {
            currentSelectedIsEvent = true
            if self.myEventsExtracted.events.count > 0 {
                self.gotoTop(isAnimated:false)
            }
            getEvents(reloadOther:true)
        }
        else {
            currentSelectedIsEvent = false
            if self.eventsDiscoveredExtracted.events.count > 0 {
                self.gotoTop(isAnimated:false)
            }
            getEventsDiscovered(reloadOther:true)
        }
        getUserInfo()
    }
    
    @objc func refreshDatas() {
        updateFromCreate()
        getUserInfo()
    }
    
    @objc func updateFromCreate() {
        if isEventSelected {
            currentPageMy = 1
            currentSelectedIsEvent = true
            getEvents()
        }
        else {
            currentPageDiscover = 1
            currentSelectedIsEvent = false
            getEventsDiscovered()
        }
    }
    
    @objc func showNewEvent(_ notification:Notification) {
        if let eventId = notification.userInfo?[kNotificationEventShowId] as? Int {
            DispatchQueue.main.async {
                self.showEvent(eventId: eventId, isAfterCreation: true)
            }
        }
    }
    
    //MARK: - Network -
    
    func getEvents(isReloadFromTab:Bool = false, reloadOther:Bool = false) {
        if self.isLoading { return }
        
        if self.myEventsExtracted.events.isEmpty { self.ui_tableview.reloadData() }
        
        if !isReloadFromTab {
            IHProgressHUD.show()
        }
        
        self.isLoading = true
        
        EventService.getAllEventsForUser(currentPage: currentPageMy, per: numberOfItemsForWS) { events, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            self.isfirstLoadingMyEvents = false
            
            if let events = events {
                if self.currentPageMy > 1 {
                    self.myEvents.append(contentsOf: events)
                }
                else {
                    self.myEvents = events
                }
                
                self.extractDict(isEventSelection: true)
                
                if !isReloadFromTab {
                    self.ui_tableview.reloadData()
                    if self.myEventsExtracted.events.count > 0 && self.currentPageMy == 1 {
                        self.gotoTop()
                    }
                }
            }
            
            if !isReloadFromTab {
                if self.myEventsExtracted.events.count == 0 {
                    self.showEmptyView()
                }
                else {
                    self.hideEmptyView()
                }
                self.ui_tableview.reloadData()
            }
            
            self.isLoading = false
            if reloadOther {
                self.getEventsDiscovered(isReloadFromTab: true)
            }
        }
    }
    
    func getEventsDiscoveredForMyEvent(isReloadFromTab:Bool = false, reloadOther:Bool = false) {
        
        EventService.getAllEventsDiscover(currentPage: currentPageDiscover, per: numberOfItemsForWS, filters: currentFilter.getfiltersForWS()) { events, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            
            DispatchQueue.main.async {
                if let events = events , events.count > 0 {
                    self.uiBtnDiscover.isHidden = false
                    self.ui_lbl_empty_subtitle_event.text = "event_no_event_but_discover".localized
                    self.uiBtnDiscover.setTitle("event_title_btn_discover_event".localized, for: .normal)
                    self.uiBtnDiscover.removeTarget(self, action: #selector(self.onClickCreate), for: .touchUpInside)
                    self.uiBtnDiscover.addTarget(self, action: #selector(self.onGoDiscover), for: .touchUpInside)
                }else{
                    self.uiBtnDiscover.isHidden = false
                    self.ui_lbl_empty_subtitle_event.text = "event_no_event_go_create".localized
                    self.uiBtnDiscover.setTitle("event_title_btn_create_event".localized, for: .normal)
                    self.uiBtnDiscover.removeTarget(self, action: #selector(self.onGoDiscover), for: .touchUpInside)
                    self.uiBtnDiscover.addTarget(self, action: #selector(self.onClickCreate), for: .touchUpInside)
                }

            }

        }
    }
    
    
    func getEventsDiscovered(isReloadFromTab:Bool = false, reloadOther:Bool = false) {
        if self.isLoading { return }
        
        if !isReloadFromTab {
            IHProgressHUD.show()
        }
        
        self.isLoading = true
        
        EventService.getAllEventsDiscover(currentPage: currentPageDiscover, per: numberOfItemsForWS, filters: currentFilter.getfiltersForWS()) { events, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            
            if let events = events {
                if self.currentPageDiscover > 1 {
                    self.eventsDiscovered.append(contentsOf: events)
                }
                else {
                    self.eventsDiscovered = events
                }
                
                self.extractDict(isEventSelection: false)
                
                if self.eventsDiscoveredExtracted.events.count > 0 && self.currentPageDiscover == 1 && !isReloadFromTab {
                    self.gotoTop()
                }
            }
            
            if !isReloadFromTab {
                if self.eventsDiscoveredExtracted.events.count == 0 {
                    self.showEmptyView()
                }
                else {
                    self.hideEmptyView()
                }
                self.ui_tableview.reloadData()
            }
            self.isLoading = false
            if reloadOther {
                self.getEvents(isReloadFromTab: true)
            }
        }
    }
    
    func getUserInfo() {
        guard let _userid = UserDefaults.currentUser?.uuid else {return}
        UserService.getUnreadCountForUser { unreadCount, error in
            if let unreadCount = unreadCount {
                UserDefaults.badgeCount = unreadCount.0
                UserDefaults.groupBadgeCount = unreadCount.1
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdateCount), object: nil)
            }
        }
    }
    
    //To transform array -> array with dict date sections
    func extractDict(isEventSelection:Bool) {
        let _events = isEventSelection ? myEvents : eventsDiscovered
        let newEventsSorted = Event.getArrayOfDateSorted(events: _events, isAscendant:true)
        var newEvents = [Any]()
        for (k,v) in newEventsSorted {
            newEvents.append(k.dateString)
            for _event in v {
                newEvents.append(_event)
            }
        }
        let eventsSorted = EventsSorted(events: newEvents, datesSections: newEventsSorted.count)
        
        if isEventSelection {
            self.myEventsExtracted.events.removeAll()
            self.myEventsExtracted = eventsSorted
        }
        else {
            self.eventsDiscoveredExtracted.events.removeAll()
            self.eventsDiscoveredExtracted = eventsSorted
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_myEvents(_ sender: Any?) {
        isEventSelected = true
        isfirstLoadingMyEvents = true
        self.uiBtnDiscover.isHidden = false

        
        if isEventSelected != currentSelectedIsEvent && myEventsExtracted.events.count == 0 {
            currentPageMy = 1
            myEventsExtracted.events.removeAll()
            self.ui_tableview.reloadData()
            getEvents()
        }
        currentSelectedIsEvent = true
        isLoading = false
       
        self.ui_tableview.reloadData()
        changeTabSelection()
        
        if self.myEventsExtracted.events.count > 0 {
            self.gotoTop()
        }
    }
    
    @IBAction func action_discover(_ sender: Any?) {
        isEventSelected = false
        self.uiBtnDiscover.isHidden = true
        if isEventSelected != currentSelectedIsEvent && self.eventsDiscoveredExtracted.events.count == 0 {
            currentPageDiscover = 1
            self.eventsDiscoveredExtracted.events.removeAll()
            getEventsDiscovered()
        }
        currentSelectedIsEvent = false
        isLoading = false
        changeTabSelection()
        self.ui_tableview.reloadData()
        
        if self.eventsDiscoveredExtracted.events.count > 0 {
            self.gotoTop()
        }
    }
    
    @IBAction func action_create_event(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Event_action_create)
        let navVC = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    @IBAction func action_show_filters(_ sender: Any) {
        if let vc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "event_filters") as? EventFiltersViewController {
            AnalyticsLoggerManager.logEvent(name: Event_action_filter)
            vc.currentFilter = self.currentFilter
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            self.navigationController?.present(vc, animated: true)
        }
    }
    
//    @IBAction func action_clear_filters(_ sender: Any) {
//        self.currentFilter.resetToDefault()
//        self.ui_location_filter.text = currentFilter.getFilterButtonString()
//        self.getEventsDiscovered(isReloadFromTab: false, reloadOther: false)
//    }
    
    //MARK: - Methods -
    func changeTabSelection() {
        getEventsDiscoveredForMyEvent()
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        self.ui_view_empty_events.isHidden = true
        self.ui_view_empty_discover.isHidden = true
        
        if isEventSelected {
            self.showHideFilterView(isHidden: true)
        }
        else {
            
            
            self.showHideFilterView(isHidden: false)
        }
        self.ui_tableview.reloadData()
    }
    
    func showHideFilterView(isHidden:Bool) {
        if isHidden {
            ui_tableview.contentInset = UIEdgeInsets(top: viewNormalHeight ,left: 0,bottom: 0,right: 0)
            ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: viewNormalHeight ,left: 0,bottom: 0,right: 0)
        }
        else {
            ui_tableview.contentInset = UIEdgeInsets(top: viewNormalHeight,left: 0,bottom: 0,right: 0)
            ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: viewNormalHeight,left: 0,bottom: 0,right: 0)
        }
    }
    
    func gotoTop(isAnimated:Bool = true) {
        if isEventSelected && myEventsExtracted.events.count == 0 { return }
        else if !isEventSelected && eventsDiscoveredExtracted.events.count == 0 { return }
        Logger.print("***** event Discovered hzereeeee: \(self.eventsDiscoveredExtracted.events.count)")
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
        }
    }
    
    func setupViews() {
        
        ui_location_filter.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: .white))
        ui_location_filter.text = currentFilter.getFilterButtonString()
        ui_label_title.text = "event_main_page_title".localized
        
        
        imageNormalHeight = maxImageHeight
        
        ui_label_title.font = UIFont.systemFont(ofSize: maxLabelFont)
        labelNormalFontHeight = maxLabelFont
        
        
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
        ui_lbl_empty_title_event.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lbl_empty_subtitle_event.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_lbl_empty_title_discover.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lbl_empty_subtitle_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_lbl_empty_title_event.text = "event_event_my_empty_title".localized
        ui_lbl_empty_subtitle_event.text = "event_event_my_empty_subtitle".localized
        
        ui_lbl_empty_title_discover.text = "event_event_discover_empty_title".localized
        ui_lbl_empty_subtitle_discover.text = "event_event_discover_empty_subtitle".localized
        
        ui_view_bt_clear_filters.layer.cornerRadius = ui_view_bt_clear_filters.frame.height / 2
        ui_title_bt_clear_filters.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_title_bt_clear_filters.text = "event_event_discover_clear_filters".localized
        
        getEventsDiscoveredForMyEvent()

        hideEmptyView()
    }
    
    func configureEmptyViewButton(){
        self.uiBtnDiscover.titleEdgeInsets = UIEdgeInsets(top:4,left:8,bottom:4,right:8)
    }
    
    @objc func onClickCreate(){
        AnalyticsLoggerManager.logEvent(name: Event_action_create)
        let navVC = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
        
    }
    @objc func onGoDiscover(){
        isEventSelected = false
        if isEventSelected != currentSelectedIsEvent && self.eventsDiscoveredExtracted.events.count == 0 {
            currentPageDiscover = 1
            self.eventsDiscoveredExtracted.events.removeAll()
            getEventsDiscovered()
        }
        currentSelectedIsEvent = false
        isLoading = false
        changeTabSelection()
        self.ui_tableview.reloadData()
        
        if self.eventsDiscoveredExtracted.events.count > 0 {
            self.gotoTop()
        }
    }
    
    func showEmptyView() {
        if isEventSelected {
            configureEmptyViewButton()
            self.ui_view_empty.isHidden = false
            ui_arrow_show_empty.isHidden = true//false
            self.ui_view_empty_events.isHidden = false
            self.ui_view_empty_discover.isHidden = true
        }
        else {
            configureEmptyViewButton()
            self.ui_view_empty.isHidden = false
            self.ui_view_empty_events.isHidden = true
            self.ui_view_empty_discover.isHidden = false
            ui_arrow_show_empty.isHidden = true
            
            //TODO: check search
            
            if currentFilter.filterType != .profile || currentFilter.radius != UserDefaults.currentUser?.radiusDistance {
                ui_view_bt_clear_filters.isHidden = true//false
                ui_lbl_empty_title_discover.text = "event_event_discover_empty_search_title".localized
                ui_lbl_empty_subtitle_discover.text = "event_event_discover_empty_search_subtitle".localized
            }
            else {
                ui_view_bt_clear_filters.isHidden = true
                ui_lbl_empty_title_discover.text = "event_event_discover_empty_title".localized
                ui_lbl_empty_subtitle_discover.text = "event_event_discover_empty_subtitle".localized
            }
        }
    }
    
    func hideEmptyView() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        ui_view_empty_events.isHidden = true
        ui_view_empty_discover.isHidden = true
    }
    
    func showEvent(eventId:Int, isAfterCreation:Bool = false, event:Event? = nil) {
        if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController  {
            vc.eventId = eventId
            vc.event = event
            vc.isAfterCreation = isAfterCreation
            vc.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVc, animated: true, completion: nil)
            return
        }
    }
}

//MARK: - Tableview datasource / delegate -
extension EventMainHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isEventSelected && myEventsExtracted.events.isEmpty && !isfirstLoadingMyEvents) || (!isEventSelected && eventsDiscoveredExtracted.events.isEmpty) {
            //  showEmptyView()
        }
        else {
            hideEmptyView()
        }
        
        return isEventSelected ? myEventsExtracted.events.count : eventsDiscoveredExtracted.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _value = isEventSelected ? myEventsExtracted.events[indexPath.row] : eventsDiscoveredExtracted.events[indexPath.row]
        
        if let txt = _value as? String {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.identifier, for: indexPath) as! EventListSectionCell
            cell.populateCell(title: txt, isTopHeader: false)
            return cell
        }
        
        let event = _value as! Event
        
        var cellName = EventListCell.identifier
        
        if event.author?.uid == UserDefaults.currentUser?.sid {
            cellName = EventListCell.EventlistMeIdentifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! EventListCell
        cell.populateCell(event: event, hideSeparator: true)
        if event.checkIsEventPassed(){
            cell.setPassed()
        }else{
            cell.setIncoming()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var event:Event? = nil
        
        if isEventSelected {
            if let _event = myEventsExtracted.events[indexPath.row] as? Event {
                event = _event
            }
        }
        else {
            if let _event = eventsDiscoveredExtracted.events[indexPath.row] as? Event {
                event = _event
            }
        }
        
        guard let event = event else {
            return
        }
        
        self.showEvent(eventId: event.uid,event: event)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        if isEventSelected {
            let lastIndex = myEventsExtracted.events.count - nbOfItemsBeforePagingReload
            
            if indexPath.row == lastIndex && (self.myEventsExtracted.events.count - myEventsExtracted.datesSections) >= (numberOfItemsForWS * currentPageMy) {
                self.currentPageMy = self.currentPageMy + 1
                self.getEvents()
            }
        }
        else {
            let lastIndex = eventsDiscoveredExtracted.events.count + eventsDiscoveredExtracted.datesSections - nbOfItemsBeforePagingReload
            if indexPath.row == lastIndex && (self.eventsDiscoveredExtracted.events.count - eventsDiscoveredExtracted.datesSections) >= numberOfItemsForWS * currentPageDiscover {
                self.currentPageDiscover = self.currentPageDiscover + 1
                self.getEventsDiscovered()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yImage = imageNormalHeight - (scrollView.contentOffset.y + imageNormalHeight)
        let diffImage = maxViewHeight - maxImageHeight
        let heightImage = min(max(yImage - diffImage, minImageHeight), maxImageHeight)
        
        let yView = viewNormalHeight - (scrollView.contentOffset.y + viewNormalHeight)
        let heightView = min(max(yView, minViewHeight), maxViewHeight)
        ui_view_height_constraint.constant = heightView
        
        // Éviter de calculer et repositionner les vues inutilement.
        if heightView <= minViewHeight {
            ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: minLabelFont)
            return
        }
        
        
        let yLabel = labelNormalConstraintBottom - (scrollView.contentOffset.y + labelNormalConstraintBottom)
        let heightLabel = min(max(yLabel, minLabelBottomConstraint), maxLabelBottomConstraint)
        
        let yLabelFont = labelNormalFontHeight - (scrollView.contentOffset.y + labelNormalFontHeight)
        let heightLabelFont = min(max((minLabelFont * yLabelFont) / minViewHeight, minLabelFont), maxLabelFont)
        ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: heightLabelFont)
        
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - EventFiltersDelegate -
extension EventMainHomeViewController:EventFiltersDelegate {
    func updateFilters(_ filters: EventActionLocationFilters) {
        self.currentFilter = filters
        
        ui_location_filter.text = currentFilter.getFilterButtonString()
        if self.eventsDiscoveredExtracted.events.count > 0 {
            self.gotoTop(isAnimated:false)
        }
        getEventsDiscovered(reloadOther:false)
    }
}
