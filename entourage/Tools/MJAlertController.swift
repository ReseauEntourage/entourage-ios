//
//  MJAlertController.swift
//  entourage
//
//  Created by Jerome on 15/03/2022.
//

import UIKit

class MJAlertController: UIViewController {

    @IBOutlet var ui_titles_choice: [UILabel]!
    @IBOutlet var ui_iv_choice: [UIImageView]!
    @IBOutlet weak var ui_view_stack_choice: UIStackView!
    @IBOutlet weak var ui_title_choice_1: UILabel!
    @IBOutlet weak var ui_title_choice_2: UILabel!
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_message: UILabel!
    @IBOutlet weak var ui_button_left: UIButton!
    @IBOutlet weak var ui_button_right: UIButton!
    
    @IBOutlet weak var ui_iv_close: UIImageView!
    @IBOutlet weak var ui_button_close: UIButton!
    
    @IBOutlet weak var ui_alert_view: UIView!
    
    weak var delegate:MJAlertControllerDelegate? = nil
    var alertTagName:MJAlertTAG = .None
    
    var buttonRightType = MJAlertButtonType(title: "Cancel".localized)
    var buttonLeftType:MJAlertButtonType? = MJAlertButtonType(title: "OK".localized)
    var alertTitle:String? = nil
    var alertMessage:String? = nil
    
    var choice1:String? = nil
    var choice2:String? = nil
    var hasChoice = false
    
    //Custom UI
    var titleStyle = ApplicationTheme.getFontCourantBoldOrange()
    var messageStyle = ApplicationTheme.getFontCourantRegularNoir()
    var choiceStyle = ApplicationTheme.getFontCourantRegularNoir()
    var mainviewBGColor = UIColor.white
    var mainviewRadius:CGFloat = 35
    var isButtonCloseHidden = false
    
    private var parentVC:UIViewController? = nil
    
    init() {
        super.init(nibName: "MJAlertController", bundle: Bundle(for: MJAlertController.self))
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if hasChoice {
            setupChoice()
        }
        else {
            setupAlert()
        }
    }
    
    func show() {
        if let parentVC = parentVC {
            parentVC.present(self, animated: true, completion: nil)
            return
        }
        
        if #available(iOS 13, *) {
            UIApplication.shared.windows.first?.rootViewController?.present(self, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController!.present(self, animated: true, completion: nil)
        }
    }
    
    func configureAlert(alertTitle:String?, message:String?,buttonrightType:MJAlertButtonType,buttonLeftType:MJAlertButtonType?,titleStyle:MJTextFontColorStyle? = nil, messageStyle:MJTextFontColorStyle? = nil, mainviewBGColor:UIColor? = nil, mainviewRadius:CGFloat? = nil, isButtonCloseHidden:Bool? = true, parentVC:UIViewController? = nil) {
        
        self.parentVC = parentVC
        
        self.titleStyle = titleStyle ?? self.titleStyle
        self.messageStyle = messageStyle ?? self.messageStyle
        
        self.mainviewRadius = mainviewRadius ?? self.mainviewRadius
        self.mainviewBGColor = mainviewBGColor ?? self.mainviewBGColor
        
        self.alertTitle = alertTitle
        self.alertMessage = message
        
        self.buttonLeftType = buttonLeftType
        self.buttonRightType = buttonrightType
        
        self.isButtonCloseHidden = isButtonCloseHidden ?? false
        
        setupAlert()
    }
    
    func configurePopWithChoice(alertTitle:String?,choice1:String,choice2:String,buttonrightType:MJAlertButtonType,buttonLeftType:MJAlertButtonType?,titleStyle:MJTextFontColorStyle? = nil,choiceStyle:MJTextFontColorStyle? = nil, mainviewBGColor:UIColor? = nil, mainviewRadius:CGFloat? = nil, parentVC:UIViewController? = nil) {
        
        self.parentVC = parentVC
        
        self.titleStyle = titleStyle ?? self.titleStyle
        self.choiceStyle = choiceStyle ?? self.choiceStyle
        
        self.mainviewRadius = mainviewRadius ?? self.mainviewRadius
        self.mainviewBGColor = mainviewBGColor ?? self.mainviewBGColor
        
        self.alertTitle = alertTitle
        self.choice1 = choice1
        self.choice2 = choice2
        
        self.buttonLeftType = buttonLeftType
        self.buttonRightType = buttonrightType
        
        self.isButtonCloseHidden = true
        
        hasChoice = true
        setupChoice()
    }
    private func setupChoice() {
        guard let ui_title = ui_title,let ui_message = ui_message, let ui_alert_view = ui_alert_view, let ui_view_stack_choice = ui_view_stack_choice, let ui_title_choice_1 = ui_title_choice_1, let ui_title_choice_2 = ui_title_choice_2 else { return }
        ui_title.text = alertTitle
        ui_title.setupFontAndColor(style: self.titleStyle)
        
        ui_message.isHidden = true
        ui_view_stack_choice.isHidden = false
        
        ui_title_choice_1.setupFontAndColor(style: self.choiceStyle)
        ui_title_choice_2.setupFontAndColor(style: self.choiceStyle)
        ui_title_choice_1.text = choice1
        ui_title_choice_2.text = choice2
        
        ui_alert_view.layer.cornerRadius = self.mainviewRadius
        ui_alert_view.backgroundColor = self.mainviewBGColor
        
        changeChoiceView(position: 0)
        setupButton()
    }
    
