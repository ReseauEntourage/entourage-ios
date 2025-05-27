//
//  SmallTalkNoBandFoundViewController.swift
//  entourage
//
//  Created by Clément on 21/05/2025.
//

import UIKit

final class SmallTalkNoBandFoundViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_event_card: UIView!
    @IBOutlet weak var ui_event_title: UILabel!
    @IBOutlet weak var ui_event_subtitle: UILabel!
    @IBOutlet weak var ui_event_button: UILabel!
    @IBOutlet weak var ui_button_wait: UIButton!

    // MARK: - Variables
    private var suggestedEventId: Int?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchSuggestedEvent()
    }

    // MARK: - UI Setup
    private func setupUI() {
        ui_title.setFontTitle(size: 20)
        ui_subtitle.setFontBody(size: 15)
        ui_title.text = "small_talk_no_band_title".localized
        ui_subtitle.text = "small_talk_no_band_subtitle".localized
        
        ui_event_title.setFontTitle(size: 15)
        ui_event_subtitle.setFontBody(size: 15)
        ui_event_button.setFontTitle(size: 15)

        ui_event_title.text = "small_talk_no_band_card_title".localized
        ui_event_subtitle.text = "small_talk_no_band_card_subtitle".localized
        ui_event_button.text = "small_talk_no_band_card_button".localized

        ui_event_card.isHidden = true
        ui_event_card.layer.cornerRadius = 12
        ui_event_card.layer.masksToBounds = true
        ui_event_card.backgroundColor = .white

        let tap = UITapGestureRecognizer(target: self, action: #selector(openSuggestedEvent))
        ui_event_card.addGestureRecognizer(tap)

        ui_button_wait.setTitle("small_talk_no_band_button_title".localized, for: .normal)
        ui_button_wait.addTarget(self, action: #selector(handleReturnToHome), for: .touchUpInside)
        configureOrangeButton(ui_button_wait, withTitle: "small_talk_no_band_button_title".localized)
    }

    // MARK: - API
    private func fetchSuggestedEvent() {
        EventService.getSuggestedSmallTalkEvent { [weak self] event in
            guard let self = self, let event = event else {
                DispatchQueue.main.async {
                    self?.ui_event_card.isHidden = true
                }
                return
            }
            self.suggestedEventId = event.uid
            DispatchQueue.main.async {
                self.ui_event_card.isHidden = false
            }
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


    // MARK: - Navigation
    @objc private func openSuggestedEvent() {
        guard let eventId = suggestedEventId else { return }

        let storyboard = UIStoryboard(name: StoryboardName.event, bundle: nil)
        guard let navVc = storyboard.instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController,
              let vc = navVc.topViewController as? EventDetailFeedViewController else {
            assertionFailure("❌ Impossible de charger le VC eventDetailNav")
            return
        }
        vc.eventId = eventId
        navVc.modalPresentationStyle = .fullScreen
        present(navVc, animated: true)
    }

    @objc private func handleReturnToHome() {
        AppState.navigateToMainApp()
    }
}
