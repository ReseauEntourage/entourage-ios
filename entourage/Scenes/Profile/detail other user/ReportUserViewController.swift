//
//  UserProfileSignalViewController.swift
//  entourage
//
//  Created by Jerome on 29/03/2022.
//

import UIKit

class ReportUserViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_lbl_mandatory: UILabel!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_button_validate: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var user:User? = nil
    var tagsignals:Tags! = nil
    weak var pageDelegate:ReportUserPageDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagsignals = Metadatas.sharedInstance.tagsSignals
        
        self.ui_lbl_info.font = ApplicationTheme.getFontCourantRegularNoir().font
        self.ui_lbl_info.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        ui_lbl_info.text = "report_user_description".localized
        
        ui_lbl_mandatory.font = ApplicationTheme.getFontLegend().font
        ui_lbl_mandatory.textColor = ApplicationTheme.getFontLegend().color
        ui_lbl_mandatory.text = "report_user_mandatory".localized
        
        ui_button_validate.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_button_validate.titleLabel?.textColor = .white
        ui_button_validate.layer.cornerRadius = ui_button_validate.frame.height / 2
        ui_button_validate.setTitle("report_user_next_button".localized, for: .normal)
        ui_button_validate.backgroundColor = .appOrangeLight
        configureOrangeButton(ui_button_validate, withTitle: "report_user_next_button".localized)
        
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
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
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
            pageDelegate?.goNext(tags: tagsignals)
        }
        else {
            showError(message: "report_user_signal_error".localized)
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
        
        cell.populateCell(title: tagsignals!.getTagNameFrom(key: signal!.name) , isChecked: signal!.isSelected, isAction: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCheck = tagsignals!.getTags()[indexPath.row].isSelected
        
        tagsignals?.checkUncheckTagFrom(position: indexPath.row, isCheck: !isCheck)
        tableView.reloadData()
    }
}
