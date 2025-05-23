//
//  UserProfileDetailViewController.swift
//  entourage
//
//  Created by Jerome on 28/03/2022.
//

import UIKit
import IHProgressHUD

class UserProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_view_top_white: UIView!
    @IBOutlet weak var ui_view_img_profile: UIView!
    @IBOutlet weak var ui_image_user: UIImageView!
    @IBOutlet weak var ui_iv_logo: UIImageView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    
    var currentUser:User? = nil
    
    var currentUserId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhotoUI()
        
        ui_top_view.populateCustom(imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.estimatedRowHeight = 200
        
        //TODO: on affiche le fond transparent pour l'alerte ou un fond blanc ?
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        loadUser()
    }
    
    func loadUser() {
        UserService.getDetailsForUser(userId: currentUserId) { user, error in
            if let user = user {
                self.currentUser = user
                self.updateUser()
            }
            else {
                Logger.print("***** erreur recup detail user \(error?.error?.localizedDescription)")
                //TODO: afficher erruer ?
                self.goBack()
            }
        }
    }
    
    func setupPhotoUI() {
        ui_image_user.layer.cornerRadius = ui_image_user.frame.height / 2
        
        ui_view_img_profile.layer.cornerRadius = ui_image_user.frame.height / 2
        ui_view_img_profile.layer.borderColor = UIColor.appBeigeClair.cgColor
        ui_view_img_profile.layer.borderWidth = 1
        
        ui_view_img_profile.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        ui_view_img_profile.layer.shadowOpacity = 1
        ui_view_img_profile.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        ui_view_img_profile.layer.shadowRadius = 10
        
        ui_view_img_profile.layer.rasterizationScale = UIScreen.main.scale
        ui_view_img_profile.layer.shouldRasterize = true
        
        ui_view_top_white.clipsToBounds = true
        ui_view_top_white.addRadiusTopOnly(radius: ApplicationTheme.bigCornerRadius)
    }
    
    func updateUser() {
        if let user = currentUser,let _url = user.avatarURL, let mainUrl = URL(string: _url) {
            ui_image_user.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_image_user.image = UIImage.init(named: "placeholder_user")
        }
        self.ui_tableview.reloadData()
    }
    
    @IBAction func action_signal_user(_ sender: Any) {
        if let vc = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "reportUserMainVC") as? ReportUserMainViewController {
            vc.user = currentUser
            vc.parentDelegate = self
            DispatchQueue.main.async {
                self.navigationController?.present(vc, animated: true)
            }
        }
    }
}

//MARK: - UserProfileDetailDelegate -
extension UserProfileDetailViewController:UserProfileDetailDelegate {
    func showMessage(message: String, imageName: String?) {
        IHProgressHUD.showSuccesswithStatus(message)
        //TODO: on garde cet affichage de message ?
//        ui_error_view.changeTitleAndImage(title: message,imageName: imageName)
//        ui_error_view.show()
    }
}

//MARK: - UITableViewDataSource,UITableViewDelegate -
extension UserProfileDetailViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let addSignal = currentUser?.sid == UserDefaults.currentUser?.sid ? 0 : 1
        if let currentUser = currentUser {
            if currentUser.interests?.count ?? 0 > 0  {
                return 3 + addSignal
            }
            return 2 + addSignal
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentUser = currentUser else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            let isMe = UserDefaults.currentUser?.sid == currentUser.sid
            let cellIdent = isMe ? "cellUserInfoMeTop" : "cellUserInfoTop"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath) as! MainUserProfileTopCell
            cell.populateCell(isMe:isMe ,username: currentUser.displayName, role: currentUser.roles?.first, partner: currentUser.partner, bio: currentUser.about,delegate: self)
            return cell
        }
        
        switch indexPath.row {
        case 1: let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserInfoActivities", for: indexPath) as! MainUserActivitiesCell
            let isMe = UserDefaults.currentUser?.sid == currentUser.sid
            let stats:UserStats = currentUser.stats ?? UserStats()
            cell.populateCell(isMe:isMe ,neighborhoodsCount: stats.neighborhoodsCount, outingsCount: stats.outingsCount ?? -1, myDate:currentUser.creationDate)
            return cell
        case 2:
            if currentUser.interests?.count ?? 0 == 0  {
                break
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserInfoCats", for: indexPath) as! CategoriesBubblesCell
            cell.populateCell(interests: currentUser.interests,tagAlignment: .left)
            return cell
            
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSignal", for: indexPath)
        return cell
    }
}

//MARK: - MainUserProfileTopCellDelegate -
extension UserProfileDetailViewController: MainUserProfileTopCellDelegate {
    func sendMessage() {
        guard let currentUserId = currentUserId else {return}
        IHProgressHUD.show()
        MessagingService.createOrGetConversation(userId: currentUserId) { conversation, error in
            IHProgressHUD.dismiss()
            
            if let conversation = conversation {
                self.showConversation(conversation: conversation)
                return
            }
            var errorMsg = "message_error_create_conversation".localized
            if let error = error {
                errorMsg = error.message
            }
            IHProgressHUD.showError(withStatus: errorMsg)
        }
    }
    
    private func showConversation(conversation:Conversation?) {
        DispatchQueue.main.async {
            if let convId = conversation?.uid {
                let sb = UIStoryboard.init(name: StoryboardName.messages, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                    vc.setupFromOtherVC(conversationId: convId, title: self.currentUser?.displayName, isOneToOne: true, conversation: conversation)
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
    func showPartner() {
        if let navVc = UIStoryboard.init(name:StoryboardName.partnerDetails, bundle: nil).instantiateInitialViewController() as? UINavigationController {
            if let vc = navVc.topViewController as? PartnerDetailViewController {
                if let id = currentUser?.partner?.aid {
                    vc.partnerId = id
                }
                else {
                    vc.partner = currentUser?.partner
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.present(navVc, animated: true)
                }
            }
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension UserProfileDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
    func didTapEvent() {
        //Nothing yet
    }
}

//MARK: - Protocol UserProfileDetailDelegate -
protocol UserProfileDetailDelegate: AnyObject {
    func showMessage(message:String, imageName:String?)
}
