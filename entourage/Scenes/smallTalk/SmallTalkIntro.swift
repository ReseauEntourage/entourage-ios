//
//  SmallTalkIntro.swift
//  entourage
//
//  Created by Clement entourage on 13/05/2025.
//

import UIKit

class SmallTalkIntro: UIViewController {
    
    // OUTLETS
    @IBOutlet weak var ui_tv_title: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_main_label: UILabel!
    @IBOutlet weak var ui_btn_previous: UIButton!
    @IBOutlet weak var ui_btn_next: UIButton!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_main_label.setFontBody(size: 15)
        ui_tv_title?.setFontTitle(size: 20)

        configureWhiteButton(ui_btn_next, withTitle: "cancel".localized)
        configureOrangeButton(ui_btn_previous, withTitle: "onboarding_start_button".localized)

        applyStyledHTMLToLabel()

        ui_tv_title.text = "onboarding_title".localized
        ui_btn_previous.setTitle("onboarding_start_button".localized, for: .normal)
        ui_btn_next.setTitle("cancel".localized, for: .normal)

        ui_btn_previous.addTarget(self, action: #selector(onNextClick), for: .touchUpInside)
        ui_btn_next.addTarget(self, action: #selector(onCancelClick), for: .touchUpInside)
    }

    // MARK: - HTML Styling
    private func applyStyledHTMLToLabel() {
        guard let htmlString = NSLocalizedString("onboarding_intro_html", comment: "") as String? else {
            ui_main_label.text = "Erreur de chargement"
            return
        }

        let styledHTML = """
        <style>
            body {
                font-family: NunitoSans-Regular;
                font-size: 14px;
                color: #000000;
            }
            b {
                font-weight: bold;
            }
        </style>
        \(htmlString)
        """

        guard let data = styledHTML.data(using: .utf8) else {
            ui_main_label.text = "Erreur d’encodage"
            return
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            ui_main_label.attributedText = attributedString
        } else {
            ui_main_label.text = "Erreur d’affichage"
        }
    }

    // MARK: - Actions
    @objc private func onNextClick() {
        SmallTalkService.createUserSmallTalkRequest { [weak self] request, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("❌ Erreur création : \(error.message)")
                    let alert = UIAlertController(title: "Erreur", message: "La création de votre demande a échoué.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }

                guard let request = request else {
                    print("❌ Requête SmallTalk reçue nulle")
                    return
                }

                // Navigation vers SmallTalkViewController
                let storyboard = UIStoryboard(name: "SmallTalk", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "SmallTalkViewController") as? SmallTalkViewController else {
                    assertionFailure("⚠️ SmallTalkViewController non trouvé")
                    return
                }

                vc.configure(with: request)

                if let nav = self.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
    }


    @objc private func onCancelClick() {
        dismiss(animated: true)
    }

    // MARK: - Style Buttons
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
}
