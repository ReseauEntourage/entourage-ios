//
//  EventMainHomeViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit

class EventMainHomeViewController: UIViewController {

    @IBOutlet weak var ui_bt_event_edit: UIButton!
    var newEventId = 123293
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Notif for updating when create new Event
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationEventCreateEnd), object: nil)
        
        //Notif for showing new created event
        NotificationCenter.default.addObserver(self, selector: #selector(showNewEvent(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewEvent), object: nil)
        ui_bt_event_edit.setTitle("Edit event N° : \(newEventId)", for: .normal)
    }
    
    
    func setDiscoverFirst() {
        //TODO: a faire lorsque la page sera OP
        Logger.print("***** Show Discover events *****")
    }
    
    func setMyFirst() {
        //TODO: a faire lorsque la page sera OP
        Logger.print("***** Show My events *****")
    }
    
    @objc func updateFromCreate() {
        //TODO: a faire le refresh de la tableview quand ce sera OP
    }

    @IBAction func action_add_event(_ sender: Any) {
        let navVC = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    @IBAction func action_edit_event(_ sender: Any) {
        
        let navVC = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "eventEditVCMain") as! EventEditMainViewController
        navVC.parentController = self.tabBarController
        navVC.eventId = newEventId
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
    }
    
    
    @objc func showNewEvent(_ notification:Notification) {
        if let eventId = notification.userInfo?["eventId"] as? Int {
            Logger.print("***** ShowNewEvent  : \(eventId)")
            DispatchQueue.main.async {
                self.showEvent(eventId: eventId, isAfterCreation: true)
            }
        }
    }

    
    func showEvent(eventId:Int, isAfterCreation:Bool = false, event:Event? = nil) {
        newEventId = eventId
        ui_bt_event_edit.setTitle("Edit event N° : \(newEventId)", for: .normal)
        //TODO: a faire lorsque l'on aura le détail d'un event ;)
//        let sb = UIStoryboard.init(name: "Neighborhood", bundle: nil)
//        if let nav = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = nav.topViewController as? NeighborhoodDetailViewController {
//            vc.isAfterCreation = isAfterCreation
//            vc.neighborhoodId = neighborhoodId
//            vc.isShowCreatePost = isShowCreatePost
//            vc.neighborhood = neighborhood
//            self.navigationController?.present(nav, animated: true)
//        }
    }
}
