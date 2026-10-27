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
    @IBOutlet weak var ui_title_label: UILabel!
    //VARIABLE
    
    
    var tableDTO = [CreateSurveyDTO]()
    var numberOfFieldFill = 1
    var groupId:Int = 0
    var eventId:Int = 0
    var surveyTitle: String = ""
    var surveyOptions: [String] = ["", "", "", "",""]
    var isQCM: Bool = false
    var delegate:CreateSurveyValidationDelegate? = nil

    /// Mode édition : seule la question est modifiable (le back n'accepte que `content`
    /// à l'update) ; choix et choix multiple sont affichés en lecture seule.
    var editingPostId: Int? = nil
    var editingSurvey: Survey? = nil
    private var isEditingSurvey: Bool { editingPostId != nil }

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
        configureOrangeButton(ui_button_validate, withTitle: (isEditingSurvey ? "modify" : "validate").localized)
        configureWhiteButton(ui_button_cancel, withTitle: "cancel".localized)
        if isEditingSurvey { ui_title_label.text = "neighborhood_edit_post_title".localized }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackTap))
        ui_back_button.addGestureRecognizer(tapGestureRecognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.initDTO()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Vérifiez si la première cellule est une QuestionCell.
        if let questionCell = ui_tableview.cellForRow(at: IndexPath(row: 0, section: 0)) as? QuestionCell {
            // Ouvrir le clavier pour le UITextView de la QuestionCell.
            questionCell.ui_text_view.becomeFirstResponder()
        }
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

    
    private func initDTO(){
        self.tableDTO.append(.questionCell)
        self.tableDTO.append(.titleOptionCell)
        if isEditingSurvey, let survey = editingSurvey {
            for _ in survey.choices {
                self.tableDTO.append(.optionCell)
            }
            isQCM = survey.multiple
        } else {
            for _ in 0...numberOfFieldFill{
                self.tableDTO.append(.optionCell)
            }
        }
        self.tableDTO.append(.qcmCell)
        self.ui_tableview.reloadData()
    }

    @objc func handleBackTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let keyboardHeight = keyboardSize.height
        let bottomInset = keyboardHeight - (view.safeAreaInsets.bottom)
        ui_tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        ui_tableview.scrollIndicatorInsets = ui_tableview.contentInset
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        ui_tableview.contentInset = .zero
        ui_tableview.scrollIndicatorInsets = .zero
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    @objc func validateSurvey() {
        if let postId = editingPostId {
            let question = surveyTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !question.isEmpty else { self.invalidDataAlert(); return }
            NeighborhoodService.editComment(groupId: groupId, messageId: postId, content: question) { [weak self] message, _ in
                guard let self = self, message != nil else { return }
                self.delegate?.onSurveyCreate()
                self.dismiss(animated: true)
            }
            return
        }
        
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
        showAlertMessage()
    }
    
    func invalidDataAlert(){
        let alertController = UIAlertController(title: "Attention", message: "Remplissez au moins le titre et deux options", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Très bien", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertMessage(){

        let title = "Attention"
        let btnLeftTitle = "Annuler"
        let btnRightTitle = "Quitter"
        var message = "Si vous quittez la création de sondage, toutes les informations saisies seront perdues"

        let alertVC = MJAlertController()
        let buttonLeft = MJAlertButtonType(title: btnLeftTitle, titleStyle:ApplicationTheme.getFontH1Blanc(size: 15), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonRight = MJAlertButtonType(title: btnRightTitle, titleStyle:ApplicationTheme.getFontH1Blanc(size: 15), bgColor: .appOrange, cornerRadius: -1)

        
        alertVC.configureAlert(alertTitle: title, message: message, buttonrightType: buttonRight, buttonLeftType: buttonLeft, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: false)
        alertVC.delegate = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
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
                if isEditingSurvey { cell.configure(text: surveyTitle) }
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
                if isEditingSurvey, let choices = editingSurvey?.choices, optionIndex < choices.count {
                    cell.configure(text: choices[optionIndex], isEditable: false)
                }
                cell.delegate = self
                return cell
            }
            
        case .qcmCell:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "QcmCell", for: indexPath) as? QcmCell{
                cell.delegate = self
                cell.selectionStyle = .none
                if isEditingSurvey { cell.configure(isOn: isQCM, isEnabled: false) }
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
    func textViewDidChangeInCell(_ cell: QuestionCell) {
        self.ui_tableview.beginUpdates()
        self.ui_tableview.endUpdates()
    }
    
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
        self.ui_tableview.beginUpdates()
        self.ui_tableview.endUpdates()
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
    func didTapEvent() {
        //Nothing yet
    }
}

extension CreateSurveyViewController:MJAlertControllerDelegate{
    func validateLeftButton(alertTag: MJAlertTAG) {
        
    }
    
    func validateRightButton(alertTag: MJAlertTAG) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
