//
//  UILabel+Animation.swift
//  entourage
//
//  Created by clément perrousset on 28/01/2026.
//

import Foundation
import UIKit

extension UILabel {
    
    private struct AssociatedKeys {
        static var animationStartTime = "animationStartTime"
        static var animationDuration = "animationDuration"
        static var animationStartValue = "animationStartValue"
        static var animationEndValue = "animationEndValue"
        static var animationPrefix = "animationPrefix"
        static var displayLink = "displayLink"
    }
    
    // MARK: - Public API
    
    /// Anime le texte du label d'un nombre A vers un nombre B
    /// - Parameters:
    ///   - value: La valeur cible (Int)
    ///   - prefix: Le texte à mettre devant le chiffre (ex: "Événements : ")
    ///   - duration: La durée de l'animation en secondes (par défaut 1.5s)
    func animateCount(to endValue: Int, prefix: String = "", duration: Double = 1.5) {
        // Arrêter toute animation en cours
        stopAnimation()
        
        let startValue = 0 // Tu peux changer ceci pour parser le texte actuel si tu veux partir de la valeur courante
        
        // Stocker les valeurs nécessaires via Associated Objects
        objc_setAssociatedObject(self, &AssociatedKeys.animationStartTime, Date.timeIntervalSinceReferenceDate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.animationDuration, duration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.animationStartValue, startValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.animationEndValue, endValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.animationPrefix, prefix, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Créer le DisplayLink (rafraichissement écran)
        let displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink.add(to: .main, forMode: .common)
        
        objc_setAssociatedObject(self, &AssociatedKeys.displayLink, displayLink, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // MARK: - Private Logic
    
    @objc private func handleUpdate(_ displayLink: CADisplayLink) {
        guard let startTime = objc_getAssociatedObject(self, &AssociatedKeys.animationStartTime) as? Double,
              let duration = objc_getAssociatedObject(self, &AssociatedKeys.animationDuration) as? Double,
              let startValue = objc_getAssociatedObject(self, &AssociatedKeys.animationStartValue) as? Int,
              let endValue = objc_getAssociatedObject(self, &AssociatedKeys.animationEndValue) as? Int,
              let prefix = objc_getAssociatedObject(self, &AssociatedKeys.animationPrefix) as? String else {
            stopAnimation()
            return
        }
        
        let now = Date.timeIntervalSinceReferenceDate
        let elapsedTime = now - startTime
        
        // Si l'animation est finie
        if elapsedTime >= duration {
            self.text = "\(prefix)\(endValue)"
            stopAnimation()
        } else {
            // Calcul de la progression (0.0 à 1.0)
            let percentage = elapsedTime / duration
            
            // Application d'une courbe EaseOut (Cubic) pour que ça ralentisse à la fin
            // Formule: 1 - (1 - t)^3
            let easeOut = 1.0 - pow(1.0 - percentage, 3.0)
            
            // Calcul de la valeur courante
            let currentValue = Double(startValue) + (Double(endValue - startValue) * easeOut)
            
            self.text = "\(prefix)\(Int(currentValue))"
        }
    }
    
    private func stopAnimation() {
        if let displayLink = objc_getAssociatedObject(self, &AssociatedKeys.displayLink) as? CADisplayLink {
            displayLink.invalidate()
            objc_setAssociatedObject(self, &AssociatedKeys.displayLink, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
