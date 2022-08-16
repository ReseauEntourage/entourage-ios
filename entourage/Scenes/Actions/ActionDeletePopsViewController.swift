//
//  ActionDeletePopsViewController.swift
//  entourage
//
//  Created by Jerome on 12/08/2022.
//

import UIKit
import IQKeyboardManagerSwift
import IHProgressHUD

class ActionDeletePopsViewController: UIViewController {
    
    
    @IBOutlet weak var ui_view_pop_main: UIView!
    
    @IBOutlet weak var ui_subtitle_demand: UILabel!
    @IBOutlet weak var ui_title_demand: UILabel!
    @IBOutlet weak var ui_view_demand: UIView!
    @IBOutlet weak var ui_bt_no: UIButton!
    @IBOutlet weak var ui_bt_yes: UIButton!
    
    @IBOutlet weak var ui_view_comment: UIView!
    @IBOutlet weak var ui_title_comment: UILabel!
    @IBOutlet weak var ui_subtitle_comment: UILabel!
    @IBOutlet weak var ui_tv_comment: GrowingTextView!
    @IBOutlet weak var ui_bt_send: UIButton!
    
    let cornerRadius:CGFloat = 20
    
    var originalGrowingTf:CGFloat = 0
    var lastGrowingTf:CGFloat = 0
    
    private var parentVC:UIViewController? = nil
    
    var isClosedOk = false
    var isContrib = false
    var actionId = 0
    
    weak var delegate:ActionDeletePopDelegate? = nil
    
    init() {
        super.init(nibName: "ActionDeletePopsViewController", bundle: Bundle(for: ActionDeletePopsViewController.self))
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        let buttonDone = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: #selector(closeKb(_:)))
        
        ui_tv_comment.delegate = self
        ui_tv_comment.trimWhiteSpaceWhenEndEditing = false
        ui_tv_comment.font = ApplicationTheme.getFontChampDefault().font
        ui_tv_comment.placeholder = "params_cancel_action_pop_comment_placeholder".localized
        ui_tv_comment.placeholderColor = ApplicationTheme.getFontChampDefault().color
        ui_tv_comment.addToolBar(width: _width, buttonValidate: buttonDone)
        
        ui_tv_comment.maxHeight = 80
        
        ui_view_pop_main.layer.cornerRadius = cornerRadius
        
        ui_bt_yes.setTitle("params_cancel_action_pop_bt_yes".localized, for: .normal)
        ui_bt_no.setTitle("params_cancel_action_pop_bt_no".localized, for: .normal)
        ui_bt_send.setTitle("params_cancel_action_pop_bt_valid".localized, for: .normal)
        
        ui_bt_yes.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_bt_no.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange())
        ui_bt_send.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        
        ui_title_demand.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
        ui_title_comment.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
        ui_subtitle_demand.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        let _attr = Utils.formatString(messageTxt: "params_cancel_action_pop_comment".localized, messageTxtHighlight: "action_optional".localized, fontColorType: ApplicationTheme.getFontCourantRegularNoir(), fontColorTypeHighlight: ApplicationTheme.getFontLegend())
        ui_subtitle_comment.attributedText = _attr
    }
    
    func configureCongrat(parentVC:UIViewController?, isContrib:Bool, actionId:Int, delegate:ActionDeletePopDelegate) {
        self.parentVC = parentVC
        self.delegate = delegate
        self.isContrib = isContrib
        self.actionId = actionId
    }
    
    func populateView() {
        let title = String.init(format: "params_cancel_action_pop_title".localized, !isContrib ? "action_solicitation".localized : "action_contrib".localized)
        let subtitle = String.init(format: "params_cancel_action_pop_subtitle".localized, !isContrib ? "action_solicitation".localized : "action_contrib".localized)
        
        ui_title_comment.text = title
        ui_title_demand.text = title
        ui_subtitle_demand.text = subtitle
    }
    
    func show() {
        if let parentVC = parentVC {
            parentVC.present(self, animated: true, completion: nil)
            populateView()
            return
        }
        
        if #available(iOS 13, *) {
            UIApplication.shared.windows.first?.rootViewController?.present(self, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController!.present(self, animated: true, completion: nil)
        }
        populateView()
    }
    
    //MARK: - Network -
    func sendCancelAction() {
        IHProgressHUD.show()
        ActionsService.cancelAction(isContrib: isContrib, actionId: actionId, isClosedOk: isClosedOk, message: ui_tv_comment.text) { action, error in
            IHProgressHUD.dismiss()
            self.dismiss(animated: true)
            self.delegate?.canceledAction(isCancel: error == nil)
        }
    }
    
    @objc func closeKb(_ sender:UIBarButtonItem?) {
        _ = ui_tv_comment.resignFirstResponder()
    }
    
    //MARK: - IBActions -
    @IBAction func action_yes(_ sender: Any) {
        ui_view_demand.isHidden = true
        ui_view_comment.isHidden = false
        isClosedOk = true
    }
    
    @IBAction func action_no(_ sender: Any) {
        ui_view_demand.isHidden = true
        ui_view_comment.isHidden = false
        isClosedOk = false
    }
    
    @IBAction func action_send(_ sender: Any) {
        sendCancelAction()
    }
    
    @IBAction func action_close_pop(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Growing delegate
extension ActionDeletePopsViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        if originalGrowingTf == 0 {
            originalGrowingTf = height
            return
        }
        
        if height >= originalGrowingTf {
            let oldHeight = lastGrowingTf
            lastGrowingTf = height
            let isUp = lastGrowingTf > oldHeight
            let notif = Notification(name: Notification.Name(kNotifGrowTextview), object: nil, userInfo: [kNotifGrowTextviewKeyISUP:isUp])
            NotificationCenter.default.post(notif)
        }
    }
}

//MARK: - Protocol -
protocol ActionDeletePopDelegate:AnyObject {
    func canceledAction(isCancel:Bool)
}
