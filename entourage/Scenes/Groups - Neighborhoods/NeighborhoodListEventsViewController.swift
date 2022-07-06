//
//  NeighborhoodListEventsViewController.swift
//  entourage
//
//  Created by Jerome on 05/07/2022.
//

import UIKit

struct MonthYearKey:Hashable {
    var monthId:Int = 0
    var dateString:String = ""
}


class NeighborhoodListEventsViewController: UIViewController {
    
    @IBOutlet weak var ui_button_add: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    var neighborhood:Neighborhood? = nil
    
    var eventsSorted = [Dictionary<MonthYearKey, [Event]>.Element]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "event_group_title_list".localized, titleFont: ApplicationTheme.getFontCourantBoldNoir().font, titleColor: ApplicationTheme.getFontCourantBoldNoir().color, imageName: nil, backgroundColor: .appBeigeClair, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil,subtitle: neighborhood?.name)
        
        
        ui_tableview.register(UINib(nibName: EventListCell.identifier, bundle: nil), forCellReuseIdentifier: EventListCell.identifier)
        
        if neighborhood?.isMember ?? false {
            ui_button_add.isHidden = false
        }
        else {
            ui_button_add.isHidden = true
        }
        
        //Notif for updating when create new Event + Show Detail event
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreateEvent), name: NSNotification.Name(rawValue: kNotificationEventCreateEnd), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNewEvent(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewEvent), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getEvents()
    }
    
    // Actions
    @objc func showNewEvent(_ notification:Notification) {
        if let eventId = notification.userInfo?[kNotificationEventShowId] as? Int {
            Logger.print("***** ShowNewEvent  : \(eventId)")
            //TODO: afficher détail de
            self.showWIP(parentVC: self)
        }
    }
    
    @objc private func updateFromCreateEvent() {
        getEvents()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getEvents() {
        guard let neighborhood = neighborhood else {
            self.goBack()
            return
        }
        EventService.getAllEventsForNeighborhoodId(neighborhood.uid) { events, error in
            if let events = events {
                let groupDic = Dictionary(grouping: events.sorted(by: {$0.getStartEndDate().startDate < $1.getStartEndDate().startDate})) { (event) -> MonthYearKey in
                    
                    let date = Calendar.current.dateComponents([.year, .month], from: (event.getStartEndDate().startDate))
                    
                    guard let month = date.month, let year = date.year else { return MonthYearKey(monthId: 0, dateString: "-")}
                    
                    let df = DateFormatter()
                    df.locale = Locale.getPreferredLocale()
                    let monthLiterral = df.standaloneMonthSymbols[month - 1].localizedCapitalized
                    
                    return MonthYearKey(monthId: month, dateString: "\(monthLiterral) \(year)")
                }
                
                self.eventsSorted.removeAll()
                self.eventsSorted = groupDic.sorted { $0.key.monthId < $1.key.monthId}
                
                self.ui_tableview.reloadData()
            }
        }
    }
    
    @IBAction func action_create_event(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        vc.parentController = self.navigationController
        vc.modalPresentationStyle = .fullScreen
        vc.isFromNeighborhood = true
        vc.currentNeighborhoodId = neighborhood?.uid
        self.navigationController?.present(vc, animated: true)
    }
}

//MARK: - Tableview Datasource / delegate -
extension NeighborhoodListEventsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventsSorted.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsSorted[section].value.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostTitleDate", for: indexPath) as! NeighborhoodPostHeadersCell
            
            cell.populateCell(title: eventsSorted[indexPath.section].key.dateString, isTopHeader: false)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EventListCell.identifier, for: indexPath) as! EventListCell
        
        var hideSeparator = false
        if indexPath.row == eventsSorted[indexPath.section].value.count {
            hideSeparator = true
        }
        
        cell.populateCell(event: eventsSorted[indexPath.section].value[indexPath.row - 1], hideSeparator: hideSeparator)
        return cell
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodListEventsViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
