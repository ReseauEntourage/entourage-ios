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
    @IBOutlet weak var ui_btn_filter: UIButton!
    @IBOutlet weak var ui_contraint_title: NSLayoutConstraint!
    @IBOutlet weak var ui_top_contrainst_table_view: NSLayoutConstraint!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var expandedfloatingButton: UIButton!
    @IBOutlet weak var ui_location_filter: UILabel!
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ui_table_view: UITableView!

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

        // Btn filter
        ui_location_filter.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: UIColor.appOrange))
        ui_location_filter.text = currentFilter.getFilterButtonString()

        // Pull to refresh
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_table_view.refreshControl = pullRefreshControl

        expandedfloatingButton.setTitle("event_title_btn_create_event".localized, for: .normal)
        deployButton()
        configureUserLocationAndRadius()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        ui_location_filter.text = currentFilter.getFilterButtonString()
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
        tableDTO.append(.filterCell(numberOfFilter: self.numberOfFilters))
        if mode == .searching {
            searchEvent.append(contentsOf: self.myEvent)
            searchEvent.append(contentsOf: self.discoverEvent)
            if searchEvent.count > 0 {
                for event in searchEvent {
                    tableDTO.append(.discoverEventCell(event: event))
                }
            } else {
                tableDTO.append(.emptyCell)
            }
        } else {
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
        }

        self.ui_table_view.reloadData()
        self.pullRefreshControl.endRefreshing()
        isLoading = false
        IHProgressHUD.dismiss()
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
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
}

// MARK: Tableview delegates
extension EventListMainV2ViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            let yOffset = self.ui_table_view.contentOffset.y
            if yOffset > 0 {
                if yOffset <= 100 {
                    let fontSize = 24 - (yOffset / 100) * (24 - 18)
                    self.ui_title_label.font = ApplicationTheme.getFontQuickSandBold(size: fontSize)
                    self.deployButton()
                    self.ui_top_contrainst_table_view.constant = 100 - 0.4 * yOffset
                    self.ui_contraint_title.constant = 20 - 0.1 * yOffset
                    self.view.layoutIfNeeded()
                } else if yOffset > 100 {
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
                cell.configure(selected: numberOfFilter != 0, numberOfFilter: self.numberOfFilters, mod: .event)
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
}

extension EventListMainV2ViewController {
    func getDiscoverEvent() {
        if isEndOfDiscoverList {
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
        if isEndOfMyEventList {
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
            self.discoverEvent.append(contentsOf: uniqueEvents)
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
            self.myEvent.append(contentsOf: _events)
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
        ui_location_filter.text = currentFilter.getFilterButtonString()
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
    func didUpdateText(text: String) {
        searchText = text
        if searchText.isEmpty {
            mode = .normal
        } else {
            mode = .searching
        }
        loadForInit()
    }
    
    func didClickButton() {
        self.showFilter()
    }
}

extension EventListMainV2ViewController: MainFilterDelegate {
    func didUpdateFilter(selectedItems: [String: Bool], radius: Float?, coordinate: CLLocationCoordinate2D?, adressTitle: String) {
        let selectedCount = selectedItems.values.filter { $0 }.count
        self.numberOfFilters = selectedCount
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
