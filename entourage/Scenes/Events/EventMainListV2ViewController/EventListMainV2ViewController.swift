//
//  EventListMainV2ViewController.swift
//  entourage
//
//  Created by Clement entourage on 18/09/2023.
//

import Foundation
import UIKit
import SDWebImage
import IHProgressHUD


private enum EventListTableDTO{
    case firstHeader
    case myEventCell
    case secondHeader
    case discoverEventCell(event:Event)
    case emptyCell
}

class EventListMainV2ViewController:UIViewController{
    
    //OUTLET
    @IBOutlet weak var ui_btn_filter: UIButton!
    
    @IBOutlet weak var ui_contraint_title: NSLayoutConstraint!
    @IBOutlet weak var ui_top_contrainst_table_view: NSLayoutConstraint!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var expandedfloatingButton: UIButton!
    @IBOutlet weak var ui_location_filter: UILabel!
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ui_table_view: UITableView!
    //VAR
    private var currentPageMy = 0
    private var currentPageDiscover = 0
    private let numberOfItemsForWS = 10
    private var currentFilter = EventActionLocationFilters()
    private var tableDTO = [EventListTableDTO]()
    private var discoverEvent = [Event]()
    private var myEvent = [Event]()
    private var isFromFilter = false
    private var nbOfItemsBeforePagingReload = 2
    private var isLoading = false
    private var isOnlyDiscoverPagination = false
    var pullRefreshControl = UIRefreshControl()
    var isEndOfDiscoverList = false
    var isEndOfMyEventList = false
    var comeFromDetail = false
    
    override func viewDidLoad() {

        NotificationCenter.default.addObserver(self, selector: #selector(showNewEvent(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewEvent), object: nil)

        //Title
        self.ui_title_label.text = "tabbar_events".localized
        //Table View
        self.ui_table_view.delegate = self
        self.ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: EventListCell.identifier, bundle: nil), forCellReuseIdentifier: EventListCell.identifier)
        ui_table_view.register(UINib(nibName: HomeEventHorizontalCollectionCell.identifier, bundle: nil), forCellReuseIdentifier: HomeEventHorizontalCollectionCell.identifier)
        ui_table_view.register(UINib(nibName: DividerCell.identifier, bundle: nil), forCellReuseIdentifier: DividerCell.identifier)
        ui_table_view.register(UINib(nibName: EventListCollectionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: EventListCollectionTableViewCell.identifier)
        ui_table_view.register(UINib(nibName: EmptyListCell.identifier, bundle: nil), forCellReuseIdentifier: EmptyListCell.identifier)
        //Btn filter
        ui_location_filter.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: UIColor.appOrange))
        ui_location_filter.text = currentFilter.getFilterButtonString()
        //Pull to refresh
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_table_view.refreshControl = pullRefreshControl
        expandedfloatingButton.setTitle("event_title_btn_create_event".localized, for: .normal)
        deployButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsLoggerManager.logEvent(name: View__Event__List)
        if !comeFromDetail {
            loadForInit()
        }
        comeFromDetail = false
    }
    
    func retractButton() {
        self.floatingButton.isHidden = false
        self.expandedfloatingButton.isHidden = true
    }

    func deployButton() {
        self.floatingButton.isHidden = true
        self.expandedfloatingButton.isHidden = false
    }
    
    func loadForInit(){
        isLoading = true
        IHProgressHUD.show()
        if(!isFromFilter){
            currentFilter = EventActionLocationFilters()
        }
        ui_location_filter.text = currentFilter.getFilterButtonString()
        self.currentPageMy = 0
        self.currentPageDiscover = 0
        self.isEndOfDiscoverList = false
        self.isEndOfMyEventList = false
        self.myEvent.removeAll()
        self.discoverEvent.removeAll()
        self.isOnlyDiscoverPagination = false
        isFromFilter = false
        self.getMyEvent()
    }
    
    func loadForFilter(){
        isLoading = true
        isFromFilter = true
        self.isEndOfDiscoverList = false
        self.discoverEvent.removeAll()
        self.currentPageDiscover = 0
        self.getMyEvent()
    }
    
    func loadForPaginationDiscover(){
        isLoading = true
        self.currentPageDiscover += 1
        self.isOnlyDiscoverPagination = true
        self.getMyEvent()

    }
    
    func loadForMyEventPagination(){
        isLoading = true
        self.currentPageMy += 1
        self.getMyEvent()
    }
    
    @objc func refreshDatas() {
        loadForInit()
    }
    
    func configureDTO(){
        tableDTO.removeAll()
        if myEvent.count > 0 {
            tableDTO.append(.firstHeader)
            tableDTO.append(.myEventCell)
        }
        if discoverEvent.count > 0 {
            tableDTO.append(.secondHeader)
            for event in discoverEvent{
                tableDTO.append(.discoverEventCell(event: event))
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
    @objc func showNewEvent(_ notification:Notification) {
        if let eventId = notification.userInfo?[kNotificationEventShowId] as? Int {
            DispatchQueue.main.async {
                self.showEvent(eventId: eventId, isAfterCreation: true)
            }
        }
    }
    
    @IBAction func OnFilterClick(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action__Event__LocationFilter)
        if let vc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "event_filters") as? EventFiltersViewController {
            vc.currentFilter = self.currentFilter
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            self.navigationController?.present(vc, animated: true)
        }
    }
    @IBAction func OnBtnNewClick(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action__Event__New)
        let navVC = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    @IBAction func OnExpandedFloatingButtonClick(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action__Event__New)
        let navVC = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
}

