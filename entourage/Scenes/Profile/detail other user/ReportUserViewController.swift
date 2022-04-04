//
//  UserProfileSignalViewController.swift
//  entourage
//
//  Created by Jerome on 29/03/2022.
//

import UIKit

class ReportUserViewController: BasePopViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_button_validate: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var user:User? = nil
    var tagsignals:Tags! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagsignals = Metadatas.sharedInstance.tagsSignals
        
        ui_top_view.populateView(title: "report_user_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        self.ui_lbl_info.font = ApplicationTheme.getFontTextRegular().font
        self.ui_lbl_info.textColor = ApplicationTheme.getFontTextRegular().color
        
        ui_lbl_info.text = "report_user_description".localized
        
        ui_button_validate.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_button_validate.titleLabel?.textColor = .white
        ui_button_validate.layer.cornerRadius = ui_button_validate.frame.height / 2
        ui_button_validate.setTitle("report_user_validate_button".localized, for: .normal)
        
        //TODO: on affiche le fond transparent pour l'alerte ou un fond blanc ?
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tagsignals = tagsignals, tagsignals.getTags().count > 0 else {
            self.dismiss(animated: true)
            return
        }
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func action_validate(_ sender: Any) {
        var hasOneCheck = false
        for signal in tagsignals.getTags() {
            if signal.isSelected {
                hasOneCheck = true
                break
            }
        }
        
        if hasOneCheck {
            reportUser()
        }
        else {
            showError(message: "report_user_error".localized)
        }
    }
    
    func reportUser() {
        let message = "Message" //TODO: avec les bonnes valeurs ;)
        let tagsSignals = tagsignals.getTagsForWS()
        guard let userId = user?.sid else { return }
        UserService.reportUser(userId: "\(userId)", tags: tagsSignals, message: message) { error in
            self.showError(message: "Utilisateur signalé", imageName: "ic_partner_follow_on")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.goBack()
            }
        }
    }
    
    func showError(message:String, imageName:String? = nil) {
        ui_error_view.changeTitleAndImage(title: message,imageName: imageName)
        ui_error_view.show()
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate  -
extension ReportUserViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsignals?.getTags().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SelectTagCell
        
        let signal = tagsignals?.getTags()[indexPath.row]
        
        cell.populateCell(title: tagsignals!.getTagNameFrom(key: signal!.name) , isChecked: signal!.isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCheck = tagsignals!.getTags()[indexPath.row].isSelected
        
        tagsignals?.checkUncheckTagFrom(position: indexPath.row, isCheck: !isCheck)
        tableView.reloadData()
    }
}

//MARK: - MJNavBackViewDelegate -
extension ReportUserViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}
