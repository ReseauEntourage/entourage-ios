//
//  ConversationsMainHomeViewController.swift
//  entourage
//
//  Created by Jerome on 19/08/2022.
//

import UIKit
import IHProgressHUD

class ConversationsMainHomeViewController: UIViewController {
    
    @IBOutlet weak var ui_image_inside_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_image_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    
    @IBOutlet weak var ui_constraint_bottom_label: NSLayoutConstraint!
    
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_view_selector: UIView!
    
    var maxViewHeight:CGFloat = 109 //134
    var minViewHeight:CGFloat = 83//108
    
    var minLabelBottomConstraint:CGFloat = 9
    var maxLabelBottomConstraint:CGFloat = 16
    
    var minLabelFont:CGFloat = 16
    var maxLabelFont:CGFloat = 23
    
    var minImageHeight:CGFloat = 0
    var maxImageHeight:CGFloat = 66
    
    var viewNormalHeight:CGFloat = 0
    var labelNormalConstraintBottom:CGFloat = 0
    var labelNormalFontHeight:CGFloat = 0
    var imageNormalHeight:CGFloat = 0
    
    var topSafeAreaInsets:CGFloat = 0
    
    var pullRefreshControl = UIRefreshControl()
    
    var currentPage = 1
    let numberOfItemsForWS = 25 // Arbitrary nb of items used for pagging
    let nbOfItemsBeforePagingReload = 10 // Arbitrary nb of items from the end of the list to send new call
    var isLoading = false
    
    var messages = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        setupViews()
        getMessages()
        
        //Notif for updating messages after tabbar selected
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatasFromTab), name: NSNotification.Name(rawValue: kNotificationMessagesUpdate), object: nil)
    }
    
    //MARK: - Call from Notifications -
    @objc func refreshDatasFromTab() {
        if self.messages.count > 0 {
            self.gotoTop(isAnimated:false)
        }
        refreshDatas()
    }
    
    @objc func refreshDatas() {
        currentPage = 1
        getMessages()
    }
    
    func setupViews() {
        
        ui_view_selector.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_view_selector.layer.maskedCorners = CACornerMask.radiusTopOnly()
        
        maxImageHeight = ui_image_constraint_height.constant
        imageNormalHeight = maxImageHeight
        
        self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: maxLabelFont)
        self.ui_label_title.text = "Messages_title".localized
        
        labelNormalFontHeight = maxLabelFont
        
        ui_constraint_bottom_label.constant = maxLabelBottomConstraint
        labelNormalConstraintBottom = ui_constraint_bottom_label.constant
        
        ui_view_height_constraint.constant = maxViewHeight
        viewNormalHeight = ui_view_height_constraint.constant
        
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            if let topPadding = window?.safeAreaInsets.top {
                topSafeAreaInsets = topPadding
            }
        }
        else {
            let window = UIApplication.shared.keyWindow
            if let topPadding = window?.safeAreaInsets.top {
                topSafeAreaInsets = topPadding
            }
        }
        
        ui_image_inside_top_constraint.constant = ui_image_inside_top_constraint.constant - topSafeAreaInsets
        
        ui_tableview.contentInset = UIEdgeInsets(top: viewNormalHeight ,left: 0,bottom: 0,right: 0)
        ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: viewNormalHeight ,left: 0,bottom: 0,right: 0)
        
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
    }
    
    //MARK: - Network
    func getMessages() {
        if self.isLoading { return }
        if self.messages.isEmpty { self.ui_tableview.reloadData() }
        
        IHProgressHUD.show()
        
        self.isLoading = true
        
        MessagingService.getAllConversations(currentPage: currentPage, per: numberOfItemsForWS) { messages, error in
            IHProgressHUD.dismiss()
            self.pullRefreshControl.endRefreshing()
            if let messages = messages {
                if self.currentPage > 1 {
                    self.messages.append(contentsOf: messages)
                }
                else {
                    self.messages = messages
                }
            }
            self.isLoading = false
            self.ui_tableview.reloadData()
        }
    }
    
    func gotoTop(isAnimated:Bool = true) {
        if messages.count == 0 { return }
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
        }
    }
}

//MARK: - Tableview datasource / delegate -
extension ConversationsMainHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! ConversationListMainCell
        
        let message = messages[indexPath.row]
        
        cell.populateCell(message: message, delegate: self, position: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
            let conv = messages[indexPath.row]
            vc.setupFromOtherVC(conversationId: conv.uid, title: conv.title, isOneToOne: conv.isOneToOne(), conversation: conv, delegate: self,selectedIndexPath: indexPath)
            
            self.present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        
        let lastIndex = messages.count - nbOfItemsBeforePagingReload
        if indexPath.row == lastIndex && self.messages.count >= numberOfItemsForWS * currentPage {
            self.currentPage = self.currentPage + 1
            self.getMessages()
        }
    }
    
    func scrollViewDidScroll( _ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0) {
            
            let yImage = self.imageNormalHeight - (scrollView.contentOffset.y+self.imageNormalHeight)
            let diffImage = (self.maxViewHeight - self.maxImageHeight)
            let heightImage = min(max (yImage -  diffImage,self.minImageHeight),self.maxImageHeight)
            
            self.ui_image.alpha = heightImage / self.maxImageHeight
            
            let yView = self.viewNormalHeight - (scrollView.contentOffset.y + self.viewNormalHeight)
            let heightView = min(max (yView,self.minViewHeight),self.maxViewHeight)
            self.ui_view_height_constraint.constant = heightView
            
            //On évite de calculer et repositionner les vues inutiliement.
            if self.ui_view_height_constraint.constant <= self.minViewHeight {
                self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: self.minLabelFont)
                return
            }
            
            self.ui_image.isHidden = false
            
            let yLabel = self.labelNormalConstraintBottom - (scrollView.contentOffset.y + self.labelNormalConstraintBottom)
            let heightLabel = min(max (yLabel,self.minLabelBottomConstraint),self.maxLabelBottomConstraint)
            
            self.ui_constraint_bottom_label.constant = heightLabel
            
            let yLabelFont = self.labelNormalFontHeight - (scrollView.contentOffset.y + self.labelNormalFontHeight)
            var heightCalculated = (self.minLabelFont * yLabelFont) / self.minViewHeight
            if yLabelFont >= self.maxViewHeight - 2 {
                heightCalculated = self.maxLabelFont
            }
            let heightLabelFont = min(max (heightCalculated,self.minLabelFont),self.maxLabelFont)
            
            self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: heightLabelFont)
            
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - ConversationListMainCellDelegate -
extension ConversationsMainHomeViewController: ConversationListMainCellDelegate {
    func showUserDetail(_ position: Int) {
        //TODO: not use actually ;)
        
        let userId:Int? = messages[position].user?.uid
        guard let userId = userId else {
            return
        }
        
        if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(userId)"
                
                self.present(navVC, animated: true)
            }
        }
    }
}

//MARK: - UpdateUnreadCountDelegate -
extension ConversationsMainHomeViewController:UpdateUnreadCountDelegate {
    func updateUnreadCount(conversationId: Int, currentIndexPathSelected: IndexPath?) {
        guard let currentIndexPathSelected = currentIndexPathSelected else {
            return
        }
        
        messages[currentIndexPathSelected.row].numberUnreadMessages = 0
        self.ui_tableview.reloadRows(at: [currentIndexPathSelected], with: .none)
    }
}
