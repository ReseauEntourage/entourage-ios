//
//  ImagePreviewController.swift
//  entourage
//
//  Created by Clement entourage on 02/10/2025.
//

import Foundation
import UIKit

final class ImagePreviewController: UIViewController, UIScrollViewDelegate {
    private let conversationId: Int
    private let chatMessageId: Int
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .whiteLarge) // iOS 12
    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let downloadButton = UIButton(type: .system)
    
    init(conversationId: Int, chatMessageId: Int) {
        self.conversationId = conversationId
        self.chatMessageId = chatMessageId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        spinner.hidesWhenStopped = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(spinner)
        
        setupTopBar()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        scrollView.addGestureRecognizer(tap) // Add to scrollView instead of view to prevent top bar intercepting
        
        loadLarge()
    }
    
    private func setupTopBar() {
        view.addSubview(topBar)
        topBar.addSubview(backButton)
        topBar.addSubview(downloadButton)

        topBar.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.translatesAutoresizingMaskIntoConstraints = false

        // Use a semi-transparent background to ensure buttons are visible over white/light images
        topBar.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        if let backImg = UIImage(named: "back_button_white") {
            backButton.setImage(backImg.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            backButton.setTitle("Retour", for: .normal)
            backButton.setTitleColor(.white, for: .normal)
        }

        if let downloadImg = UIImage(named: "ic_neighb_download") {
            downloadButton.setImage(downloadImg.withRenderingMode(.alwaysTemplate), for: .normal)
            downloadButton.tintColor = .white
        } else if #available(iOS 13.0, *) {
            downloadButton.setImage(UIImage(systemName: "arrow.down.to.line")?.withRenderingMode(.alwaysTemplate), for: .normal)
            downloadButton.tintColor = .white
        } else {
            downloadButton.setTitle("Download", for: .normal)
            downloadButton.setTitleColor(.white, for: .normal)
        }

        backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadImage), for: .touchUpInside)
        downloadButton.isHidden = true // Hidden until image loads

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            topBar.rightAnchor.constraint(equalTo: view.rightAnchor),

            backButton.leftAnchor.constraint(equalTo: topBar.leftAnchor, constant: 16),
            backButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),

            downloadButton.rightAnchor.constraint(equalTo: topBar.rightAnchor, constant: -16),
            downloadButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 30),
            downloadButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        // Dynamic top bar height based on safe area
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let topPadding = window?.safeAreaInsets.top ?? 44
        topBar.heightAnchor.constraint(equalToConstant: topPadding + 44).isActive = true
    }

    private func loadLarge() {
        spinner.startAnimating()
        MessagingService.getConversationImage(conversationId: conversationId, chatMessageId: chatMessageId) { [weak self] img, _ in
            guard let self = self else { return }
            guard let urlStr = img?.url else {
                self.spinner.stopAnimating()
                self.dismiss(animated: true)
                return
            }
            ImageCache.shared.load(urlStr) { image in
                self.spinner.stopAnimating()
                self.imageView.image = image
                self.downloadButton.isHidden = (image == nil)
            }
        }
    }
    
    @objc private func close() { dismiss(animated: true) }
    
    @objc private func downloadImage() {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let title = error == nil ? "photo téléchargée" : "Erreur"
        let message = error == nil ? "" : "Impossible de sauvegarder la photo."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
}
