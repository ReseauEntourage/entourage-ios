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
    
    @IBOutlet weak var ui_label_select_option: UILabel!
    @IBOutlet weak var ui_label_nb_votes: UILabel!
    
    @IBOutlet weak var ui_label_ambassador: UILabel!
    
    @IBOutlet weak var ui_btn_signal_post: UIButton!
    
    @IBOutlet weak var ui_view_translate: UIView!
    @IBOutlet weak var ui_label_translate: UILabel!
    
    @IBOutlet weak var ui_view_btn_i_like: UIView!
    
    @IBOutlet weak var ui_view_btn_i_comment: UIView!
    
    @IBOutlet weak var ui_reaction_stackview: UIStackView!
    
    @IBOutlet weak var ui_image_react_btn: UIImageView!
    @IBOutlet weak var ui_label_i_like: UILabel!
    @IBOutlet weak var ui_stackview_options: UIStackView!
    
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
        let voteLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(voteLabelTapped))
           ui_comments_nb.addGestureRecognizer(commentsLabelTapGesture)
        
           ui_comments_nb.isUserInteractionEnabled = true  // Assure-toi que l'interaction utilisateur est activée
        if ui_label_nb_votes != nil {
            ui_label_nb_votes.addGestureRecognizer(voteLabelTapGesture)
            ui_label_nb_votes.isUserInteractionEnabled = true  // Assure-toi que l'interaction utilisateur est activée
        }
        if(ui_view_btn_i_like != nil){
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                ui_view_btn_i_like.addGestureRecognizer(longPressGesture)
        }
        if ui_view_btn_i_like != nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLittleTap))
            ui_view_btn_i_like.addGestureRecognizer(tapGesture)
        }
    }
    @objc func handleLittleTap(gesture: UITapGestureRecognizer) {
        AnalyticsLoggerManager.logEvent(name: Clic_Post_Like)
        if gesture.state == .ended {
            // Vérifier si l'utilisateur a déjà réagi
            if postMessage.reactionId == 0 || postMessage.reactionId == nil, let firstReactionType = getStoredReactionTypes()?.first {
                // Ajouter la première réaction disponible
                updateReaction(reactionType: firstReactionType, add: true)
                delegate?.addReaction(post: self.postMessage, reactionType: firstReactionType)
            } else {
                // Supprimer la réaction existante si l'utilisateur a déjà réagi
                if let existingReactionType = getReactionTypeById(postMessage.reactionId ?? 0) {
                    updateReaction(reactionType: existingReactionType, add: false)
                    delegate?.deleteReaction(post: self.postMessage, reactionType: existingReactionType)
                }
            }
        }
    }
    func configureWithSurvey(survey: Survey) {
        // Assurez-vous que surveyResponse a le bon nombre d'éléments
        if postMessage.surveyResponse == nil || postMessage.surveyResponse?.count != survey.choices.count {
            postMessage.surveyResponse = Array(repeating: false, count: survey.choices.count)
        }
        
        guard let surveyResponses = postMessage.surveyResponse else { return }
        
        if ui_label_select_option != nil {
            if let _multiple = postMessage.survey?.multiple{
                if _multiple == true {
                    ui_label_select_option.text = "Sélectionnez une ou plusieurs options"
                }else {
                    ui_label_select_option.text = "Sélectionnez une option"
                }
            }
        }
        
        ui_stackview_options.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let totalVotes = survey.summary.reduce(0, +)
        survey.choices.enumerated().forEach { index, choice in
            let surveyOptionView = SurveyOptionView()
            surveyOptionView.questionLabel.text = choice
            surveyOptionView.optionIndex = index
            surveyOptionView.radioButton.isSelected = surveyResponses[index]

            let votes = survey.summary[index]
            let votePercentage = totalVotes > 0 ? Float(votes) / Float(totalVotes) : 0
            surveyOptionView.progressBar.progress = votePercentage
            surveyOptionView.answerCountLabel.text = "\(votes)"
            surveyOptionView.delegate = self

            ui_stackview_options.addArrangedSubview(surveyOptionView)
        }
        layoutIfNeeded()
    }


    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            AnalyticsLoggerManager.logEvent(name: Clic_Post_List_Reactions)
            showReactionsPopup()
        }
    }
    
    @objc func commentTapped() {
        delegate?.showMessages(addComment: true, postId: postId, indexPathSelected: currentIndexPath, postMessage: postMessage)
    }
    
    @objc func commentLabelTapped() {
        delegate?.showMessages(addComment: false, postId: postId, indexPathSelected: currentIndexPath, postMessage: postMessage)
    }
    @objc func voteLabelTapped() {
        self.delegate?.sendVoteView(post: self.postMessage)

    }

    
    func updateReactionIcon() {
        if ui_image_react_btn != nil {
            print("eho postMessage reactionId " , postMessage.reactionId)
            // Mettre à jour l'icône en fonction de la valeur de reactionId
            if postMessage.reactionId == 0 || postMessage.reactionId == nil  {
                ui_image_react_btn.image = UIImage(named: "ic_i_like_grey")
                ui_label_i_like.textColor = UIColor.black
            } else {
                ui_image_react_btn.image = UIImage(named: "ic_i_like")
                ui_label_i_like.textColor = UIColor.appOrange
            }
        }
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

    class RoundedView: UIView {
        override var bounds: CGRect {
            didSet {
                layer.cornerRadius = bounds.size.width / 2
            }
        }
    }
    /* guard let _stackview = ui_reaction_stackview else{return} */
    func displayReactions(for postMessage: PostMessage) {
        guard let storedReactions = getStoredReactionTypes() else { return }
        guard let _stackview = ui_reaction_stackview else { return }
        _stackview.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var totalReactionsCount = 0

        postMessage.reactions?.forEach { reaction in
            if let reactionType = storedReactions.first(where: { $0.id == reaction.reactionId }) {
                let container = RoundedView()
                container.translatesAutoresizingMaskIntoConstraints = false
                container.layer.masksToBounds = true
                container.layer.borderColor = UIColor.appGrisReaction.cgColor
                container.layer.borderWidth = 1.0
                container.backgroundColor = .white

                let imageView = UIImageView()
                imageView.backgroundColor = .white
                imageView.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(imageView)

                // Contraintes pour le container et le padding de l'image
                NSLayoutConstraint.activate([
                    container.widthAnchor.constraint(equalToConstant: 25),
                    container.heightAnchor.constraint(equalToConstant: 25),
                    imageView.widthAnchor.constraint(equalToConstant: 15),
                    imageView.heightAnchor.constraint(equalToConstant: 15),
                    imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
                ])

                imageView.contentMode = .scaleAspectFill

                if let imageUrl = URL(string: reactionType.imageUrl ?? "") {
                    imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_i_like"))
                }
                _stackview.addArrangedSubview(container)
                totalReactionsCount += reaction.reactionsCount
            }
        }

        // Ajouter des contraintes au stack view lui-même si nécessaire
        // Par exemple, si votre stack view doit avoir une hauteur spécifique
        NSLayoutConstraint.activate([
            _stackview.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        _stackview.layoutIfNeeded()

        if totalReactionsCount > 0 {
            let reactionsCountLabel = UILabel()
            reactionsCountLabel.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 13), color: .black))
            reactionsCountLabel.text = "  " + "\(totalReactionsCount)"
            reactionsCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            _stackview.addArrangedSubview(reactionsCountLabel)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stackViewTapped))
        _stackview.isUserInteractionEnabled = true
        _stackview.addGestureRecognizer(tapGesture)
    }
    
    @objc func stackViewTapped() {
        AnalyticsLoggerManager.logEvent(name: Clic_ListReactions_Contact)
        delegate?.onReactClickSeeMember(post: postMessage) // Assure-toi que `delegate` et `postMessage` sont accessibles ici
    }

    func updateReaction(reactionType: ReactionType, add: Bool) {
        if add {
            // Ajouter une réaction
            postMessage.reactionId = reactionType.id
            if let index = postMessage.reactions?.firstIndex(where: { $0.reactionId == reactionType.id }) {
                // La réaction existe déjà, augmenter le compteur
                postMessage.reactions?[index].reactionsCount += 1
            } else {
                // Ajouter une nouvelle réaction
                let newReaction = Reaction(reactionId: reactionType.id, chatMessageId: postId, reactionsCount: 1)
                if postMessage.reactions != nil {
                    postMessage.reactions?.append(newReaction)
                } else {
                    postMessage.reactions = [newReaction]
                }
            }
        } else {
            // Supprimer une réaction
            postMessage.reactionId = 0
            if let index = postMessage.reactions?.firstIndex(where: { $0.reactionId == reactionType.id }) {
                if postMessage.reactions?[index].reactionsCount ?? 0 > 1 {
                    postMessage.reactions?[index].reactionsCount -= 1
                } else {
                    postMessage.reactions?.remove(at: index)
                }
            }
        }

        // Mettre à jour l'affichage des réactions
        updateReactionIcon()
        displayReactions(for: postMessage)
    }

    
    func populateCell(message:PostMessage, delegate:NeighborhoodPostCellDelegate, currentIndexPath:IndexPath?, userId:Int?, isMember:Bool?) {
        print("eho passed here ? ")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleTranslationGesture))

        if(ui_view_translate != nil){
            ui_view_translate.addGestureRecognizer(tapGesture)
        }

        
        self.postMessage = message
        self.delegate = delegate
        if self.postMessage.survey != nil && self.ui_stackview_options != nil {
            configureWithSurvey(survey: self.postMessage.survey!)
        }
        updateReactionIcon()
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
            //ui_comments_nb.text = "neighborhood_post_noComment".localized
            ui_comments_nb.text = ""
            
            ui_comments_nb.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 13), color: .appGrisSombre40))

        }else {
            let msg:String = message.commentsCount ?? 0 <= 1 ? "neighborhood_post_1Comment".localized : "neighborhood_post_XComments".localized
            
            let attrStr = Utils.formatStringUnderline(textString: String.init(format: msg, message.commentsCount ?? 0), textColor: .black, font: ApplicationTheme.getFontChampInput().font)
            ui_comments_nb.attributedText = attrStr
        }
        
        if let survey = message.survey {
            let totalVotes = survey.totalVotes // Utilisez l'extension pour obtenir le total des votes
            let votesText = "\(totalVotes) vote\(totalVotes > 1 ? "s" : "")" // Gère le pluriel
            
            // Créer le texte souligné pour les votes
            let votesAttrString = Utils.formatStringUnderline(textString: votesText, textColor: .black, font: ApplicationTheme.getFontChampInput().font)
            
            // Créer le texte final avec le " - " non souligné si commentsCount > 0
            let finalAttrString = NSMutableAttributedString()
            finalAttrString.append(votesAttrString)
            
            if let commentsCount = message.commentsCount, commentsCount > 0 {
                finalAttrString.append(NSAttributedString(string: " - ", attributes: [NSAttributedString.Key.font: ApplicationTheme.getFontChampInput().font, NSAttributedString.Key.foregroundColor: UIColor.black]))
            }
            
            // Assigner le texte au label
            ui_label_nb_votes.attributedText = finalAttrString
        } else {
            // Gérez le cas où `message.survey` est nul
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
        if let isMember = isMember, !isMember {
            if ui_view_btn_i_like != nil {
                ui_view_btn_i_like.isUserInteractionEnabled = true
                // Ajouter un geste pour avertir l'utilisateur
                let tapGestureForLike = UITapGestureRecognizer(target: self, action: #selector(ifNotMemberWarnUser))
                ui_view_btn_i_like.addGestureRecognizer(tapGestureForLike)
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ifNotMemberWarnUser))
                    ui_view_btn_i_like.addGestureRecognizer(longPressGesture)
            }
            // Configurer pour les non-membres
            ui_btn_signal_post.isUserInteractionEnabled = true
            let tapGestureForSignal = UITapGestureRecognizer(target: self, action: #selector(ifNotMemberWarnUser))
            ui_btn_signal_post.addGestureRecognizer(tapGestureForSignal)
        }else{
            if(ui_view_btn_i_like != nil){
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                    ui_view_btn_i_like.addGestureRecognizer(longPressGesture)
            }
            if ui_view_btn_i_like != nil {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLittleTap))
                ui_view_btn_i_like.addGestureRecognizer(tapGesture)
            }
            let tapGestureForSignal = UITapGestureRecognizer(target: self, action: #selector(signalClicked))
            ui_btn_signal_post.addGestureRecognizer(tapGestureForSignal)
            
        }
    }
    
    @objc func ifNotMemberWarnUser() {
        delegate?.ifNotMemberWarnUser()
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
    func onReactClickSeeMember(post:PostMessage)
    func ifNotMemberWarnUser()
    func postSurveyResponse(forPostId postId: Int, withResponses responses: [Bool])
    func sendVoteView(post:PostMessage)

}

