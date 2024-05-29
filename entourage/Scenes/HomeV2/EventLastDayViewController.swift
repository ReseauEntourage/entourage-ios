//
//  EventLastDayViewController.swift
//  entourage
//
//  Created by Clement entourage on 22/05/2024.
//

import Foundation
import UIKit

class EventLastDayViewController: UIViewController, MJAlertControllerDelegate {

    
    // OUTLETS
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiContent: UILabel!
    @IBOutlet weak var uiBtnICome: UIButton!
    @IBOutlet weak var uiBtnIDontCome: UIButton!
    @IBOutlet weak var uiBtnQuit: UIButton!
    
    // VARIABLES
    var event: Event? = nil
    var user:User? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEventDetails()
        uiBtnICome.addTarget(self, action: #selector(iComeButtonTapped), for: .touchUpInside)
        uiBtnIDontCome.addTarget(self, action: #selector(iDontComeButtonTapped), for: .touchUpInside)
        uiBtnQuit.addTarget(self, action: #selector(onQuit), for: .touchUpInside)
    }

    private func setupEventDetails() {
        guard let event = self.event else { return }
        
        let eventTitle = event.title
        var eventAddress = event.metadata?.place_name ?? ""
        if event.metadata?.place_name == "" {
            eventAddress = event.metadata?.street_address ?? ""
        }
        let eventTime = event.startTimeFormatted
        
        let titleText = "🔔 N’oubliez pas : « \(eventTitle) » a lieu demain au \(eventAddress) à \(eventTime) !"
        let contentText = "Pour faciliter l’organisation de l’événement, pouvez-vous nous dire si vous serez présent demain ?"
        
        uiTitle.text = titleText
        uiContent.text = contentText
        
//        if let imageUrl = event.getCurrentImageUrl, let url = URL(string: imageUrl) {
//            loadImage(from: url)
//        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image.image = image
                }
            }
        }
    }
    
    func showMessage(title:String, content:String) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        alertVC.delegate = self
        
        alertVC.configureAlert(alertTitle: title, message: content, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
    
    @objc func onQuit(){
        self.dismiss(animated: true) {
            
        }
    }
    
    func validateLeftButton(alertTag: MJAlertTAG) {
        //NOTHING
    }
    
    func validateRightButton(alertTag: MJAlertTAG) {
        self.dismiss(animated: true)
        // Ajoutez ici ce que vous souhaitez faire lorsque le bouton OK est pressé
    }

    @objc func iComeButtonTapped() {
        EventService.confirmParticipation(eventId: self.event?.uid ?? 0) { success, error in
            if success {
                self.showMessage(title: "Merci !", content: "Merci d'avoir répondu, à bientôt !")
            } else {
                self.showMessage(title: "Attention !", content: "Une erreur s'est produite")
                // Handle failure
            }
        }
    }

    @objc func iDontComeButtonTapped() {
        EventService.leaveEvent(eventId: self.event?.uid ?? 0, userId:self.user?.sid ?? 0) { event, error in
            if error == nil {
                self.showMessage(title: "Merci !", content: "Merci d'avoir répondu, à bientôt !")

            }else{
                self.showMessage(title: "Attention !", content: "Une erreur s'est produite")
            }
        }
    }
}
