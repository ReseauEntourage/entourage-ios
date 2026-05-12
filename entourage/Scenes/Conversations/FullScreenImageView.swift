import SwiftUI
import UIKit

struct FullScreenImageView: View {
    let image: UIImage
    let dismissAction: () -> Void

    @State private var showDownloadAlert = false
    @State private var downloadMessage = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()

            VStack {
                HStack {
                    Button(action: {
                        dismissAction()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: {
                        saveImage()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
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
        let saver = ImageSaver()
        saver.successHandler = {
            self.downloadMessage = "Image enregistrée dans la pellicule avec succès."
            self.showDownloadAlert = true
        }
        saver.errorHandler = { error in
            self.downloadMessage = "Erreur lors de l'enregistrement de l'image."
            self.showDownloadAlert = true
        }
        saver.writeToPhotoAlbum(image: image)
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
