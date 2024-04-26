//
//  SimpleMJAlertDialog.swift
//  entourage
//
//  Created by Clement entourage on 27/03/2024.
//

import Foundation
import UIKit

protocol SimpleAlertClick {
    func onClickMainButton()
}

class SimpleAlertDialog: UIViewController {

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appOrangeLight // Assure-toi que cette couleur est bien définie quelque part.
        label.font = ApplicationTheme.getFontNunitoRegular(size: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = ApplicationTheme.getFontNunitoRegular(size: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.appOrangeLight // Assure-toi que cette couleur est bien définie quelque part.
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Ajouter ma localité", for: .normal)
        button.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange(size: 15, color: .white))
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var alertTitle: String?
    var alertMessage: String?
    var delegate: SimpleAlertClick? = nil
    
    init(title: String?, message: String?, btnTitle: String?) {
        self.alertTitle = title
        self.alertMessage = message
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.actionButton.setTitle(btnTitle, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layoutViews()
    }

    private func layoutViews() {
        view.addSubview(backgroundView)

        // Modifiez ici pour que backgroundView prenne toute la largeur de la vue parent moins 20 pixels de chaque côté
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(messageLabel)
        backgroundView.addSubview(actionButton)
        
        titleLabel.text = alertTitle
        messageLabel.text = alertMessage
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            actionButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -20),
            actionButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }


    @objc private func didTapActionButton() {
        dismiss(animated: true, completion: {
            self.delegate?.onClickMainButton()
        })
    }
}

