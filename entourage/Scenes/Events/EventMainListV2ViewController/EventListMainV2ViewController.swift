import Foundation
import UIKit
import SDWebImage
import IHProgressHUD
import MapKit

private enum EventListTableDTO {
    case filterCell(numberOfFilter: Int)
    case firstHeader
    case myEventCell
    case secondHeader
    case discoverEventCell(event: Event)
    case emptyCell
}

enum ViewMode {
    case normal
    case filtered
    case searching
}

class EventListMainV2ViewController: UIViewController {

    // OUTLET
    @IBOutlet weak var ui_contraint_title: NSLayoutConstraint!
    @IBOutlet weak var ui_top_contrainst_table_view: NSLayoutConstraint!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var expandedfloatingButton: UIButton!
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_tableview_contraint_top: NSLayoutConstraint!
    
    @IBOutlet weak var uiBtnSearch: UIView!
    @IBOutlet weak var uiBtnFilter: UIView!
    @IBOutlet weak var ui_tv_number_of_filter: UILabel!
    // VAR
    private var currentPageMy = 0
    private var currentPageDiscover = 0
    private let numberOfItemsForWS = 10
    private var currentFilter = EventActionLocationFilters()
    private var tableDTO = [EventListTableDTO]()
    private var discoverEvent = [Event]()
    private var myEvent = [Event]()
    private var searchEvent = [Event]()
    private var isFromFilter = false
    private var nbOfItemsBeforePagingReload = 2
    private var isLoading = false
    private var isOnlyDiscoverPagination = false
    var pullRefreshControl = UIRefreshControl()
    var isEndOfDiscoverList = false
    var isEndOfMyEventList = false
    var comeFromDetail = false
    var numberOfFilters = 0
    var selectedItemsFilter = [String: Bool]()
    var selectedAddress: String = ""
    var selectedRadius: Float = 0
    var selectedCoordinate: CLLocationCoordinate2D?
    private var searchText = ""
    private var mode: ViewMode = .normal
    private var isSearching = false
    private var startSearching = false
    private var isFromSearch = false
    
    private var filterCell: CellMainFilter?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(showNewEvent(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewEvent), object: nil)

        // Title
        self.ui_title_label.text = "tabbar_events".localized

