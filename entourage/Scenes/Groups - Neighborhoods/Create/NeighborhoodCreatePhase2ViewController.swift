//
//  NeighborhoodCreatePhase2ViewController.swift
//  entourage
//
//  Created by Jerome on 08/04/2022.
//

import UIKit

class NeighborhoodCreatePhase2ViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    var tagsInterests:Tags! = nil
    
    weak var pageDelegate:NeighborhoodCreateMainDelegate? = nil
    
    var showEditOther = false
    var messageOther:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ui_lbl_info.font = ApplicationTheme.getFontCourantRegularNoir().font
        self.ui_lbl_info.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        
        let stringAttr = Utils.formatString(messageTxt: "neighborhoodCreateCatMessage".localized, messageTxtHighlight: "neighborhoodCreateCatMessageMandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_lbl_info.attributedText = stringAttr
        
        //TODO: on affiche le fond transparent pour l'alerte ou un fond blanc ?
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        tagsInterests = Metadatas.sharedInstance.tagsInterest
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tagsInterests = tagsInterests, tagsInterests.getTags().count > 0 else {
            self.dismiss(animated: true)
            return
        }
        
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
        }
        else {
            showError(message: "editUserInterests_error".localized)
        }
    }
    
    func updateInterests() {
        UserService.updateUserInterests(interests: tagsInterests.getTagsForWS()) { user, error in
            Logger.print("Return update Interests : \(user)")
            if let err = error?.error {
                self.showError(message: err.localizedDescription)
                return
            }
            self.dismiss(animated: true)
        }
    }
    
    func showError(message:String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
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
