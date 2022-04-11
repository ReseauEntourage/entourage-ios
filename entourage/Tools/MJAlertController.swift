//
//  MJAlertController.swift
//  entourage
//
//  Created by Jerome on 15/03/2022.
//

import UIKit

class MJAlertController: UIViewController {

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
    
    //Custom UI
    var titleStyle = ApplicationTheme.getFontCourantBoldOrange()
    var messageStyle = ApplicationTheme.getFontCourantRegularNoir()
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

        setupAlert()
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
        ui_title.backgroundColor = mainviewBGColor
        
        ui_iv_close?.isHidden = isButtonCloseHidden
        ui_button_close?.isHidden = isButtonCloseHidden
        
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
}

enum MJAlertTAG {
    case Suppress
    case Logout
    case None
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
}
//MARK: - To make closePressed optional function -
extension MJAlertControllerDelegate {
    func closePressed(alertTag:MJAlertTAG) {}
}
