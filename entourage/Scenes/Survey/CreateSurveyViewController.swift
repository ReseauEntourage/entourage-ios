//
//  CreateSurveyViewController.swift
//  entourage
//
//  Created by Clement entourage on 13/03/2024.
//

import Foundation
import UIKit

enum CreateSurveyDTO{
    case questionCell
    case titleOptionCell
    case optionCell
    case qcmCell
}

protocol CreateSurveyValidationDelegate{
    func onSurveyCreate()
}

class CreateSurveyViewController:UIViewController{
    
    
    //OUTLET
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_button_validate: UIButton!
    
    @IBOutlet weak var ui_button_cancel: UIButton!
    
    @IBOutlet weak var ui_back_button: UIImageView!
    //VARIABLE
    
    
    var tableDTO = [CreateSurveyDTO]()
    var numberOfFieldFill = 1
    var groupId:Int = 0
    var eventId:Int = 0
    var surveyTitle: String = ""
    var surveyOptions: [String] = ["", "", "", "",""]
    var isQCM: Bool = true
    var delegate:CreateSurveyValidationDelegate? = nil

    override func viewDidLoad() {
        self.ui_tableview.dataSource = self
        self.ui_tableview.delegate = self
        ui_tableview.register(UINib(nibName: QuestionCell.identifier, bundle: nil), forCellReuseIdentifier: QuestionCell.identifier)
        ui_tableview.register(UINib(nibName: TitleOptionCell.identifier, bundle: nil), forCellReuseIdentifier: TitleOptionCell.identifier)
        ui_tableview.register(UINib(nibName: OptionCell.identifier, bundle: nil), forCellReuseIdentifier: OptionCell.identifier)
        ui_tableview.register(UINib(nibName: QcmCell.identifier, bundle: nil), forCellReuseIdentifier: QcmCell.identifier)
        ui_button_validate.addTarget(self, action: #selector(validateSurvey), for: .touchUpInside)
        ui_button_cancel.addTarget(self, action: #selector(cancelSurveyCreation), for: .touchUpInside)
        ui_back_button.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackTap))
        ui_back_button.addGestureRecognizer(tapGestureRecognizer)
        
        self.initDTO()
    }
    
    private func initDTO(){
        self.tableDTO.append(.questionCell)
        self.tableDTO.append(.titleOptionCell)
        for _ in 0...numberOfFieldFill{
            self.tableDTO.append(.optionCell)
        }
        self.tableDTO.append(.qcmCell)
        self.ui_tableview.reloadData()
    }

    @objc func handleBackTap() {
        self.dismiss(animated: true, completion: nil)
    }


    @objc func validateSurvey() {
        
        if(self.surveyTitle.isEmpty || self.surveyOptions[0].isEmpty){
            self.invalidDataAlert()
            return
        }

        self.surveyOptions.removeAll(where: { $0.isEmpty })
        
        if groupId != 0 {
            SurveyService.createSurveyInGroup(groupId: groupId, content: self.surveyTitle, choices: self.surveyOptions, multiple: self.isQCM) { isSuccess in
                if isSuccess {
                    self.delegate?.onSurveyCreate()
                    self.surveyOptions = ["","","","",""]
                    self.dismiss(animated: true)
                } else {
                    // Gérer l'échec
                }
            }
        } else if eventId != 0 {
            SurveyService.createSurveyInEvent(eventId: self.eventId, content: self.surveyTitle, choices: self.surveyOptions, multiple: self.isQCM) { isSuccess in
                if isSuccess{
                    self.delegate?.onSurveyCreate()
                    self.surveyOptions = ["","","","",""]
                    self.dismiss(animated: true)
                }else{
                    
                }
            }
        }
    }

    @objc func cancelSurveyCreation() {
        // Logique du bouton annuler
        let alertController = UIAlertController(title: "Attention", message: "Souhaitez-vous vraiment quitter ?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Non", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Oui", style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func invalidDataAlert(){
        let alertController = UIAlertController(title: "Attention", message: "Remplissez au moins le titre et deux options", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Très bien", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
}

extension CreateSurveyViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.tableDTO[indexPath.row]{
            
        case .questionCell:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as? QuestionCell{
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
            
        case .titleOptionCell:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TitleOptionCell", for: indexPath) as? TitleOptionCell{
                cell.delegate = self
                cell.selectionStyle = .none

                return cell
            }
            
        case .optionCell:
            if let cell = tableView.dequeueReusableCell(withIdentifier: OptionCell.identifier, for: indexPath) as? OptionCell {
                let optionIndex = indexPath.row - tableDTO.filter { $0 == .questionCell || $0 == .titleOptionCell }.count
                cell.selectionStyle = .none
                cell.configure(numberInList: optionIndex)
                cell.delegate = self
                return cell
            }
            
        case .qcmCell:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "QcmCell", for: indexPath) as? QcmCell{
                cell.delegate = self
                cell.selectionStyle = .none

                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension CreateSurveyViewController:QuestionCellDelegate{
    func onValidateQuestion(title:String) {
        self.surveyTitle = title

    }
    
    
}

extension CreateSurveyViewController:TitleOptionCellDelegate{

}

extension CreateSurveyViewController:OptionCellDelegate{
    func onOptionChanged(option: String, numberInList: Int) {
        if let lastOptionIndex = tableDTO.lastIndex(of: .optionCell), tableDTO.filter({ $0 == .optionCell }).count < 5 {
            if lastOptionIndex == numberInList + 3 {
                tableDTO.insert(.optionCell, at: lastOptionIndex + 1)
                ui_tableview.insertRows(at: [IndexPath(row: lastOptionIndex + 1, section: 0)], with: .automatic)
            }
        }
        // Mise à jour de l'option correspondante.
        if numberInList < surveyOptions.count {
            surveyOptions[numberInList] = option
        }
    }
    
    
}

extension CreateSurveyViewController:QcmCellDelegate{
    func onSwitchChanged(isQCM: Bool) {
        self.isQCM = isQCM

    }
}

extension CreateSurveyViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}
