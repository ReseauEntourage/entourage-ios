//
//  GroupFormViews.swift
//  entourage
//
//  Ecrans SwiftUI des étapes du parcours de création / modification d'un groupe et de l'aperçu
//  (change flux-creation-unifie). Remplacent les `Phase` UIKit et leurs cellules : mêmes champs,
//  habillage de l'événement (titre par écran, mention « obligatoire », erreur sous le champ).
//

import SwiftUI
import UIKit

// MARK: - Étape 1 : nom, description, lieu -

struct GroupStepDetailsView: View {
    @ObservedObject var store: GroupFormStore
    let onPickPlace: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                FormFlowStepHeader(position: GroupCreateStep.details.position, count: GroupCreateStep.count, titleKey: GroupCreateStep.details.titleKey)

                // Nom
                VStack(alignment: .leading, spacing: 0) {
                    FormFlowLabel(title: "group_form_name_label".localized, isRequired: true)
                    FormFlowTextField(
                        placeholder: "neighborhoodCreateNamePlaceholderName".localized,
                        text: store.binding(\.name),
                        hasError: store.errors[.name] != nil,
                        identifier: "group_form_name"
                    )
                    .formFlowError(store.errors[.name])
                }
                .padding(.bottom, 20)

                // Description
                VStack(alignment: .leading, spacing: 0) {
                    FormFlowLabel(title: "group_form_description_label".localized, isRequired: true)
                    FormFlowTextArea(
                        placeholder: "neighborhoodCreateTitleDescriptionPlaceholder".localized,
                        text: store.binding(\.descriptionText),
                        maxLength: ApplicationTheme.maxCharsDescription,
                        hasError: store.errors[.description] != nil,
                        identifier: "group_form_description"
                    )
                    .formFlowError(store.errors[.description])
                }
                .padding(.bottom, 20)

                // Lieu
                VStack(alignment: .leading, spacing: 0) {
                    FormFlowLabel(title: "group_form_place_label".localized, isRequired: true)
                    FormFlowHint(text: "neighborhoodCreatePlaceDescription".localized)
                    FormFlowPlaceField(
                        placeholder: "neighborhoodCreatePlaceInfos".localized,
                        text: store.values.addressName,
                        hasError: store.errors[.address] != nil,
                        identifier: "group_form_place",
                        action: onPickPlace
                    )
                    .formFlowError(store.errors[.address])
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.onTapGesture { FormFlowStyle.hideKeyboard() })
        }
        .background(Color.white)
    }
}

// MARK: - Étape 2 : centres d'intérêt -

struct GroupStepInterestsView: View {
    @ObservedObject var store: GroupFormStore
    let tags: [(key: String, name: String)]

    private func name(for key: String) -> String {
        return TagsUtils.showTagTranslated(tags.first { $0.key == key }?.name ?? key)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                FormFlowStepHeader(position: GroupCreateStep.interests.position, count: GroupCreateStep.count, titleKey: GroupCreateStep.interests.titleKey)

                FormFlowLabel(title: "group_form_interests_label".localized, isRequired: true)
                    .padding(.bottom, 6)

                FormFlowLayout(items: tags.map { $0.key }) { key in
                    FormFlowChip(title: name(for: key), isOn: store.values.interests.contains(key), identifier: "group_form_interest_\(key)") {
                        store.toggleInterest(key)
                    }
                }
                .formFlowError(store.errors[.categories])

                // Catégorie « Autre » : précision obligatoire (même règle qu'avant la refonte).
                if store.values.isOtherInterestSelected {
                    VStack(alignment: .leading, spacing: 0) {
                        FormFlowLabel(title: "neighborhoodCreateCatOtherTitle".localized, isRequired: true)
                        FormFlowTextField(
                            placeholder: "neighborhoodCreateCatOtherPlaceholder".localized,
                            text: store.binding(\.otherInterestMessage),
                            hasError: store.errors[.otherInterest] != nil
                        )
                        .formFlowError(store.errors[.otherInterest])
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.onTapGesture { FormFlowStyle.hideKeyboard() })
        }
        .background(Color.white)
    }
}

// MARK: - Étape 3 : photo, message de bienvenue -

struct GroupStepPhotoView: View {
    @ObservedObject var store: GroupFormStore
    let onPickPhoto: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                FormFlowStepHeader(position: GroupCreateStep.photo.position, count: GroupCreateStep.count, titleKey: GroupCreateStep.photo.titleKey)

                // Photo
                VStack(alignment: .leading, spacing: 0) {
                    FormFlowLabel(title: "group_form_photo_label".localized, isRequired: true)
                    FormFlowPhotoPickerTile(
                        localImage: nil,
                        remoteUrl: store.values.imageUrl,
                        hasPhoto: store.values.hasPhoto,
                        hasError: store.errors[.photo] != nil,
                        addTitle: "event_form_photo_add".localized,
                        changeTitle: "event_form_photo_change".localized,
                        addedCaption: "event_form_photo_added".localized,
                        identifier: "group_form_photo",
                        action: onPickPhoto
                    )
                    .formFlowError(store.errors[.photo])
                }
                .padding(.bottom, 20)

                // Message de bienvenue (facultatif)
                VStack(alignment: .leading, spacing: 0) {
                    FormFlowLabel(title: "group_form_welcome_label".localized)
                    FormFlowHint(text: "group_form_welcome_hint".localized)
                    FormFlowTextArea(
                        placeholder: "addPhotoCreateDescriptionPlaceholder".localized,
                        text: store.binding(\.welcomeMessage),
                        maxLength: ApplicationTheme.maxCharsDescription200
                    )
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.onTapGesture { FormFlowStyle.hideKeyboard() })
        }
        .background(Color.white)
    }
}

// MARK: - Aperçu -

struct GroupPreviewView: View {
    @ObservedObject var store: GroupFormStore

    private var values: GroupFormValues { store.values }

    private func interestName(_ key: String) -> String {
        let tags = Metadatas.sharedInstance.tagsInterest?.getTags() ?? []
        return TagsUtils.showTagTranslated(tags.first { $0.key == key }?.name ?? key)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                FormFlowStepHeader(eyebrow: "event_form_preview_eyebrow".localized, title: "group_form_preview_title".localized, isSmall: true)

                FormFlowPreviewPhoto(localImage: nil, remoteUrl: values.imageUrl)
                    .padding(.bottom, 14)

                Text(values.name)
                    .font(FormFlowStyle.title(18))
                    .foregroundColor(FormFlowStyle.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)

                if !values.addressName.isEmpty {
                    FormFlowMetaRow(systemImage: "mappin.and.ellipse", text: values.addressName)
                }

                if !values.interests.isEmpty {
                    FormFlowLayout(items: values.interests, spacing: 7) { key in
                        FormFlowPreviewChip(title: interestName(key))
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                }

                if !values.descriptionText.isEmpty {
                    Text(values.descriptionText)
                        .font(FormFlowStyle.regular(14))
                        .foregroundColor(FormFlowStyle.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 18)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
    }
}