extension NeighborhoodPostCell: ReactionsPopupViewDelegate {

    func reactForPost(reactionType: ReactionType) {
        if postMessage.reactionId != 0 {
            if postMessage.reactionId == reactionType.id {
                // L'utilisateur souhaite supprimer sa réaction précédente
                updateReaction(reactionType: reactionType, add: false)
                delegate?.deleteReaction(post: self.postMessage, reactionType: reactionType)
            } else {
                // Supprimer la réaction existante avant d'ajouter la nouvelle
                if let existingReactionType = getReactionTypeById(postMessage.reactionId ?? 0) {
                    updateReaction(reactionType: existingReactionType, add: false)
                    delegate?.deleteReaction(post: self.postMessage, reactionType: existingReactionType)
                }
                // Ajouter la nouvelle réaction
                updateReaction(reactionType: reactionType, add: true)
                delegate?.addReaction(post: self.postMessage, reactionType: reactionType)
            }
        } else {
            // Ajouter une nouvelle réaction
            updateReaction(reactionType: reactionType, add: true)
            delegate?.addReaction(post: self.postMessage, reactionType: reactionType)
        }
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
class NeighborhoodPostSurveyCell:NeighborhoodPostCell{
    
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
        self.layer.borderColor = UIColor.appGrisReaction.cgColor
        self.layer.borderWidth = 1
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        NotificationCenter.default.addObserver(self, selector: #selector(dismiss), name: Notification.Name("FermerReactionsPopup"), object: nil)


        for reaction in reactions {
            let imageView = UIImageView()
            if let imageUrl = URL(string: reaction.imageUrl ?? "") {
                imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_i_like"))
            }
            imageView.contentMode = .scaleAspectFill
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func dismiss() {
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




extension NeighborhoodPostCell: SurveyOptionViewDelegate {
    func didTapVote(surveyOptionView: SurveyOptionView, optionIndex: Int) {
        self.delegate?.sendVoteView(post: self.postMessage)
    }
    
    func didTapOption(_ surveyOptionView: SurveyOptionView, optionIndex: Int) {
        guard var localSurvey = postMessage.survey, // Utilisez `var` ici pour une copie locale modifiable
              localSurvey.choices.indices.contains(optionIndex) else { return }

        // Initialiser surveyResponse si c'est nil
        if postMessage.surveyResponse == nil {
            postMessage.surveyResponse = Array(repeating: false, count: localSurvey.choices.count)
        }

        // Ce guard est maintenant sûr grâce à l'initialisation ci-dessus
        guard var surveyResponse = postMessage.surveyResponse else { return }

        // Réinitialiser les votes si le sondage n'est pas à choix multiples
        if !localSurvey.multiple {
            surveyResponse.indices.forEach { surveyResponse[$0] = false }
            localSurvey.summary.indices.forEach { localSurvey.summary[$0] = 0 }
        }
        
        // Inverser la réponse actuelle et ajuster le compteur de votes
        surveyResponse[optionIndex].toggle()
        if surveyResponse[optionIndex] {
            localSurvey.summary[optionIndex] += 1
        } else {
            localSurvey.summary[optionIndex] = max(localSurvey.summary[optionIndex] - 1, 0)
        }
        
        // Sauvegarder les modifications
        postMessage.survey = localSurvey
        postMessage.surveyResponse = surveyResponse
        
        // Mettre à jour l'interface utilisateur pour refléter les changements
        let totalVotes = localSurvey.summary.reduce(0, +)
        ui_stackview_options.arrangedSubviews.enumerated().forEach { (index, view) in
            if let optionView = view as? SurveyOptionView {
                let votes = localSurvey.summary[index]
                let votePercentage = totalVotes > 0 ? Float(votes) / Float(totalVotes) : 0
                optionView.progressBar.progress = votePercentage
                optionView.answerCountLabel.text = "\(votes)"
                optionView.radioButton.isSelected = surveyResponse[index]
            }
        }

        // Appeler le délégué pour effectuer l'action de réseau avec les réponses mises à jour
        delegate?.postSurveyResponse(forPostId: postMessage.uid, withResponses: surveyResponse)
    }
}