        // Table View
        self.ui_table_view.delegate = self
        self.ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: EventListCell.identifier, bundle: nil), forCellReuseIdentifier: EventListCell.identifier)
        ui_table_view.register(UINib(nibName: HomeEventHorizontalCollectionCell.identifier, bundle: nil), forCellReuseIdentifier: HomeEventHorizontalCollectionCell.identifier)
        ui_table_view.register(UINib(nibName: DividerCell.identifier, bundle: nil), forCellReuseIdentifier: DividerCell.identifier)
        ui_table_view.register(UINib(nibName: EventListCollectionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: EventListCollectionTableViewCell.identifier)
        ui_table_view.register(UINib(nibName: EmptyListCell.identifier, bundle: nil), forCellReuseIdentifier: EmptyListCell.identifier)
        ui_table_view.register(UINib(nibName: CellMainFilter.identifier, bundle: nil), forCellReuseIdentifier: CellMainFilter.identifier)

        // Pull to refresh
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_table_view.refreshControl = pullRefreshControl

        expandedfloatingButton.setTitle("event_title_btn_create_event".localized, for: .normal)
        deployButton()
        configureUserLocationAndRadius()
        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(onSearchClick))
        uiBtnSearch.addGestureRecognizer(searchTapGesture)

        let filterTapGesture = UITapGestureRecognizer(target: self, action: #selector(onFilterClick))
        uiBtnFilter.addGestureRecognizer(filterTapGesture)
        //Confguration Post onboarding
        configurePostOnboarding()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showHighlightOverlay(targetView: self.uiBtnFilter, withBubbleText: "Des filtres ont été appliqués en fonction de vos préférences. Cliquez ici pour les modifier.")
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsLoggerManager.logEvent(name: View__Event__List)
        if !comeFromDetail {
            loadForInit()
        }
        if isFromSearch {
            isFromSearch = false
            if let filterCellIndexPath = getFilterCellIndexPath(), let filterCell = ui_table_view.cellForRow(at: filterCellIndexPath) as? CellMainFilter {
                filterCell.ui_textfield.becomeFirstResponder()
            }
        }

        comeFromDetail = false
    }
    
    private func configurePostOnboarding(){
        if OnboardingEndChoicesManager.shared.categoryForButton == "event" {
            numberOfFilters = EnhancedOnboardingConfiguration.shared.numberOfFilterForEvent.count
            EnhancedOnboardingConfiguration.shared.numberOfFilterForEvent.forEach { id in
                selectedItemsFilter[id] = true
            }
            if numberOfFilters > 0 {
                self.ui_tv_number_of_filter.text = String(numberOfFilters)
                self.ui_tv_number_of_filter.isHidden = false
            } else {
                self.ui_tv_number_of_filter.isHidden = true
            }
            OnboardingEndChoicesManager.shared.categoryForButton = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showHighlightOverlay(targetView: self.uiBtnFilter, withBubbleText: "Des filtres ont été appliqués en fonction de vos préférences. Cliquez ici pour les modifier.")
            }
        }
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
        if isSearching {
            mode = .searching
            ui_tableview_contraint_top.constant = 20
            if let tabBarController = self.tabBarController as? MainTabbarViewController {
                tabBarController.setTabBar(hidden: true, animated: true, duration: 0.3)
            }
        } else {
            if let tabBarController = self.tabBarController as? MainTabbarViewController {
                tabBarController.setTabBar(hidden: false, animated: true, duration: 0.3)
            }
            if numberOfFilters == 0 {
                mode = .normal
                ui_tableview_contraint_top.constant = 100
            } else {
                mode = .filtered
                ui_tableview_contraint_top.constant = 100
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.loadForInit()
        }
    }

    func retractButton() {
        self.floatingButton.isHidden = false
        self.expandedfloatingButton.isHidden = true
    }

    func deployButton() {
        self.floatingButton.isHidden = true
        self.expandedfloatingButton.isHidden = false
    }

    func configureUserLocationAndRadius() {
        if let user = UserDefaults.currentUser {
            self.selectedRadius = Float(user.radiusDistance ?? 40)
            self.selectedCoordinate = CLLocationCoordinate2D(latitude: user.addressPrimary?.latitude ?? 0, longitude: user.addressPrimary?.longitude ?? 0)
            self.selectedAddress = user.addressPrimary?.displayAddress ?? ""
        }
    }

    func loadForInit() {
        isLoading = true
        IHProgressHUD.show()
        if !isFromFilter {
            currentFilter = EventActionLocationFilters()
        }
        self.currentPageMy = 0
        self.currentPageDiscover = 0
        self.isEndOfDiscoverList = false
        self.isEndOfMyEventList = false
        self.myEvent.removeAll()
        self.discoverEvent.removeAll()
        self.searchEvent.removeAll()
        self.isOnlyDiscoverPagination = false
        isFromFilter = false
        self.getMyEvent()
    }

    func loadForFilter() {
        isLoading = true
        isFromFilter = true
        self.isEndOfDiscoverList = false
        self.isEndOfMyEventList = false
        if self.numberOfFilters > 0 {
            self.mode = .filtered
        } else {
            self.mode = .normal
        }
        self.discoverEvent.removeAll()
        self.currentPageDiscover = 0
        self.myEvent.removeAll() // Ensure myEvent is cleared when filtering
        self.currentPageMy = 0 // Reset current page for my events
        self.getMyEvent()
    }

    func loadForPaginationDiscover() {
        isLoading = true
        self.currentPageDiscover += 1
        self.isOnlyDiscoverPagination = true
        self.getMyEvent()
    }

    func loadForMyEventPagination() {
        isLoading = true
        self.currentPageMy += 1
        self.getMyEvent()
    }

    @objc func refreshDatas() {
        loadForInit()
    }

    func configureDTO() {
        tableDTO.removeAll()
        
        switch mode {
        case .normal:
            if myEvent.count > 0 {
                tableDTO.append(.firstHeader)
                tableDTO.append(.myEventCell)
            }
            if discoverEvent.count > 0 {
                tableDTO.append(.secondHeader)
                for event in discoverEvent {
                    tableDTO.append(.discoverEventCell(event: event))
                }
            } else {
                tableDTO.append(.secondHeader)
                tableDTO.append(.emptyCell)
            }
        case .filtered:
            if myEvent.count > 0 {
                tableDTO.append(.firstHeader)
                tableDTO.append(.myEventCell)
            }
            if discoverEvent.count > 0 {
                tableDTO.append(.secondHeader)
                for event in discoverEvent {
                    tableDTO.append(.discoverEventCell(event: event))
                }
            } else {
                tableDTO.append(.secondHeader)
                tableDTO.append(.emptyCell)
            }
        case .searching:
            if searchEvent.count > 0 {
                for event in searchEvent {
                    tableDTO.append(.discoverEventCell(event: event))
                }
            } else {
                tableDTO.append(.emptyCell)
            }
        }
        
        if isSearching && startSearching {
            self.ui_table_view.reloadData()
        } else if isSearching {
            let sectionToReload = IndexSet(integer: 1)
            self.ui_table_view.reloadSections(sectionToReload, with: .automatic)
        } else {
            self.ui_table_view.reloadData()
        }

        self.pullRefreshControl.endRefreshing()
        isLoading = false
        IHProgressHUD.dismiss()
        if self.startSearching {
            self.startSearching = false
            if let filterCellIndexPath = getFilterCellIndexPath(), let filterCell = ui_table_view.cellForRow(at: filterCellIndexPath) as? CellMainFilter {
                filterCell.ui_textfield.becomeFirstResponder()
            }
        }
    }

    @objc func showNewEvent(_ notification: Notification) {
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

    func showFilter() {
        let sb = UIStoryboard.init(name: StoryboardName.filterMain, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MainFilter") as? MainFilter {
            vc.mod = .event
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

// MARK: Tableview delegates
extension EventListMainV2ViewController: UITableViewDelegate, UITableViewDataSource {
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
                cell.configure(selected: numberOfFilters != 0, numberOfFilter: self.numberOfFilters, mod: .event, isSearching: self.mode == .searching)
                return cell
            }
        }
        
        switch tableDTO[indexPath.row] {
        case .firstHeader:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "DividerCell") as? DividerCell {
                cell.selectionStyle = .none
                cell.configure(title: "my_event_title".localized)
                return cell
            }
        case .myEventCell:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "HomeEventHorizontalCollectionCell") as? HomeEventHorizontalCollectionCell {
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(events: self.myEvent)
                return cell
            }
        case .secondHeader:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "DividerCell") as? DividerCell {
                cell.selectionStyle = .none
                cell.configure(title: "all_event_title".localized)
                return cell
            }
        case .discoverEventCell(let event):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "EventListCell") as? EventListCell {
                cell.selectionStyle = .none
                cell.populateCell(event: event, hideSeparator: true)
                return cell
            }
        case .emptyCell:
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "EmptyListCell") as? EmptyListCell {
                cell.selectionStyle = .none
                return cell
            }
        case .filterCell(let numberOfFilter):
            if let cell = ui_table_view.dequeueReusableCell(withIdentifier: "CellMainFilter") as? CellMainFilter {
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(selected: numberOfFilter != 0, numberOfFilter: self.numberOfFilters, mod: .event, isSearching: self.mode == .searching)
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading {
            return
        }
        let lastIndex = discoverEvent.count - nbOfItemsBeforePagingReload
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
        case .myEventCell:
            return 215
        case .secondHeader:
            return UITableView.automaticDimension
        case .discoverEventCell(_):
            return UITableView.automaticDimension
        case .emptyCell:
            return UITableView.automaticDimension
        case .filterCell(numberOfFilter: let numberOfFilter):
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching && indexPath.section == 0 {
            return
        }
        
        switch tableDTO[indexPath.row] {
        case .firstHeader:
            return
        case .myEventCell:
            return
        case .secondHeader:
            return
        case .discoverEventCell(let event):
            self.showEvent(eventId: event.uid, event: event)
        case .emptyCell:
            return
        case .filterCell(_):
            return
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.mode == .searching && scrollView.contentOffset.y <= -500 {
            if let filterCellIndexPath = getFilterCellIndexPath(), let filterCell = ui_table_view.cellForRow(at: filterCellIndexPath) as? CellMainFilter {
                filterCell.ui_textfield.becomeFirstResponder()
            }
        } else {
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

extension EventListMainV2ViewController {
    func getDiscoverEvent() {
        if isEndOfDiscoverList && self.mode != .searching {
            return
        }
        switch mode {
        case .normal, .filtered:
            let selectedItemsList = selectedItemsFilter.filter { $0.value }.map { $0.key }
            EventService.getSuggestFilteredEvents(
                currentPage: currentPageDiscover,
                per: numberOfItemsForWS,
                radius: self.selectedRadius,
                latitude: Float(self.selectedCoordinate?.latitude ?? 0.0),
                longitude: Float(self.selectedCoordinate?.longitude ?? 0.0),
                selectedItem: selectedItemsList
            ) { events, error in
                self.handleDiscoverEventResponse(events: events, error: error)
            }
        case .searching:
            EventService.searchEvents(query: searchText, currentPage: currentPageDiscover, per: numberOfItemsForWS) { events, error in
                self.handleDiscoverEventResponse(events: events, error: error)
            }
        }
    }

    func getMyEvent() {
        if isEndOfMyEventList && self.mode != .searching {
            self.getDiscoverEvent()
            return
        }
        let userId = UserDefaults.currentUser?.sid ?? 0
        switch mode {
        case .normal:
            EventService.getAllEventsForUser(currentPage: currentPageMy, per: numberOfItemsForWS) { events, error in
                self.handleMyEventResponse(events: events, error: error)
            }
        case .filtered:
            let selectedItemsList = selectedItemsFilter.filter { $0.value }.map { $0.key }
            EventService.getFilteredMyEvents(
                userId: userId,
                currentPage: currentPageMy,
                per: numberOfItemsForWS,
                radius: self.selectedRadius,
                latitude: Float(self.selectedCoordinate?.latitude ?? 0.0),
                longitude: Float(self.selectedCoordinate?.longitude ?? 0.0),
                selectedItem: selectedItemsList
            ) { events, error in
                self.handleMyEventResponse(events: events, error: error)
            }
        case .searching:
            self.getDiscoverEvent()
        }
    }

    private func handleDiscoverEventResponse(events: [Event]?, error: EntourageNetworkError?) {
        if let _events = events {
            if _events.count < self.numberOfItemsForWS {
                self.isEndOfDiscoverList = true
            }
            let uniqueEvents = _events.filter { newEvent in
                !self.discoverEvent.contains { existingEvent in
                    existingEvent.uid == newEvent.uid
                }
            }
            switch self.mode {
            case .normal, .filtered:
                self.discoverEvent.append(contentsOf: uniqueEvents)
            case .searching:
                self.searchEvent.append(contentsOf: uniqueEvents)
            }
        } else if let _error = error {
            // TODO: Handle error
        }
        self.configureDTO()
        self.isLoading = false
    }

    private func handleMyEventResponse(events: [Event]?, error: EntourageNetworkError?) {
        if let _events = events {
            if _events.count < self.numberOfItemsForWS {
                self.isEndOfMyEventList = true
            }

            let uniqueEvents = _events.filter { newEvent in
                !self.myEvent.contains { existingEvent in
                    existingEvent.uid == newEvent.uid
                }
            }
            self.myEvent.append(contentsOf: uniqueEvents)
        } else if let _error = error {
            // TODO: Handle error
        }
        self.getDiscoverEvent()
    }
}

// MARK: Extensions for event filters
extension EventListMainV2ViewController: EventFiltersDelegate {
    func updateFilters(_ filters: EventActionLocationFilters) {
        self.currentFilter = filters
        self.isFromFilter = true
        self.loadForFilter()
    }
}

// MARK: Extensions for collection view pagination
extension EventListMainV2ViewController: EventListCollectionTableViewCellDelegate {
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

extension EventListMainV2ViewController {
    func showEvent(eventId: Int, isAfterCreation: Bool = false, event: Event? = nil) {
        comeFromDetail = true
        if self.mode == .searching {
            isFromSearch = true
        }
        if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController {
            vc.eventId = eventId
            vc.event = event
            vc.isAfterCreation = isAfterCreation
            vc.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(navVc, animated: true, completion: nil)
            return
        }
    }
}

extension EventListMainV2ViewController: HomeEventHCCDelegate {
    func goToMyEventHomeCell(event: Event) {
        showEvent(eventId: event.uid)
    }
}

extension EventListMainV2ViewController: CellMainFilterDelegate {
    func shouldCloseSearch() {
        isSearching = false
        searchText = ""
        switchSearchMode()
    }
    
    func didUpdateText(text: String) {
        searchText = text
        self.searchEvent.removeAll()
        self.getMyEvent()  // Met à jour les données en fonction du texte de recherche
    }
    
    func didClickButton() {
        self.showFilter()
    }
}

extension EventListMainV2ViewController: MainFilterDelegate {
    func didUpdateFilter(selectedItems: [String: Bool], radius: Float?, coordinate: CLLocationCoordinate2D?, adressTitle: String) {
        let selectedCount = selectedItems.values.filter { $0 }.count
        self.numberOfFilters = selectedCount
        if numberOfFilters > 0 {
            self.ui_tv_number_of_filter.text = String(numberOfFilters)
            self.ui_tv_number_of_filter.isHidden = false
        } else {
            self.ui_tv_number_of_filter.isHidden = true
        }
        self.selectedItemsFilter = selectedItems
        self.selectedCoordinate = coordinate
        self.selectedRadius = radius ?? 0
        self.selectedAddress = adressTitle
        if selectedCoordinate?.latitude == 0 || selectedCoordinate?.longitude == 0 {
            self.configureUserLocationAndRadius()
        }
        if !tableDTO.isEmpty {
            tableDTO[0] = .filterCell(numberOfFilter: selectedCount)
        }
        let indexPath = IndexPath(row: 0, section: 0)
        self.ui_table_view.reloadRows(at: [indexPath], with: .automatic)
        self.loadForFilter()
    }
}

extension EventListMainV2ViewController {
    func showHighlightOverlay(targetView: UIView, withBubbleText text: String) {
        // Crée l'overlay
        let overlayView = HighlightOverlayView(targetView: targetView)
        overlayView.frame = self.view.bounds

        // Ajoute la bulle
        overlayView.addBubble(with: text, below: targetView)

        // Gérer le clic sur l'overlay pour le retirer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeOverlay(_:)))
        overlayView.addGestureRecognizer(tapGesture)

        // Ajoute l'overlay à la vue principale
        self.view.addSubview(overlayView)
    }

    @objc private func removeOverlay(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
}
