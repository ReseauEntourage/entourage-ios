//
//  WelcomThreeViewController.swift
//  entourage
//
//  Created by Clement entourage on 09/06/2023.
//

import Foundation
import UIKit

protocol WelcomeThreeDelegate {
    
}

enum WelcomeThreeDTO{
    case titleEventCell
    case mainEventTextCell
    case titleDemandCell
    case mainDemandTextCell
    case titleContribCell
    case mainContribTextCell
    case eventCell
    case demandCell
    case secondaryTextCell
    case contribCell
    case blanckCell
}

class WelcomeThreeViewController:UIViewController{
    
    //OUTLET
    @IBOutlet weak var btn_main: UIButton!
    @IBOutlet weak var ui_top_image: UIImageView!
    @IBOutlet weak var btn_close: UIImageView!
    @IBOutlet weak var top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_table_view: UITableView!
    
    var delegate:WelcomeThreeDelegate?
    var tableDTO = [WelcomeThreeDTO]()
    var haveEvents = false
    var haveDemands = false
    var currentFilter = EventActionLocationFilters()
    var currentLocationFilter = EventActionLocationFilters()
    var currentSectionsFilter:Sections = Sections()
    var currentevents = [Event]()
    var currentDemands = [Action]()

    
    override func viewDidLoad() {
        initButton()
        registerCells()
        self.ui_table_view.delegate = self
        self.ui_table_view.dataSource = self
        ui_top_image.isHidden = true
        ui_table_view.backgroundColor = UIColor(named: "orange_tres_tres_clair")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getEventsDiscovered()
    }
    
