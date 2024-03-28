//
//  SurveyView.swift
// Class to makes option choice in PostSurveyCell
//  entourage
//
//  Created by Clement entourage on 18/03/2024.
//

import Foundation
import UIKit

protocol SurveyOptionViewDelegate: AnyObject {
    func didTapOption(_ surveyOptionView: SurveyOptionView, optionIndex: Int)
    func didTapVote(surveyOptionView: SurveyOptionView, optionIndex: Int)
}

class SurveyOptionView: UIView {
    let radioButton = UIButton(type: .custom)
    let questionLabel = UILabel()
    let progressBar = UIProgressView(progressViewStyle: .default)
    let answerCountLabel = UILabel()
    var optionIndex: Int?
    var surveyResponse: Bool = false {
        didSet {
            radioButton.isSelected = surveyResponse
        }
    }

    weak var delegate: SurveyOptionViewDelegate?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Configuration du radioButton
        radioButton.setImage(UIImage(named: "ic_survey_unclicked"), for: .normal)
        radioButton.setImage(UIImage(named: "ic_survey_clicked"), for: .selected)
        radioButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)

        
        // Configuration du questionLabel
        questionLabel.font = UIFont.systemFont(ofSize: 13)
        questionLabel.textColor = .black
        
        // Configuration du progressBar
        progressBar.progressTintColor = .appOrange
        progressBar.trackTintColor = .appBeige
        
        // Configuration du answerCountLabel
        answerCountLabel.font = UIFont.systemFont(ofSize: 13)
        answerCountLabel.textColor = .black
        // Configuration du answerCountLabel pour détecter les taps
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(answerCountLabelTapped))
        answerCountLabel.isUserInteractionEnabled = true // Très important pour permettre les interactions
        answerCountLabel.addGestureRecognizer(tapGestureRecognizer)

        
        // Ajout des vues
        addSubview(radioButton)
        addSubview(questionLabel)
        addSubview(progressBar)
        addSubview(answerCountLabel)
        setupConstraints()
    }
    
    @objc private func radioButtonTapped() {
        radioButton.isSelected = !radioButton.isSelected
        delegate?.didTapOption(self, optionIndex: optionIndex!)

    }

    @objc private func answerCountLabelTapped() {
        guard let index = optionIndex else { return }
        delegate?.didTapVote(surveyOptionView: self, optionIndex: index)
    }

    private func setupConstraints() {
            radioButton.translatesAutoresizingMaskIntoConstraints = false
            questionLabel.translatesAutoresizingMaskIntoConstraints = false
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            answerCountLabel.translatesAutoresizingMaskIntoConstraints = false

            // Contraintes pour le radioButton
            NSLayoutConstraint.activate([
                radioButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                radioButton.topAnchor.constraint(equalTo: topAnchor),
                radioButton.widthAnchor.constraint(equalToConstant: 24), // Taille souhaitée pour le bouton
                radioButton.heightAnchor.constraint(equalTo: radioButton.widthAnchor)
            ])

            // Contraintes pour le questionLabel
            NSLayoutConstraint.activate([
                questionLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 8), // Espace entre le bouton et le texte
                questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                questionLabel.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor)
            ])

            // Contraintes pour le progressBar
            NSLayoutConstraint.activate([
                progressBar.topAnchor.constraint(equalTo: radioButton.bottomAnchor, constant: 8), // Espace en haut
                progressBar.leadingAnchor.constraint(equalTo: questionLabel.leadingAnchor),
                progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
                progressBar.heightAnchor.constraint(equalToConstant: 4) // Hauteur de la progressBar
            ])

            // Contraintes pour le answerCountLabel
            NSLayoutConstraint.activate([
                answerCountLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: -30), // Espace en haut
                answerCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                answerCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor) // Pour s'assurer que la vue s'étende jusqu'en bas
            ])
        }



}
