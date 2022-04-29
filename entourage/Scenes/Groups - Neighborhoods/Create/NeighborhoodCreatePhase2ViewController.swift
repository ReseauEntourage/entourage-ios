//
//  NeighborhoodCreatePhase2ViewController.swift
//  entourage
//
//  Created by Jerome on 08/04/2022.
//

import UIKit
import IHProgressHUD

class NeighborhoodCreatePhase2ViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    var tagsInterests:Tags! = nil
    
    @IBOutlet weak var ui_error_view: MJErrorInputTextView!
    weak var pageDelegate:NeighborhoodCreateMainDelegate? = nil
    
    var showEditOther = false
    var messageOther:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ui_lbl_info.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        let stringAttr = Utils.formatString(messageTxt: "neighborhoodCreateCatMessage".localized, messageTxtHighlight: "neighborhoodCreateCatMessageMandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_lbl_info.attributedText = stringAttr
        
        tagsInterests = Metadatas.sharedInstance.tagsInterest
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showError), name: NSNotification.Name(kNotificationNeighborhoodCreatePhase2Error), object: nil)
        
        ui_error_view.isHidden = true
        self.ui_error_view.setupView(title: "neighborhoodCreatePhase2_error".localized)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tagsInterests = tagsInterests, tagsInterests.getTags().count > 0 else {
            self.dismiss(animated: true)
            return
        }
        ui_error_view.isHidden = true
        super.viewWillAppear(animated)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func action_validate(_ sender: Any) {
        var hasOneCheck = false
        
        for interest in tagsInterests.getTags() {
            if interest.isSelected {
                hasOneCheck = true
                break
            }
        }
        
        if hasOneCheck {
            updateInterests()
            ui_error_view.isHidden = true
        }
        else {
            ui_error_view.isHidden = false
        }
    }
    
    func updateInterests() {
        UserService.updateUserInterests(interests: tagsInterests.getTagsForWS()) { user, error in
            Logger.print("Return update Interests : \(user)")
            if let err = error?.error {
                IHProgressHUD.showError(withStatus: err.localizedDescription)
                
                return
            }
            self.dismiss(animated: true)
        }
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
extension NeighborhoodCreatePhase2ViewController : UITableViewDataSource, UITableViewDelegate {
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
        
        cell.populateCell(title: tagsInterests!.getTagNameFrom(key: interest!.name) , isChecked: interest!.isSelected, imageName: (interest! as! TagInterest).tagImageName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showEditOther && indexPath.row == tagsInterests.getTags().count { return }
        let isCheck = tagsInterests!.getTags()[indexPath.row].isSelected
        
        tagsInterests?.checkUncheckTagFrom(position: indexPath.row, isCheck: !isCheck)
        
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
        self.pageDelegate?.addGroupInterests(tags: tagsInterests,messageOther: messageOther)
        
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
extension NeighborhoodCreatePhase2ViewController: NeighborhoodCreateAddOtherDelegate {
    func addMessage(_ message: String?) {
        self.messageOther = message
        self.pageDelegate?.addGroupInterests(tags: tagsInterests,messageOther: messageOther)
    }
}