    private func registerCells(){
        ui_table_view.register(UINib(nibName: WelcomeOneContentMain.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneContentMain.identifier)
        ui_table_view.register(UINib(nibName: WelcomeOneTitleCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneTitleCell.identifier)
        ui_table_view.register(UINib(nibName: SecondaryTextWelcomeCell.identifier, bundle: nil), forCellReuseIdentifier: SecondaryTextWelcomeCell.identifier)
        ui_table_view.register(UINib(nibName: EventListCell.identifier, bundle: nil), forCellReuseIdentifier: EventListCell.identifier)
        ui_table_view.register(UINib(nibName: ActionContribDetailHomeCell.identifier, bundle: nil), forCellReuseIdentifier: ActionContribDetailHomeCell.identifier)
        ui_table_view.register(UINib(nibName: ActionSolicitationDetailHomeCell.identifier, bundle: nil), forCellReuseIdentifier: ActionSolicitationDetailHomeCell.identifier)
        ui_table_view.register(UINib(nibName: WelcomeThreeDemandExampleCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeThreeDemandExampleCell.identifier)

    }
    
    func initButton(){
        btn_close.isUserInteractionEnabled = true
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        btn_close.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func fillDTOWithEvent(){
        self.tableDTO.removeAll()
        self.tableDTO.append(.titleEventCell)
        self.tableDTO.append(.mainEventTextCell)
        self.tableDTO.append(.eventCell)
        if currentevents.count > 2 {
            self.tableDTO.append(.eventCell)
            self.tableDTO.append(.eventCell)
        }else if currentevents.count > 1 {
            self.tableDTO.append(.eventCell)
        }
        self.tableDTO.append(.blanckCell)
        self.ui_table_view.reloadData()
    }
    
    private func fillDTOWithDemand(){
        self.tableDTO.append(.titleDemandCell)
        self.tableDTO.append(.mainDemandTextCell)
        self.tableDTO.append(.demandCell)
        if currentDemands.count > 2 {
            self.tableDTO.append(.demandCell)
            self.tableDTO.append(.demandCell)
        }else if currentDemands.count > 1 {
            self.tableDTO.append(.demandCell)

        }
        self.tableDTO.append(.blanckCell)
        self.ui_table_view.reloadData()
    }
    
    private func fillDTOWithContrib(){
        self.tableDTO.append(.titleContribCell)
        self.tableDTO.append(.mainContribTextCell)
        self.tableDTO.append(.secondaryTextCell)
        self.tableDTO.append(.contribCell)
        self.tableDTO.append(.contribCell)
        self.tableDTO.append(.blanckCell)
        self.ui_table_view.reloadData()
    }
    
    private func setMainButtonWithEvent(){
        self.btn_main.setTitle("welcome_three_mainbutton_event".localized, for: .normal)
        self.btn_main.addTarget(self, action: #selector(onWithEventBtnClick), for: .touchUpInside)
    }
    
    private func setMainButtonWithDemand(){
        self.btn_main.setTitle("welcome_three_mainbutton_demand".localized, for: .normal)
        self.btn_main.addTarget(self, action: #selector(onWithDemandBtnClick), for: .touchUpInside)
    }
    
    private func setMainButtonWithContrib(){
        self.btn_main.setTitle("welcome_three_mainbutton_contrib".localized, for: .normal)
        self.btn_main.addTarget(self, action: #selector(onWithContribBtnClick), for: .touchUpInside)
    }
    
    @objc func onWithEventBtnClick(){
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day5A)
        self.dismiss(animated: true) {
            DeepLinkManager.showDiscoverOutingListUniversalLink()
        }
        
    }
    
    @objc func onWithDemandBtnClick(){
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day5B)
        self.dismiss(animated: true) {
            DeepLinkManager.showSolicitationListUniversalLink()

        }
    }
    
    @objc func onWithContribBtnClick(){
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day5C)
        self.dismiss(animated: true) {
            DeepLinkManager.showContribListUniversalLink()
            DeepLinkManager.showActionNewUniversalLink(isContrib: true)
        }
    }
    
    func showEvent(eventId:Int, event:Event? = nil) {
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day5ACard)

        self.dismiss(animated: true) {
            if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController  {
                vc.eventId = eventId
                vc.event = event
                vc.isAfterCreation = false
                vc.modalPresentationStyle = .fullScreen
                AppState.getTopViewController()?.present(navVc, animated: true)
            }
        }
    }
    
    func showAction(actionId:Int,isContrib:Bool, action:Action? = nil) {
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day5BCard)
        self.dismiss(animated: true) {
            let sb = UIStoryboard.init(name: StoryboardName.actions, bundle: nil)
            if let navVc = sb.instantiateViewController(withIdentifier: "actionDetailFullNav") as? UINavigationController, let vc = navVc.topViewController as? ActionDetailFullViewController {
                vc.actionId = actionId
                vc.action = nil
                vc.isContrib = isContrib
                AppState.getTopViewController()?.present(navVc, animated: true)
            }
        }
    }
}

extension WelcomeThreeViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(tableDTO[indexPath.row]){
            
        case .titleEventCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneTitleCell", for: indexPath) as! WelcomeOneTitleCell
            cell.initForWelcomeThreeIfEvent()
            cell.selectionStyle = .none
            return cell
        case .mainEventTextCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneContentMain", for: indexPath) as! WelcomeOneContentMain
            cell.initForWelcomeThreeIfEvent()
            cell.selectionStyle = .none
            return cell
        case .titleDemandCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneTitleCell", for: indexPath) as! WelcomeOneTitleCell
            cell.initForWelcomeThreeIfDemand()
            cell.selectionStyle = .none
            return cell
        case .mainDemandTextCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneContentMain", for: indexPath) as! WelcomeOneContentMain
            cell.initForWelcomeThreeIfDemand()
            cell.selectionStyle = .none
            return cell
        case .titleContribCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneTitleCell", for: indexPath) as! WelcomeOneTitleCell
            cell.initForWelcomeThreeIfContrib()
            cell.selectionStyle = .none
            return cell
        case .mainContribTextCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneContentMain", for: indexPath) as! WelcomeOneContentMain
            cell.initForWelcomeThreeIfContrib()
            cell.selectionStyle = .none
            return cell
        case .eventCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "EventListCell", for: indexPath) as! EventListCell
            //Config
            if indexPath.row == 2 {
                cell.populateCell(event: self.currentevents[0], hideSeparator: true)
            }
            if indexPath.row == 3{
                cell.populateCell(event: self.currentevents[1], hideSeparator: true)
            }
            if indexPath.row == 4 {
                cell.populateCell(event: self.currentevents[2], hideSeparator: true)
            }
            cell.selectionStyle = .none
            return cell
        case .demandCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeThreeDemandExampleCell", for: indexPath) as! WelcomeThreeDemandExampleCell
            //Config
            if indexPath.row == 2 {
                cell.populateCell(action: currentDemands[0], hideSeparator: false)
            }
            if indexPath.row == 3 {
                cell.populateCell(action: currentDemands[1], hideSeparator: false)
            }
            if indexPath.row == 4 {
                cell.populateCell(action: currentDemands[2], hideSeparator: false)
            }
            cell.selectionStyle = .none
            return cell
        case .secondaryTextCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "SecondaryTextWelcomeCell", for: indexPath) as! SecondaryTextWelcomeCell
            cell.selectionStyle = .none
            return cell
        case .contribCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "ActionContribDetailHomeCell", for: indexPath) as! ActionContribDetailHomeCell
            //Config
            if indexPath.row == 3 {
                cell.populateCellForExample(image: UIImage(named: "ic_welcome_three_cofee")!, name: "welcome_three_contrib_example_one_title".localized, date: "welcome_three_contrib_example_one_date".localized, location: "welcome_three_contrib_example_one_loca".localized, distance: "welcome_three_contrib_example_one_distance".localized)
            }
            if indexPath.row == 4 {
                cell.populateCellForExample(image: UIImage(named: "ic_welcome_three_clothes")!, name: "welcome_three_contrib_example_two_title".localized, date: "welcome_three_contrib_example_two_date".localized, location: "welcome_three_contrib_example_two_loca".localized, distance: "welcome_three_contrib_example_two_distance".localized)
            }
            cell.hideSeparator()
            cell.selectionStyle = .none
            return cell
        case .blanckCell:
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "orange_tres_tres_clair")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.tableDTO.count - 1{
            return 200
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row]{
        case .titleEventCell:
            print("doNothing")
        case .mainEventTextCell:
            print("doNothing")
        case .titleDemandCell:
            print("doNothing")
        case .mainDemandTextCell:
            print("doNothing")
        case .titleContribCell:
            print("doNothing")
        case .mainContribTextCell:
            print("doNothing")
        case .eventCell:
            if indexPath.row == 2 {
                self.showEvent(eventId: self.currentevents[0].uid, event: self.currentevents[0])
            }
            if indexPath.row == 3 {
                self.showEvent(eventId: self.currentevents[1].uid, event: self.currentevents[1])
            }
            if indexPath.row == 4 {
                    self.showEvent(eventId: self.currentevents[2].uid, event: self.currentevents[2])
            }
        case .demandCell:
            if indexPath.row == 2 {
                self.showAction(actionId: currentDemands[0].id, isContrib: false, action: currentDemands[0])
            }
            if indexPath.row == 3 {
                self.showAction(actionId: currentDemands[1].id, isContrib: false, action: currentDemands[1])
            }
            if indexPath.row == 4 {
                self.showAction(actionId: currentDemands[2].id, isContrib: false, action: currentDemands[2])
            }
        case .secondaryTextCell:
            print("doNothing")
        case .contribCell:
            print("doNothing")
        case .blanckCell:
            print("doNothing")
        }
    }
}


