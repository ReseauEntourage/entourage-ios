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
        view.addGestureRecognizer(tap)
        
        loadLarge()
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
            }
        }
    }
    
    @objc private func close() { dismiss(animated: true) }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
}
