//
//  EventCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit

class EventCreatePhase4ViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_error_view: MJErrorInputTextView!
    
    weak var pageDelegate:EventCreateMainDelegate? = nil
    var tagsInterests:Tags! = nil
    
    var showEditOther = false
    var messageOther:String? = nil
    
    var currentEvent:Event? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ui_lbl_info.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        let stringAttr = Utils.formatString(messageTxt: "event_create_phase4_title".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_lbl_info.attributedText = stringAttr
        
        tagsInterests = Metadatas.sharedInstance.tagsInterest
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showError), name: NSNotification.Name(kNotificationEventCreatePhase4Error), object: nil)
        ui_error_view.isHidden = true
        self.ui_error_view.setupView(title: "eventCreatePhase4_error".localized)
        
        if pageDelegate?.isEdit() ?? false {
            currentEvent = pageDelegate?.getCurrentEvent()
            
            if let interests = currentEvent?.interests {
                for interest in interests {
                    if let _ = tagsInterests?.getTagNameFrom(key: interest) {
                        tagsInterests?.checkUncheckTagFrom(key: interest, isCheck: true)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tagsInterests = tagsInterests, tagsInterests.getTags().count > 0 else {
            self.dismiss(animated: true)
            return
        }
        ui_error_view.isHidden = true
        super.viewWillAppear(animated)
    }
    
    @objc func showError(notification:Notification) {
        if let message = notification.userInfo?["error_message"] as? String {
            ui_error_view.setupView(title: message, imageName: nil)
            ui_error_view.isHidden = false
        }
        else {
            ui_error_view.isHidden = true
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate  -
extension EventCreatePhase4ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showEditOther {
            return tagsInterests.getTags().count + 1
        }
        return tagsInterests?.getTags().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showEditOther && indexPath.row == tagsInterests.getTags().count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellOther", for: indexPath) as! NeighborhoodCreateAddOtherCell
            
            cell.populateCell(currentWord:messageOther , delegate: self)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInterest", for: indexPath) as! SelectTagCell
        
        let interest = tagsInterests?.getTags()[indexPath.row]
        
        cell.populateCell(title: tagsInterests!.getTagNameFrom(key: interest!.name) , isChecked: interest!.isSelected, imageName: (interest! as! TagInterest).tagImageName, isAction: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showEditOther && indexPath.row == tagsInterests.getTags().count { return }
        let isCheck = tagsInterests!.getTags()[indexPath.row].isSelected
        
        tagsInterests?.checkUncheckTagFrom(position: indexPath.row, isCheck: !isCheck)
        
        if pageDelegate?.isEdit() ?? false {
            tableView.reloadData()
            messageOther = nil
            self.pageDelegate?.addInterests(tags: tagsInterests,messageOther: messageOther)
            return
        }
        
        if indexPath.row == tagsInterests.getTags().count - 1 {
            //Ajout une ligne +
            showEditOther = tagsInterests.getTags()[indexPath.row].isSelected
            if showEditOther {
                self.reloadData(animated: true)
            }
            else {
                self.reloadData(animated: false)
            }
        }
        else {
            tableView.reloadData()
        }
        messageOther = showEditOther ? messageOther : nil
        self.pageDelegate?.addInterests(tags: tagsInterests,messageOther: messageOther)
        
    }
    
    func reloadData(animated:Bool){
        ui_tableview.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05, execute: {
            let scrollPoint = CGPoint(x: 0, y: self.ui_tableview.contentSize.height - self.ui_tableview.frame.size.height)
            self.ui_tableview.setContentOffset(scrollPoint, animated: animated)
        })
    }
}

//MARK: - NeighborhoodCreateAddOtherDelegate -
extension EventCreatePhase4ViewController: NeighborhoodCreateAddOtherDelegate {
    func addMessage(_ message: String?) {
        self.messageOther = message
        self.pageDelegate?.addInterests(tags: tagsInterests,messageOther: messageOther)
    }
}
