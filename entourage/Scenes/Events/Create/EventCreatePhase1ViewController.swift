//
//  EventCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//
//  Étape 1 « Présentez votre événement » : nom, description, photo.
//

import UIKit
import SwiftUI

class EventCreatePhase1ViewController: UIViewController {

    weak var pageDelegate: EventCreateMainDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let store = pageDelegate?.formStore else { return }

        embedSwiftUI(EventStepPresentationView(store: store, onPickPhoto: { [weak self] in
            guard let self = self else { return }
            self.pageDelegate?.showChooseImage(delegate: self)
        }))
    }
}

//MARK: - Delegates -
extension EventCreatePhase1ViewController: ChoosePictureEventDelegate {
    func selectedPicture(image: EventImage) {
        pageDelegate?.formStore.setGalleryImage(image)
    }
}

// MARK: - Vue SwiftUI -

struct EventStepPresentationView: View {
    @ObservedObject var store: EventFormStore
    let onPickPhoto: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                EventStepHeader(step: .presentation)

                // Nom
                VStack(alignment: .leading, spacing: 0) {
                    EventFormLabel(title: "event_form_name_label".localized, isRequired: true)
                    EventFormTextField(
                        placeholder: "event_form_name_placeholder".localized,
                        text: store.binding(\.title),
                        hasError: store.errors[.title] != nil
                    )
                    .eventFormError(store.errors[.title])
                }
                .padding(.bottom, 20)

                // Description
                VStack(alignment: .leading, spacing: 0) {
                    EventFormLabel(title: "event_form_description_label".localized, isRequired: true)
                    EventFormHint(text: "event_form_description_hint".localized)
                    EventFormTextArea(
                        placeholder: "event_form_description_placeholder".localized,
                        text: store.binding(\.descriptionText),
                        maxLength: ApplicationTheme.maxCharsDescription,
                        hasError: store.errors[.description] != nil
                    )
                    .eventFormError(store.errors[.description])
                }
                .padding(.bottom, 20)

                // Photo
                VStack(alignment: .leading, spacing: 0) {
                    EventFormLabel(title: "event_form_photo_label".localized, isRequired: true)
                    photoTile
                        .eventFormError(store.errors[.photo])
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.onTapGesture { EventFormStyle.hideKeyboard() })
        }
        .background(Color.white)
    }

    @ViewBuilder
    private var photoTile: some View {
        let photo = EventPhotoImage(localImage: store.localPhoto, remoteUrl: store.values.imageDisplayUrl)
        let hasError = store.errors[.photo] != nil

        Button(action: onPickPhoto) {
            if store.values.hasPhoto && photo.hasImage {
                ZStack(alignment: .bottomTrailing) {
                    photo
                        .frame(maxWidth: .infinity)
                        .frame(height: 190)
                        .clipped()
                    Text("event_form_photo_change".localized)
                        .font(EventFormStyle.semibold(12.5))
                        .foregroundColor(EventFormStyle.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(10)
                }
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(EventFormStyle.line, lineWidth: 1))
            }
            else {
                VStack(spacing: 7) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13).fill(EventFormStyle.accentSoft)
                        Image(systemName: store.values.hasPhoto ? "checkmark" : "photo")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(EventFormStyle.accent)
                    }
                    .frame(width: 46, height: 46)

                    Text((store.values.hasPhoto ? "event_form_photo_change" : "event_form_photo_add").localized)
                        .font(EventFormStyle.bold(13.5))
                        .foregroundColor(EventFormStyle.ink)
                        .underline()
                    Text((store.values.hasPhoto ? "event_form_photo_added" : "event_form_photo_hint").localized)
                        .font(EventFormStyle.regular(12))
                        .foregroundColor(EventFormStyle.ink2)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(hasError ? EventFormStyle.errorBorder : EventFormStyle.line,
                                style: StrokeStyle(lineWidth: hasError ? 1.5 : 1, dash: hasError ? [] : [5, 4]))
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
