//
//  NeighborhoodPostCell.swift
//  entourage
//
//  Created by Jerome on 13/05/2022.
//

import UIKit
import ActiveLabel

class NeighborhoodPostCell: UITableViewCell {
    @IBOutlet weak var ui_view_container: UIView!
    
    @IBOutlet weak var ui_iv_user: UIImageView!
    @IBOutlet weak var ui_username: UILabel!
    
    @IBOutlet weak var ui_date: UILabel!
    
    @IBOutlet weak var ui_comment: ActiveLabel!
    
    @IBOutlet weak var ui_comments_nb: UILabel!
    
    @IBOutlet weak var ui_image_post: UIImageView!
    
    @IBOutlet weak var ui_view_comment_post: UIView!
    @IBOutlet weak var ui_view_comment: UIView!
    
    
    @IBOutlet weak var ui_label_ambassador: UILabel!
    
    @IBOutlet weak var ui_btn_signal_post: UIButton!
    
    @IBOutlet weak var ui_view_translate: UIView!
    @IBOutlet weak var ui_label_translate: UILabel!
    
    @IBOutlet weak var ui_view_btn_i_like: UIView!
    
    @IBOutlet weak var ui_view_btn_i_comment: UIView!
    
    @IBOutlet weak var ui_reaction_stackview: UIStackView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    weak var delegate:NeighborhoodPostCellDelegate? = nil
    var postId:Int = 0
    var currentIndexPath:IndexPath? = nil
    var userId:Int? = nil
    var imageUrl:URL? = nil
    var isTranslated: Bool = !LanguageManager.getTranslatedByDefaultValue()

    
    var postMessage:PostMessage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        ui_view_container.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_iv_user.layer.cornerRadius = ui_iv_user.frame.height / 2
        
