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
    
    @IBOutlet weak var ui_view_filter_button: UIView!
    @IBOutlet weak var ui_view_selector: UIView!
    @IBOutlet weak var ui_image_inside_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_image_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    
    @IBOutlet weak var ui_constraint_bottom_label: NSLayoutConstraint!
    
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_label_events: UILabel!
    @IBOutlet weak var ui_view_indicator_events: UIView!
    @IBOutlet weak var ui_label_discover: UILabel!
    @IBOutlet weak var ui_view_indicator_discover: UIView!
    
    //Views empty
    @IBOutlet weak var ui_view_empty: UIView!
    //GRoup
    @IBOutlet weak var ui_view_empty_events: UIView!
    @IBOutlet weak var ui_lbl_empty_subtitle_event: UILabel!
    @IBOutlet weak var ui_lbl_empty_title_event: UILabel!
    
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
    
    var myEvents = [Event]()
    var myEventsExtracted = EventsSorted()
    var eventsDiscovered = [Event]()
    var eventsDiscoveredExtracted = EventsSorted()
    
    private var isEventSelected = true
    private var currentSelectedIsEvent = false // Use to prevent reloading tabs on view appears + Tap selection bar
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
        
        setupEmptyViews()
        
        setupViews()
        
        //Notif for updating when create new Event
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationEventCreateEnd), object: nil)
        
        //Notif for showing new created event
        NotificationCenter.default.addObserver(self, selector: #selector(showNewEvent(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewEvent), object: nil)
        
        //Notif for updating events after tabbar selected
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatasFromTab), name: NSNotification.Name(rawValue: kNotificationEventsUpdate), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEventSelected {
            if !currentSelectedIsEvent {
                currentSelectedIsEvent = true
                getEvents()
            }
        }
        else if currentSelectedIsEvent {
            currentSelectedIsEvent = false
            getEventsDiscovered()
        }
        changeTabSelection()
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
        currentPageMy = 1
        currentPageDiscover = 1
        
        if isEventSelected {
            currentSelectedIsEvent = true
            if self.myEvents.count > 0 {
                self.gotoTop(isAnimated:false)
            }
            getEvents(reloadOther:true)
        }
        else {
            currentSelectedIsEvent = false
            if self.eventsDiscovered.count > 0 {
                self.gotoTop(isAnimated:false)
            }
            getEventsDiscovered(reloadOther:true)
        }
    }
    
    @objc func refreshDatas() {
        updateFromCreate()
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
        
        if self.myEvents.isEmpty { self.ui_tableview.reloadData() }
        
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
                
                self.extractDict()
                
                if !isReloadFromTab {
                    self.ui_tableview.reloadData()
                    if self.myEvents.count > 0 && self.currentPageMy == 1 {
                        self.gotoTop()
                    }
                }
            }
            
            if !isReloadFromTab {
                if self.myEvents.count == 0 {
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
    
    func getEventsDiscovered(isReloadFromTab:Bool = false, reloadOther:Bool = false) {
        if self.isLoading { return }
        
        if !isReloadFromTab {
            IHProgressHUD.show()
        }
        
        self.isLoading = true
        
        EventService.getAllEventsDiscover(currentPage: currentPageDiscover, per: numberOfItemsForWS) { events, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            
            if let events = events {
                if self.currentPageDiscover > 1 {
                    self.eventsDiscovered.append(contentsOf: events)
                }
                else {
                    self.eventsDiscovered = events
                }
                
                self.extractDict()
                
                if self.eventsDiscovered.count > 0 && self.currentPageDiscover == 1 && !isReloadFromTab {
                    self.gotoTop()
                }
            }
            if !isReloadFromTab {
                if self.eventsDiscovered.count == 0 {
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
    
    //To transform array -> array with dict date sections
    func extractDict() {
        let _events = isEventSelected ? myEvents : eventsDiscovered
        let newEventsSorted = Event.getArrayOfDateSorted(events: _events, isAscendant:true)
        
        var newEvents = [Any]()
        for (k,v) in newEventsSorted {
            newEvents.append(k.dateString)
            for _event in v {
                newEvents.append(_event)
            }
        }
        
        let eventsSorted = EventsSorted(events: newEvents, datesSections: newEventsSorted.count)
        
        if isEventSelected {
            self.myEventsExtracted = eventsSorted
        }
        else {
            self.eventsDiscoveredExtracted = eventsSorted
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_myEvents(_ sender: Any?) {
        isEventSelected = true
        isfirstLoadingMyEvents = true
        
        if isEventSelected != currentSelectedIsEvent && myEvents.count == 0 {
            currentPageMy = 1
            myEvents.removeAll()
            getEvents()
        }
        currentSelectedIsEvent = true
        isLoading = false
        changeTabSelection()
        if self.myEvents.count > 0 {
            self.gotoTop()
        }
    }
    
    @IBAction func action_discover(_ sender: Any?) {
        isEventSelected = false
        
        if isEventSelected != currentSelectedIsEvent && self.eventsDiscovered.count == 0 {
            currentPageDiscover = 1
            self.eventsDiscovered.removeAll()
            getEventsDiscovered()
        }
        currentSelectedIsEvent = false
        isLoading = false
        changeTabSelection()
        if self.eventsDiscovered.count > 0 {
            self.gotoTop()
        }
    }
    
    @IBAction func action_create_event(_ sender: Any) {
        let navVC = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    @IBAction func action_show_filters(_ sender: Any) {
        self.showWIP(parentVC: tabBarController)
    }
    
    //MARK: - Methods -
    func changeTabSelection() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        self.ui_view_empty_events.isHidden = true
        self.ui_view_empty_discover.isHidden = true
        
        if isEventSelected {
            ui_label_events.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_label_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
            
            ui_view_indicator_events.isHidden = false
            ui_view_indicator_discover.isHidden = true
            self.showHideFilterView(isHidden: true)
        }
        else {
            ui_label_events.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
            
            ui_label_discover.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            
            ui_view_indicator_events.isHidden = true
            ui_view_indicator_discover.isHidden = false
            self.showHideFilterView(isHidden: false)
        }
        self.ui_tableview.reloadData()
    }
    
    func showHideFilterView(isHidden:Bool) {
        ui_view_filter_button.isHidden = isHidden
        if isHidden {
            ui_tableview.contentInset = UIEdgeInsets(top: viewNormalHeight ,left: 0,bottom: 0,right: 0)
            ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: viewNormalHeight ,left: 0,bottom: 0,right: 0)
        }
        else {
            ui_tableview.contentInset = UIEdgeInsets(top: viewNormalHeight + ui_view_filter_button.frame.height ,left: 0,bottom: 0,right: 0)
            ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: viewNormalHeight + ui_view_filter_button.frame.height ,left: 0,bottom: 0,right: 0)
        }
    }
    
    func gotoTop(isAnimated:Bool = true) {
        if isEventSelected && myEvents.count == 0 { return }
        else if eventsDiscovered.count == 0 { return }
        
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
        }
    }
    
    func setupViews() {
        ui_label_title.text = "event_main_page_title".localized
        ui_label_events.text = "event_main_page_button_myEvents".localized
        ui_label_discover.text = "event_main_page_button_discover".localized
        
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
        
        ui_view_filter_button.isHidden = true
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
        
        hideEmptyView()
    }
    
    func showEmptyView() {
        if isEventSelected {
            self.ui_view_empty.isHidden = false
            ui_arrow_show_empty.isHidden = false
            self.ui_view_empty_events.isHidden = false
            self.ui_view_empty_discover.isHidden = true
        }
        else {
            
            self.ui_view_empty.isHidden = false
            self.ui_view_empty_events.isHidden = true
            self.ui_view_empty_discover.isHidden = false
            ui_arrow_show_empty.isHidden = false
        }
    }
    
    func hideEmptyView() {
        ui_view_empty.isHidden = true
        ui_arrow_show_empty.isHidden = true
        ui_view_empty_events.isHidden = true
        ui_view_empty_discover.isHidden = true
    }
    
    func showEvent(eventId:Int, isAfterCreation:Bool = false, event:Event? = nil) {
        
        Logger.print("**** Show event : \(event)")
        self.showWIP(parentVC: self)
        
        //TODO: a faire lorsque l'on aura le détail d'un event ;)
    }
}

//MARK: - Tableview datasource / delegate -
extension EventMainHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isEventSelected && myEvents.isEmpty && !isfirstLoadingMyEvents) || (!isEventSelected && eventsDiscovered.isEmpty) {
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var event:Event? = nil
        
        if isEventSelected {
            if let _event = myEventsExtracted.events[indexPath.row] as? Event {
                event = _event
                //TODO: show edit Et suppress apres tests
                if event?.author?.uid == UserDefaults.currentUser?.sid {
                   
                    if let vc = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventEditVCMain") as? EventEditMainViewController {
                        vc.eventId = _event.uid
                        vc.currentEvent = _event
                        vc.modalPresentationStyle = .fullScreen
                        self.tabBarController?.present(vc, animated: true, completion: nil)
                        return
                    }
                }
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
            Logger.print("***** Last index = \(lastIndex)")
            if indexPath.row == lastIndex && (self.myEventsExtracted.events.count - myEventsExtracted.datesSections) >= (numberOfItemsForWS * currentPageMy) {
                self.currentPageMy = self.currentPageMy + 1
                Logger.print("***** on lance le reload \(indexPath.row)")
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
