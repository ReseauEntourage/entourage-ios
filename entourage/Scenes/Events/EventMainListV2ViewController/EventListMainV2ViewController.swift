//
//  EventListMainV2ViewController.swift
//  entourage
//
//  Created by Clement entourage on 18/09/2023.
//

import Foundation
import UIKit
import SDWebImage

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
    private let numberOfItemsForWS = 7
    private var currentFilter = EventActionLocationFilters()
    private var tableDTO = [EventListTableDTO]()
    private var discoverEvent = [Event]()
    private var myEvent = [Event]()
    private var isFromFilter = false
    private var nbOfItemsBeforePagingReload = 5
    private var isLoading = false
    private var isOnlyDiscoverPagination = false
    var pullRefreshControl = UIRefreshControl()
    var isEndOfDiscoverList = false
    var isEndOfMyEventList = false

    
    override func viewDidLoad() {
        //Title
        self.ui_title_label.text = "tabbar_events".localized
        //Table View
        self.ui_table_view.delegate = self
        self.ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: EventListCell.identifier, bundle: nil), forCellReuseIdentifier: EventListCell.identifier)
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
        deployButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadForInit()
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
        self.currentPageMy = 0
        self.currentPageDiscover = 0
        self.isEndOfDiscoverList = false
        self.isEndOfMyEventList = false
        self.myEvent.removeAll()
        self.discoverEvent.removeAll()
        isFromFilter = false
        self.getDiscoverEvent()
    }
    
    func loadForFilter(){
        isLoading = true
        isFromFilter = true
        self.isEndOfDiscoverList = false
        self.discoverEvent.removeAll()
        self.currentPageDiscover = 0
        self.getDiscoverEvent()
    }
    
    func loadForPaginationDiscover(){
        isLoading = true
        self.currentPageDiscover += 1
        self.isOnlyDiscoverPagination = true
        self.getDiscoverEvent()
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
    }
    
    @IBAction func OnFilterClick(_ sender: Any) {
        if let vc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "event_filters") as? EventFiltersViewController {
            AnalyticsLoggerManager.logEvent(name: Event_action_filter)
            vc.currentFilter = self.currentFilter
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            self.navigationController?.present(vc, animated: true)
        }
    }
    @IBAction func OnBtnNewClick(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Event_action_create)
        let navVC = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    @IBAction func OnExpandedFloatingButtonClick(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Event_action_create)
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
            if self.ui_table_view.contentOffset.y <= 0.0 {
                UIView.animate(withDuration: 0.3) {
                    self.deployButton()
                    self.ui_top_contrainst_table_view.constant = 100
                    self.ui_title_label.font = ApplicationTheme.getFontQuickSandBold(size: 24)
                    self.ui_contraint_title.constant = 20

                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.retractButton()
                    self.ui_top_contrainst_table_view.constant = 60
                    self.ui_title_label.font = ApplicationTheme.getFontQuickSandBold(size: 18)
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
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "EventListCollectionTableViewCell") as? EventListCollectionTableViewCell{
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(events: self.myEvent)
                return cell
            }
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
            return 200
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
                self.discoverEvent.append(contentsOf: _events)
            }else if let _error = error {
                //TODO ERROR Trigger warning
            }
            self.getMyEvent()
        }
    }
    
    func getMyEvent(){
        if isEndOfMyEventList {
            return
        }
        EventService.getAllEventsForUser(currentPage: currentPageMy, per: numberOfItemsForWS) { events, error in
            
            if(self.isFromFilter){
                self.isFromFilter = false
                self.configureDTO()
                return
            }
            if(self.isOnlyDiscoverPagination){
                self.isOnlyDiscoverPagination = false
                self.configureDTO()
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
            self.configureDTO()
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
    func goToMyEvent(event: Event) {
        self.showEvent(eventId: event.uid, event: event)
    }
    
    func paginateForMyEvent() {
        self.loadForMyEventPagination()
    }
}

extension EventListMainV2ViewController{
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


