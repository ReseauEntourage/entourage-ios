//
//  ImageGridCell.swift
//  entourage
//
//  Created by Clement entourage on 02/10/2025.
//
import Foundation
import UIKit

final class ImageGridCell: UICollectionViewCell {
    static let reuseId = "ImageGridCell"
    
    let imageView = UIImageView()
    let spinner = UIActivityIndicatorView(style: .gray) // iOS 12 OK
    
    /// Token pour s’assurer que l’image reçue correspond encore à cette cellule
    private var loadToken: UUID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .lightGray
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        spinner.hidesWhenStopped = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(spinner)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Invalide l'ancien chargement
        loadToken = nil
        // Reset visuel
        imageView.image = nil
        spinner.stopAnimating()
    }
    
    /// Configure la cellule pour une URL d’image.
    /// Arrête **toujours** le spinner, même si l’image ne correspond finalement plus à la cellule.
    func configure(urlString: String?) {
        // Reset
        imageView.image = nil
        spinner.startAnimating()
        
        guard let urlString = urlString, !urlString.isEmpty else {
            spinner.stopAnimating()
            return
        }
        
        let token = UUID()
        loadToken = token
        
        ImageCache.shared.load(urlString) { [weak self] image in
            guard let self = self else { return }
            defer { self.spinner.stopAnimating() } // on s’assure d’arrêter le spinner dans tous les cas
            
            // Si la cellule a été réutilisée entre temps, on ignore le résultat
            guard self.loadToken == token else { return }
            
            self.imageView.image = image
        }
    }
}
