//
//  PartnerDetailViewController.swift
//  entourage
//
//  Created by Jerome on 25/03/2022.
//

import MessageUI
import IHProgressHUD

class PartnerDetailViewController: UIViewController {
    
    var partner:Partner? = nil
    @objc var partnerId:Int = -1
    let radius_main_view:CGFloat = 35
    
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_view_top_white: UIView!
    @IBOutlet weak var ui_view_img_profile: UIView!
    @IBOutlet weak var ui_image_partner: UIImageView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var hasPartnerNeeds = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = false
        }
        
        setupPhotoUI()
        
        ui_top_view.populateCustom(imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.estimatedRowHeight = 200
        getPartnerInfos()
    }
    
    func getPartnerInfos() {
        AssociationService.getPartnerDetail(id: partnerId) { [weak self] partner, error in
            if partner != nil {
                self?.partner = partner
                
                DispatchQueue.main.async {
                    self?.updatePartner()
                }
            }
            else {
                Logger.print("Erreur get asso id : \(self?.partnerId) err: -> \(String(describing: error?.error?.localizedDescription))")
            }
        }
    }
    
    func setupPhotoUI() {
        ui_image_partner.layer.cornerRadius = ui_image_partner.frame.height / 2
        
        ui_view_img_profile.layer.cornerRadius = ui_image_partner.frame.height / 2
        ui_view_img_profile.layer.borderColor = UIColor.white.cgColor
        ui_view_img_profile.layer.borderWidth = 1
        
        ui_view_img_profile.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        ui_view_img_profile.layer.shadowOpacity = 1
        ui_view_img_profile.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        ui_view_img_profile.layer.shadowRadius = 10
        
        ui_view_img_profile.layer.rasterizationScale = UIScreen.main.scale
        ui_view_img_profile.layer.shouldRasterize = true
        
        ui_view_top_white.clipsToBounds = true
        ui_view_top_white.addRadiusTopOnly(radius: radius_main_view)
    }
    
    func updatePartner() {
        if let _url = partner?.largeLogoUrl, let mainUrl = URL(string: _url) {
            ui_image_partner.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_asso"))
        }
        
        self.ui_tableview.reloadData()
    }
    
    func updateFollowing(isFollowing:Bool) {
        guard let _asso = partner else {
            return
        }
        UserService.updateUserPartnerFollow(partnerId: _asso.aid!, isFollowing: isFollowing) { [weak self] error in
            if error == nil {
                self?.partner?.isFollowing = isFollowing
                self?.updatePartner()
            }
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource,UITableViewDelegate -
extension PartnerDetailViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if partner == nil {
            return 0
        }
        
        if partner!.donations_needs?.isEmpty ?? true && partner!.volunteers_needs?.isEmpty ?? true {
            hasPartnerNeeds = false
            return 2
        }
        hasPartnerNeeds = true
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! PartnerDetailTopCell
            cell.populateCell(partner:partner, delegate: self)
            return cell
        }
        
        if hasPartnerNeeds && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNeeds", for: indexPath) as! PartnerDetailNeedsCell
            cell.populateCell(partner:partner)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInfo", for: indexPath) as! PartnerDetailInfoCell
        cell.populateCell(partner:partner, delegate: self)
        return cell
    }
}

//MARK: - PartnerDetailInfoCellDelegate -
extension PartnerDetailViewController: PartnerDetailInfoCellDelegate {
    func followUnfollow() {
        if partner?.isFollowing ?? false {
            let customAlert = MJAlertController()
            let buttonAccept = MJAlertButtonType(title: "Yes".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
            let buttonCancel = MJAlertButtonType(title: "No".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
            
            customAlert.configureAlert(alertTitle: "partner_pop_unfollow_title".localized, message: "partner_pop_unfollow_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
            
            customAlert.alertTagName = .None
            customAlert.delegate = self
            customAlert.show()
        }
        else {
            self.updateFollowing(isFollowing: true)
        }
    }
    
    func showAddress(address: String?) {
        if let _address = address,let _addressEncoded = "https://maps.apple.com/?address=\(_address)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),  let url = URL(string: _addressEncoded) {
            sendAction(url: url)
        }
    }
    
    func showWebsite(website: String?) {
        if let newUrl = website {
            var urlReal = newUrl
            if !newUrl.contains("http") || !newUrl.contains("https")  {
                urlReal = String.init(format: "http://%@", newUrl)
            }
            if let url = URL(string: urlReal) {
                sendAction(url: url)
            }
        }
    }
    
    func sendCall(phone: String?) {
        if let _phone = phone, let url = URL(string: "tel://\(_phone)") {
            sendAction(url: url)
        }
    }
    
    func sendEmail(email: String?) {
        if let _email = email, MFMailComposeViewController.canSendMail()  {
            let controller = MFMailComposeViewController()
            controller.setMessageBody("", isHTML: true)
            controller.setToRecipients([_email])
            controller.mailComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            IHProgressHUD.showError(withStatus: "about_email_notavailable".localized)
        }
    }
    
    func sendAction(url:URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

//MARK: - MFMessageComposeViewControllerDelegate -
extension PartnerDetailViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PartnerDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - MJNavBackViewDelegate -
extension PartnerDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}

//MARK: - MJAlertControllerDelegate -
extension PartnerDetailViewController:MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
    }
    func validateRightButton(alertTag: MJAlertTAG) {
        self.updateFollowing(isFollowing: false)
    }
    func closePressed(alertTag: MJAlertTAG) {}
}
