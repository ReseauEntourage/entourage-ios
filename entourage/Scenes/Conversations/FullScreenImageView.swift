import SwiftUI
import UIKit

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = .clear
        scrollView.addSubview(hostedView)

        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>

        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let view = hostingController.view else { return }
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            view.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                  y: scrollView.contentSize.height * 0.5 + offsetY)
        }

        @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard let scrollView = recognizer.view as? UIScrollView else { return }

            if scrollView.zoomScale > scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                let zoomPoint = recognizer.location(in: hostingController.view)
                let zoomSize = CGSize(width: scrollView.bounds.size.width / scrollView.maximumZoomScale,
                                      height: scrollView.bounds.size.height / scrollView.maximumZoomScale)
                let zoomRect = CGRect(x: zoomPoint.x - zoomSize.width / 2.0,
                                      y: zoomPoint.y - zoomSize.height / 2.0,
                                      width: zoomSize.width,
                                      height: zoomSize.height)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
    }
}

struct FullScreenImageView: View {
    let image: UIImage?
    var imageURL: String? = nil
    let dismissAction: () -> Void

    @State private var showDownloadAlert = false
    @State private var downloadMessage = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let img = image {
                ZoomableScrollView {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                }
                .ignoresSafeArea()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }

            VStack {
                HStack {
                    Button(action: {
                        dismissAction()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 35, height: 35)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }

                    Spacer()

                    if let _ = image {
                        Button(action: {
                            saveImage()
                        }) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 35, height: 35)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
            }
        }
        .alert(isPresented: $showDownloadAlert) {
            Alert(title: Text("Information"), message: Text(downloadMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func saveImage() {
        guard let img = image else { return }
        let saver = ImageSaver()
        saver.successHandler = {
            self.downloadMessage = "Image enregistrée dans la pellicule avec succès."
            self.showDownloadAlert = true
        }
        saver.errorHandler = { error in
            self.downloadMessage = "Erreur lors de l'enregistrement de l'image."
            self.showDownloadAlert = true
        }
        saver.writeToPhotoAlbum(image: img)
    }
}

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
