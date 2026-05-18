import Foundation
import UIKit
import SwiftUI

final class ImagePreviewController: UIHostingController<ImagePreviewWrapper> {
    init(conversationId: Int, chatMessageId: Int) {
        let wrapper = ImagePreviewWrapper(conversationId: conversationId, chatMessageId: chatMessageId)
        super.init(rootView: wrapper)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        self.view.backgroundColor = .clear

        // Pass dismiss block down
        self.rootView.dismissAction = { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ImagePreviewViewModel: ObservableObject {
    @Published var image: UIImage? = nil

    func loadLarge(conversationId: Int, chatMessageId: Int) {
        MessagingService.getConversationImage(conversationId: conversationId, chatMessageId: chatMessageId) { [weak self] img, _ in
            guard let self = self else { return }
            guard let urlStr = img?.url else { return }

            ImageCache.shared.load(urlStr) { fetchedImage in
                DispatchQueue.main.async {
                    self.image = fetchedImage
                }
            }
        }
    }
}

struct ImagePreviewWrapper: View {
    let conversationId: Int
    let chatMessageId: Int
    var dismissAction: (() -> Void)? = nil

    @StateObject private var viewModel = ImagePreviewViewModel()

    var body: some View {
        FullScreenImageView(image: viewModel.image, dismissAction: {
            dismissAction?()
        })
        .onAppear {
            viewModel.loadLarge(conversationId: conversationId, chatMessageId: chatMessageId)
        }
    }
}
