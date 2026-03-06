//
//  AssociationPresenter.swift
//  entourage
//

import Foundation
import UIKit

protocol AssociationPresenterDelegate: AnyObject {
    func didLoadPartner(_ partner: Partner)
    func didUpdatePartnerSuccess()
    func didFailWithError(_ error: String)
}

class AssociationPresenter {
    
    weak var delegate: AssociationPresenterDelegate?
    var currentPartner: Partner?
    
    // Pour charger les infos initiales
    func getPartnerDetails(partnerId: Int) {
        AssociationService.getPartnerDetail(id: partnerId) { [weak self] partner, error in
            if let p = partner {
                self?.currentPartner = p
                self?.delegate?.didLoadPartner(p)
            } else if let error = error {
                self?.delegate?.didFailWithError(error.message)
            }
        }
    }
    
    // Logique principale de sauvegarde (Image + Texte)
    func updateUserPartner(partnerId: Int,
                           newDescription: String?,
                           newImage: UIImage?) {
        
        // 1. Si on a une image, on commence par le flow d'upload
        if let image = newImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            
            AssociationService.getPresignedUploadUrl(contentType: "image/jpeg") { [weak self] uploadKey, presignedUrl, error in
                // CORRECTION : On s'assure de bien récupérer le uploadKey ici
                guard let self = self, let url = presignedUrl, let key = uploadKey else {
                    self?.delegate?.didFailWithError("Erreur lors de la préparation de l'upload")
                    return
                }
            
                // 2. Upload vers S3
                AssociationService.uploadImageToPresignedUrl(urlStr: url, data: imageData) { success in
                    if success {
                        // 3. Update API
                        // CORRECTION : On envoie le uploadKey (et non l'URL) pour mettre à jour le logo
                        self.sendUpdateToApi(partnerId: partnerId, description: newDescription, logoKey: key)
                    } else {
                        self.delegate?.didFailWithError("Erreur lors de l'upload de l'image")
                    }
                }
            }
        } else {
            // Pas d'image à changer, update simple
            sendUpdateToApi(partnerId: partnerId, description: newDescription, logoKey: nil)
        }
    }
    
    // CORRECTION: Changement du paramètre 'imageUrl' en 'logoKey' pour correspondre à la logique "upload_key"
    private func sendUpdateToApi(partnerId: Int, description: String?, logoKey: String?) {
        var data = [String: Any]()
        
        if let desc = description {
            data["description"] = desc
        }
        
        if let key = logoKey {
            // CORRECTION: Utilisation de "logo_key" avec la clé S3 (et non "image_url")
            data["image_url"] = key
        }
        
        // Si rien n'a changé, on signale le succès directement
        if data.isEmpty {
            self.delegate?.didUpdatePartnerSuccess()
            return
        }
        
        AssociationService.updatePartner(partnerId: partnerId, data: data) { [weak self] success, error in
            if success {
                self?.delegate?.didUpdatePartnerSuccess()
            } else {
                self?.delegate?.didFailWithError("Erreur lors de la mise à jour")
            }
        }
    }
}