    //MARK: - Private methods -
    private func setupAlert() {
        guard let ui_title = ui_title,let ui_message = ui_message, let ui_alert_view = ui_alert_view else { return }
        
        ui_title.text = alertTitle
        ui_title.textColor = titleStyle.color
        ui_title.font = titleStyle.font
        
        ui_message.text = alertMessage
        ui_message.textColor = messageStyle.color
        ui_message.font = messageStyle.font
       
        ui_alert_view.layer.cornerRadius = mainviewRadius
        ui_alert_view.backgroundColor = mainviewBGColor
        
        ui_iv_close?.isHidden = isButtonCloseHidden
        ui_button_close?.isHidden = isButtonCloseHidden
        ui_view_stack_choice.isHidden = true
        
        setupButton()
    }
    
    private func setupButton() {
        guard let ui_button_left = ui_button_left, let ui_button_right = ui_button_right else { return }
        
        if let buttonLeftType = buttonLeftType {
            ui_button_left.isHidden = false
            initButton(button: ui_button_left, butttonType: buttonLeftType)
        }
        else {
            ui_button_left.isHidden = true
        }
        
        initButton(button: ui_button_right, butttonType: buttonRightType)
    }
    
    private func initButton(button:UIButton, butttonType:MJAlertButtonType) {
        button.setTitle(butttonType.title, for: .normal)
        button.layer.cornerRadius = butttonType.cornerRadius == -1 ? button.frame.height / 2 : butttonType.cornerRadius
        button.setTitleColor(butttonType.titleStyle.color, for: .normal)
        button.titleLabel?.font = butttonType.titleStyle.font
        button.backgroundColor = butttonType.bgColor
    }
    
    //MARK: - Actions -
    @IBAction func action_left_button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.validateLeftButton(alertTag:alertTagName)
    }
    @IBAction func action_right_button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.validateRightButton(alertTag:alertTagName)
    }
    @IBAction func action_close_button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.closePressed(alertTag:alertTagName)
    }
    
    @IBAction func action_select_choice(_ sender: UIButton) {
        delegate?.selectedChoice(position: sender.tag)
        changeChoiceView(position: sender.tag)
    }
    
    func changeChoiceView(position:Int) {
        var i = 0
        for title in ui_titles_choice {
            if i == position {
                title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
            }
            else {
                title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
            }
            i = i + 1
        }
        
        i = 0
        for button in ui_iv_choice {
            if i == position {
                button.image = UIImage.init(named: "ic_selector_on")
            }
            else {
                button.image = UIImage.init(named: "ic_selector_off")
            }
            i = i + 1
        }
    }
}

enum MJAlertTAG {
    case AcceptSettings
    case Suppress
    case Logout
    case None
    case AcceptAdd
}

//MARK: - MJAlertButtonType -
struct MJAlertButtonType {
    var title:String = "button"
    var bgColor:UIColor = .clear
    var cornerRadius:CGFloat = 0
    var titleStyle:MJTextFontColorStyle
    
    //Pass -1 for cornerRadius -> height / 2
    init(title:String, titleStyle:MJTextFontColorStyle? = nil, bgColor:UIColor? = nil, cornerRadius:CGFloat? = nil) {
        self.title = title
        self.bgColor = bgColor ?? self.bgColor
        self.cornerRadius = cornerRadius ?? self.cornerRadius
        self.titleStyle = titleStyle ?? MJTextFontColorStyle(font: UIFont.systemFont(ofSize: 15), color: .black)
    }
}

//MARK: - MJAlertControllerDelegate -
protocol MJAlertControllerDelegate: AnyObject {
    func validateLeftButton(alertTag:MJAlertTAG)
    func validateRightButton(alertTag:MJAlertTAG)
    func closePressed(alertTag:MJAlertTAG)
    func selectedChoice(position:Int)
}
//MARK: - To make closePressed optional function -
extension MJAlertControllerDelegate {
    func closePressed(alertTag:MJAlertTAG) {}
    func selectedChoice(position:Int) {}
}