        ui_username.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoBold(size: 12), color: .black))
        ui_date.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoLight(size: 9), color: .black))
        ui_comment.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_comments_nb.setupFontAndColor(style: ApplicationTheme.getFontChampInput())
        ui_comment.enableLongPressCopy()
        ui_image_post?.layer.cornerRadius = 8
        if ui_view_comment != nil {
            ui_view_comment.layer.cornerRadius = ui_view_comment.frame.height / 2

            ui_btn_signal_post.addTarget(self, action: #selector(signalClicked), for: .touchUpInside)
        }
        if ui_view_btn_i_comment != nil {
            let commentTapGesture = UITapGestureRecognizer(target: self, action: #selector(commentTapped))
              ui_view_btn_i_comment.addGestureRecognizer(commentTapGesture)
              ui_view_btn_i_comment.isUserInteractionEnabled = true
        }
        let commentsLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(commentLabelTapped))
           ui_comments_nb.addGestureRecognizer(commentsLabelTapGesture)
           ui_comments_nb.isUserInteractionEnabled = true  // Assure-toi que l'interaction utilisateur est activée
        
        if(ui_view_btn_i_like != nil){
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                ui_view_btn_i_like.addGestureRecognizer(longPressGesture)
        }
    }
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            showReactionsPopup()
        }
    }
    
    @objc func commentTapped() {
        delegate?.showMessages(addComment: true, postId: postId, indexPathSelected: currentIndexPath, postMessage: postMessage)
    }
    
    @objc func commentLabelTapped() {
        delegate?.showMessages(addComment: false, postId: postId, indexPathSelected: currentIndexPath, postMessage: postMessage)
    }
    
    func toggleTranslation() {
        isTranslated.toggle()
        // Mise à jour de ui_label_translate
        if let ui_label_translate = ui_label_translate {
            let text = isTranslated ? "layout_translate_title_original".localized : "layout_translate_title_translation".localized
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let underlineAttributedString = NSAttributedString(string: text, attributes: underlineAttribute)
            ui_label_translate.attributedText = underlineAttributedString
            ui_label_translate.font = UIFont(name: "Quicksand-Bold", size: 13)
            ui_label_translate.textColor = UIColor.orange
            ui_label_translate.isHighlighted = true
        }

        
        // Mise à jour de ui_comment
        if isTranslated {
            if let _translation = postMessage.contentTranslations{
                ui_comment.text = _translation.translation
            }
        } else {
            if let _translation = postMessage.contentTranslations {
                ui_comment.text = _translation.original
            }
        }
    }


    @objc func toggleTranslationGesture() {
        toggleTranslation()
    }
    
    @objc func signalClicked(){
        self.delegate?.signalPost(postId: self.postId, userId: self.userId!, textString: self.postMessage.content ?? "")
    }
    
    func removeButton() {
        ui_view_comment_post.removeFromSuperview()
        ui_btn_signal_post.removeFromSuperview()
    }
    
    func setTranslatedText(){
        
    }
    func showReactionsPopup() {
        guard let storedReactions = getStoredReactionTypes() else { return }

        let popupWidth: CGFloat = 250
        let popupHeight: CGFloat = 50
        let xOffset: CGFloat = 40 // Décalage sur la droite

        // Trouver la position du bouton dans la fenêtre de l'application
        guard let buttonFrame = ui_view_btn_i_like.superview?.convert(ui_view_btn_i_like.frame, to: nil) else { return }

        // Calculer la position de la popup
        let popupFrame = CGRect(x: buttonFrame.midX - (popupWidth / 2) + xOffset, y: buttonFrame.minY - popupHeight, width: popupWidth, height: popupHeight)

        let popupView = ReactionsPopupView(reactions: storedReactions, frame: popupFrame, delegate: self)
        
        // Ajouter la popup à la fenêtre de l'application
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(popupView)
        }
    }

    
    /* guard let _stackview = ui_reaction_stackview else{return} */
    func displayReactions(for postMessage: PostMessage) {
        guard let storedReactions = getStoredReactionTypes() else { return }
        guard let _stackview = ui_reaction_stackview else{return}
        // Réinitialiser le stack view
        _stackview.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var totalReactionsCount = 0

        postMessage.reactions?.forEach { reaction in
                if let reactionType = storedReactions.first(where: { $0.id == reaction.reactionId }) {
                let container = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                container.layer.cornerRadius = container.frame.height / 2
                container.layer.masksToBounds = true
                container.layer.borderColor = UIColor.appGrey151.cgColor
                container.layer.borderWidth = 1.0
                container.backgroundColor = .white

                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(imageView)

                // Contraintes pour le padding
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
                    imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2),
                    imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
                    imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -2)
                ])

                imageView.contentMode = .scaleAspectFit

                if let imageUrl = URL(string: reactionType.imageUrl ?? "") {
                    // Charger l'image depuis imageUrl
                    imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "default_reaction_icon"))
                }
                _stackview.addArrangedSubview(container)
                totalReactionsCount += reaction.reactionsCount
            }
        }

        if totalReactionsCount > 0 {
            let reactionsCountLabel = UILabel()
            reactionsCountLabel.text = "  " + "\(totalReactionsCount)"
            _stackview.addArrangedSubview(reactionsCountLabel)
        }
        layoutIfNeeded()
    }



    
    func populateCell(message:PostMessage, delegate:NeighborhoodPostCellDelegate, currentIndexPath:IndexPath?, userId:Int?) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleTranslationGesture))

        if(ui_view_translate != nil){
            ui_view_translate.addGestureRecognizer(tapGesture)
        }

        
        self.postMessage = message
        self.delegate = delegate
        ui_username.text = message.user?.displayName
        ui_date.text = message.createdDateFormatted
        ui_comment.handleURLTap { url in
            // Ouvrez le lien dans Safari, par exemple
            delegate.showWebviewUrl(url: url)
        }
        if postMessage.contentTranslations == nil {
            ui_comment.text = postMessage.content
        }
        
        if let _status = message.status {
            if _status == "deleted" {
                ui_comment.text = "deleted_post_text".localized
                ui_comment.textColor = UIColor.appGrey151
                ui_btn_signal_post.isHidden = true
            }else{
                ui_comment.textColor = .black
                ui_btn_signal_post.isHidden = false
                toggleTranslation()
            }
        }
        
        self.currentIndexPath = currentIndexPath
        postId = message.uid
        self.userId = userId
        
        if let _url = message.user?.avatarURL, let url = URL(string: _url) {
            ui_iv_user.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_iv_user.image = UIImage.init(named: "placeholder_user")
        }
        
        if message.commentsCount == 0 {
            ui_comments_nb.text = "neighborhood_post_noComment".localized
            
            ui_comments_nb.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 13), color: .appGrisSombre40))

        }
        else {
            let msg:String = message.commentsCount ?? 0 <= 1 ? "neighborhood_post_1Comment".localized : "neighborhood_post_XComments".localized
            
            let attrStr = Utils.formatStringUnderline(textString: String.init(format: msg, message.commentsCount ?? 0), textColor: .black, font: ApplicationTheme.getFontChampInput().font)
            ui_comments_nb.attributedText = attrStr
        }
        
        if let urlStr = message.messageImageUrl, let url = URL(string: urlStr) {
            ui_image_post?.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_post"))
            imageUrl = url
        }
        else {
            ui_image_post?.image = UIImage.init(named: "placeholder_post")
        }
        
        var tagString = ""
        if let _user = message.user {
            if _user.isAdmin() {
                tagString = tagString + "title_is_admin".localized + " •"
            }
            if _user.isAmbassador() {
                tagString = tagString + "title_is_ambassador".localized + " •"
            }
            if let _partner = _user.partner {
                tagString = tagString + _partner.name + " •"
            }
        }
        if tagString.isEmpty {
            ui_label_ambassador.isHidden = true
        }else{
            if tagString.last == "•" {
                tagString.removeLast()
            }
            ui_label_ambassador.isHidden = false
            ui_label_ambassador.text = tagString
        }
        
        displayReactions(for: message)
        
    }
    func getStoredReactionTypes() -> [ReactionType]? {
        guard let reactionsData = UserDefaults.standard.data(forKey: "StoredReactions") else { return nil }
        do {
            let reactions = try JSONDecoder().decode([ReactionType].self, from: reactionsData)
            return reactions
        } catch {
            print("Erreur de décodage des réactions : \(error)")
            return nil
        }
    }


    @IBAction func action_show_comments(_ sender: Any) {
        delegate?.showMessages(addComment: false,postId: postId, indexPathSelected: currentIndexPath,postMessage:postMessage)
    }
    
    @IBAction func action_add_comments(_ sender: Any) {
        delegate?.showMessages(addComment: true,postId: postId, indexPathSelected: currentIndexPath,postMessage: postMessage)
    }
    
    @IBAction func action_show_user(_ sender: Any) {
        delegate?.showUser(userId: userId)
    }
    
    @IBAction func action_show_image(_ sender: Any) {
        delegate?.showImage(imageUrl: imageUrl, postId: self.postId)
    }
}