//MARK: Tableview delegates
extension EventListMainV2ViewController:UITableViewDelegate, UITableViewDataSource{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        DispatchQueue.main.async {
            let yOffset = self.ui_table_view.contentOffset.y
            if yOffset > 0 {
                if yOffset <= 100 {
                    // Interpolation linéaire pour ajuster la taille de la police en fonction du déplacement
                    let fontSize = 24 - (yOffset / 100) * (24 - 18)
                    self.ui_title_label.font = ApplicationTheme.getFontQuickSandBold(size: fontSize)
                    self.deployButton()
                    // Ajustez les autres éléments en fonction du déplacement également, si nécessaire
                    self.ui_top_contrainst_table_view.constant = 100 - 0.4 * yOffset
                    self.ui_contraint_title.constant = 20 - 0.1 * yOffset
                    self.view.layoutIfNeeded()

                } else if yOffset > 100 {
                    // Réglez sur les valeurs minimales si le déplacement dépasse 100
                    self.retractButton()
                    self.ui_title_label.font = ApplicationTheme.getFontQuickSandBold(size: 18)
                    self.ui_top_contrainst_table_view.constant = 60
                    self.ui_contraint_title.constant = 10
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
                cell.configure(title: "my_event_title".localized)
                return cell
            }
        case .myEventCell:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeEventHorizontalCollectionCell") as? HomeEventHorizontalCollectionCell{
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(events: self.myEvent)
                return cell
            }
//            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "EventListCollectionTableViewCell") as? EventListCollectionTableViewCell{
//                cell.selectionStyle = .none
//                cell.delegate = self
//                cell.configure(events: self.myEvent)
//                return cell
//            }
        case .secondHeader:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "DividerCell") as? DividerCell{
                cell.selectionStyle = .none
                cell.configure(title: "all_event_title".localized)
                return cell
            }
        case .discoverEventCell(let event):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "EventListCell") as? EventListCell{
                cell.selectionStyle = .none
                cell.populateCell(event: event, hideSeparator: true)
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
        let lastIndex = discoverEvent.count - nbOfItemsBeforePagingReload
        if indexPath.row == lastIndex {
            self.loadForPaginationDiscover()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row]{
        case .firstHeader:
            return UITableView.automaticDimension
        case .myEventCell:
            return 215
        case .secondHeader:
            return UITableView.automaticDimension
        case .discoverEventCell(_):
            return UITableView.automaticDimension
        case .emptyCell:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
            
        case .firstHeader:
            return
        case .myEventCell:
            return
        case .secondHeader:
            return
        case .discoverEventCell(let event):
            self.showEvent(eventId: event.uid,event: event)
        case .emptyCell:
            return
        }
    }
}



extension EventListMainV2ViewController{
    
    func getDiscoverEvent(){
        if isEndOfDiscoverList {
            return
        }
        EventService.getAllEventsDiscover(currentPage: currentPageDiscover, per: numberOfItemsForWS, filters: currentFilter.getfiltersForWS()) { events, error in
            if let _events = events{
                if _events.count < self.numberOfItemsForWS{
                    self.isEndOfDiscoverList = true
                }
                print("eho event size " , events?.count)
                
                // Filtrer les événements pour ne pas ajouter de doublons
                let uniqueEvents = _events.filter { newEvent in
                    !self.discoverEvent.contains { existingEvent in
                        existingEvent.uid == newEvent.uid
                    }
                }
                
                self.discoverEvent.append(contentsOf: uniqueEvents)
                self.configureDTO()
                self.isLoading = false
            } else if let _error = error {
                //TODO ERROR Trigger warning
            }
            self.configureDTO()
        }
    }
    
    func getMyEvent(){
        if isEndOfMyEventList {
            self.getDiscoverEvent()
            return
        }
        EventService.getAllEventsForUser(currentPage: currentPageMy, per: 50) { events, error in
            
            if(self.isFromFilter){
                self.isFromFilter = false
                self.getDiscoverEvent()
                return
            }
            if(self.isOnlyDiscoverPagination){
                self.isOnlyDiscoverPagination = false
                self.getDiscoverEvent()
                return
            }
            
            if let _events = events{
                if _events.count < self.numberOfItemsForWS{
                    self.isEndOfMyEventList = true
                    
                }
                self.myEvent.append(contentsOf: _events)
            }else if let _error = error {
                //TODO ERROR Trigger warning
            }
            self.getDiscoverEvent()
        }
        
    }
}

//MARK: here handle filter return data
extension EventListMainV2ViewController:EventFiltersDelegate {
    func updateFilters(_ filters: EventActionLocationFilters) {
        self.currentFilter = filters
        ui_location_filter.text = currentFilter.getFilterButtonString()
        self.isFromFilter = true
    }
}

//MARK: Here handle pagination for collectionview
extension EventListMainV2ViewController:EventListCollectionTableViewCellDelegate{
    func goToMyGroup(group: Neighborhood) {
        //Nothing to do
    }
    
    func goToMyEvent(event: Event) {
        self.showEvent(eventId: event.uid, event: event)
    }
    
    func paginateForMyEvent() {
        self.loadForMyEventPagination()
    }
}

extension EventListMainV2ViewController{
    func showEvent(eventId:Int, isAfterCreation:Bool = false, event:Event? = nil) {
        comeFromDetail = true
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


extension EventListMainV2ViewController:HomeEventHCCDelegate{
    func goToMyEventHomeCell(event: Event) {
        showEvent(eventId: event.uid)
    }
}