extension WelcomeThreeViewController {
    func getEventsDiscovered() {
        EventService.getAllEventsDiscover(currentPage: 1,per: 4, filters: currentFilter.getfiltersForWS()) { events, error in
            if let _events = events {
                if _events.count > 0{
                    AnalyticsLoggerManager.logEvent(name: View_WelcomeOfferHelp_Day5A)
                    self.currentevents.append(contentsOf: _events)
                    self.haveEvents = true
                    self.fillDTOWithEvent()
                    self.setMainButtonWithEvent()
                }else{
                    self.haveEvents = false
                    self.getSolicitations()
                }
            }else{
                self.haveEvents = false
                self.getSolicitations()
            }
        }
    }
    
    func getSolicitations() {
        ActionsService.getAllActions(isContrib: false, currentPage: 1, per: 4, filtersLocation: currentLocationFilter.getfiltersForWS(), filtersSections: currentSectionsFilter.getallSectionforWS()) { actions, error in
            if let _actions = actions {
                if _actions.count > 0 {
                    AnalyticsLoggerManager.logEvent(name: View_WelcomeOfferHelp_Day5B)
                    DispatchQueue.main.async {
                        self.currentDemands.append(contentsOf: _actions)
                        self.haveDemands = true
                        self.fillDTOWithDemand()
                        self.setMainButtonWithDemand()
                    }

                    
                }else{
                    AnalyticsLoggerManager.logEvent(name: View_WelcomeOfferHelp_Day5C)
                    DispatchQueue.main.async {
                        self.haveDemands = false
                        self.fillDTOWithContrib()
                        self.setMainButtonWithContrib()
                        self.ui_top_image.isHidden = false
                        self.top_constraint.constant = 120
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.haveDemands = false
                    self.fillDTOWithContrib()
                    self.setMainButtonWithContrib()
                    self.ui_top_image.isHidden = false
                    self.top_constraint.constant = 120
                }
            }
        }
    }
}