protocol NeighborhoodPostCellDelegate: AnyObject {
    func showMessages(addComment:Bool, postId:Int, indexPathSelected:IndexPath?, postMessage:PostMessage?)
    func showUser(userId:Int?)
    func showImage(imageUrl:URL?, postId:Int)
    func signalPost(postId:Int, userId:Int, textString:String)
    func showWebviewUrl(url:URL)
    func addReaction(post:PostMessage, reactionType:ReactionType)
    func deleteReaction(post:PostMessage, reactionType:ReactionType)
    
}

extension NeighborhoodPostCell: ReactionsPopupViewDelegate {
    func reactForPost(reactionType: ReactionType) {
        self.delegate?.addReaction(post: self.postMessage, reactionType: reactionType)
        
    }

    func getReactionTypeById(_ id: Int) -> ReactionType? {
        // Retourne le ReactionType correspondant à l'ID
        return getStoredReactionTypes()?.first { $0.id == id }
    }
}



class NeighborhoodPostTextCell: NeighborhoodPostCell {
    //override class var identifier: String {return self.description()}
}

class NeighborhoodPostImageCell: NeighborhoodPostCell {
   // override class var identifier: String {return self.description()}
}
class NeighborhoodPostDeletedCell:NeighborhoodPostCell{
    
}
class NeighborhoodPostTranslationCell:NeighborhoodPostCell{
    
}
class NeighborhoodPostImageTranslationCell:NeighborhoodPostCell{
    
}

protocol ReactionsPopupViewDelegate: AnyObject {
    func reactForPost(reactionType: ReactionType)
    func getReactionTypeById(_ id: Int) -> ReactionType?
}

class ReactionsPopupView: UIView {

    weak var delegate: ReactionsPopupViewDelegate?
    
    init(reactions: [ReactionType], frame: CGRect, delegate: ReactionsPopupViewDelegate?) {
        super.init(frame: frame)
        self.delegate = delegate
        self.backgroundColor = .white
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10

        for reaction in reactions {
            let imageView = UIImageView()
            if let imageUrl = URL(string: reaction.imageUrl ?? "") {
                imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "default_reaction_icon"))
            }
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reactionTapped))
            imageView.addGestureRecognizer(tapGesture)
            imageView.tag = reaction.id
            stackView.addArrangedSubview(imageView)

            imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }

        self.addSubview(stackView)
        NSLayoutConstraint.activate([
                  stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),      // Padding en haut
                  stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5), // Padding en bas
                  stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10), // Padding à gauche
                  stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10) // Padding à droite
              ])
    }
    func dismiss() {
        self.removeFromSuperview()
    }

    @objc func reactionTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        let reactionId = imageView.tag
        if let reaction = delegate?.getReactionTypeById(reactionId) {
            delegate?.reactForPost(reactionType: reaction)
        }
        dismiss()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


