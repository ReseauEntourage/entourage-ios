//
//  ActionFormViews.swift
//  entourage
//
//  Ecrans SwiftUI des étapes du parcours de création / modification d'une entraide et de l'aperçu
//  (change flux-creation-unifie). Remplacent les `Phase` UIKit et leurs cellules : mêmes champs,
//  habillage de l'événement (titre par écran, mention « obligatoire », erreur sous le champ).
//

import SwiftUI
import UIKit

/// Texte « contribution » / « demande » injecté dans les libellés.
func actionTypeName(isContrib: Bool) -> String {
    return (isContrib ? "action_contrib" : "action_solicitation").localized
}

/// En-tête d'une étape : « Étape N sur X » (position et total dérivés de la liste d'étapes du store).
private func actionStepHeader(_ step: ActionCreateStep, store: ActionFormStore, title: String) -> FormFlowStepHeader {
    let steps = store.steps
    let position = (steps.firstIndex(of: step) ?? 0) + 1
    return FormFlowStepHeader(
        eyebrow: String(format: "event_form_step_label".localized, position, steps.count),
        title: title
    )
}

// MARK: - Catégorie -

struct ActionStepCategoryView: View {
    @ObservedObject var store: ActionFormStore
    let isContrib: Bool
    let sections: [(key: String, subtitle: String, imageName: String)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                actionStepHeader(.category, store: store, title: String(format: ActionCreateStep.category.titleKey.localized, actionTypeName(isContrib: isContrib)))

                FormFlowLabel(title: "action_form_category_label".localized, isRequired: true)
                    .padding(.bottom, 6)

                VStack(spacing: 10) {
                    ForEach(sections, id: \.key) { section in
                        FormFlowSelectableCard(
                            symbolNames: ["square.grid.2x2"],
                            assetImageName: section.imageName,
                            title: TagsUtils.showTagTranslated(section.key),
                            subtitle: TagsUtils.showSubTagTranslated(section.key),
                            isOn: store.values.sectionKey == section.key,
                            action: { store.selectSection(section.key) }
                        )
                    }
                }
                .formFlowError(store.errors[.category])
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
    }
}

// MARK: - Titre, description, image -

struct ActionStepDetailsView: View {
    @ObservedObject var store: ActionFormStore
    let isContrib: Bool
    let onPickImage: () -> Void

    private var placeholders: (title: String, description: String) {
        let section = store.values.sectionKey ?? ""
        let known = ["social", "services", "clothes", "equipment", "hygiene"]
        guard known.contains(section) else { return ("", "") }
        let prefix = (isContrib ? "contrib_" : "demand_") + section
        return ((prefix + "_title").localized, (prefix + "_description").localized)
    }

    var body: some View {
        let type = actionTypeName(isContrib: isContrib)
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                actionStepHeader(.details, store: store, title: String(format: ActionCreateStep.details.titleKey.localized, type))

                // Titre
                VStack(alignment: .leading, spacing: 0) {
                    FormFlowLabel(title: "action_form_title_label".localized, isRequired: true)
                    FormFlowHint(text: String(format: "action_create_phase_1_name_subtitle".localized, type))
                    FormFlowTextField(
                        placeholder: placeholders.title.isEmpty ? String(format: "action_create_phase_1_name_placeholder".localized, type) : placeholders.title,
                        text: store.binding(\.title),
                        hasError: store.errors[.title] != nil
                    )
                    .formFlowError(store.errors[.title])
                }
                .padding(.bottom, 20)

                // Description
                VStack(alignment: .leading, spacing: 0) {
                    FormFlowLabel(title: "action_form_description_label".localized, isRequired: true)
                    FormFlowHint(text: String(format: "action_create_phase_1_desc_subtitle".localized, type))
                    FormFlowTextArea(
                        placeholder: placeholders.description.isEmpty ? String(format: "action_create_phase_1_desc_placeholder".localized, type) : placeholders.description,
                        text: store.binding(\.descriptionText),
                        maxLength: ApplicationTheme.maxCharsDescription,
                        hasError: store.errors[.description] != nil
                    )
                    .formFlowError(store.errors[.description])
                }
                .padding(.bottom, 20)

                // Image (contribution seulement, facultative)
                if isContrib {
                    VStack(alignment: .leading, spacing: 0) {
                        FormFlowLabel(title: "action_form_image_label".localized)
                        FormFlowPhotoPickerTile(
                            localImage: store.localImage,
                            remoteUrl: store.values.imageUrl,
                            hasPhoto: store.values.hasImage,
                            hasError: false,
                            addTitle: "action_add_post_title_image".localized,
                            changeTitle: "event_form_photo_change".localized,
                            addedCaption: "event_form_photo_added".localized,
                            action: onPickImage
                        )
                    }
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

// MARK: - Lieu -

struct ActionStepLocationView: View {
    @ObservedObject var store: ActionFormStore
    let isContrib: Bool
    let onPickPlace: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                actionStepHeader(.location, store: store, title: String(format: ActionCreateStep.location.titleKey.localized, actionTypeName(isContrib: isContrib)))

                FormFlowLabel(title: "action_form_place_label".localized, isRequired: true)
                FormFlowHint(text: "actionCellLocationDescription".localized)
                FormFlowPlaceField(
                    placeholder: "neighborhoodCreatePlaceInfos".localized,
                    text: store.values.placeName,
                    hasError: store.errors[.address] != nil,
                    action: onPickPlace
                )
                .formFlowError(store.errors[.address])
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
    }
}

// MARK: - Partage dans un groupe (conditionnel) -

struct ActionStepShareView: View {
    @ObservedObject var store: ActionFormStore
    let isContrib: Bool

    var body: some View {
        let type = actionTypeName(isContrib: isContrib)
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                actionStepHeader(.share, store: store, title: String(format: ActionCreateStep.share.titleKey.localized, type, store.defaultGroupName))

                FormFlowHint(text: String(format: "share_request_description".localized, type))

                VStack(spacing: 0) {
                    FormFlowRadioRow(title: "yes".localized, isOn: store.values.shareToGroup == true, showsSeparator: true) {
                        store.update { $0.shareToGroup = true }
                    }
                    FormFlowRadioRow(title: "no".localized, isOn: store.values.shareToGroup == false, showsSeparator: false) {
                        store.update { $0.shareToGroup = false }
                    }
                }
                .formFlowError(store.errors[.share])
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
    }
}

// MARK: - Aperçu -

struct ActionPreviewView: View {
    @ObservedObject var store: ActionFormStore
    let isContrib: Bool

    private var values: ActionFormValues { store.values }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                FormFlowStepHeader(eyebrow: "event_form_preview_eyebrow".localized,
                                   title: String(format: "action_form_preview_title".localized, actionTypeName(isContrib: isContrib)),
                                   isSmall: true)

                if isContrib && values.hasImage {
                    FormFlowPreviewPhoto(localImage: store.localImage, remoteUrl: values.imageUrl)
                        .padding(.bottom, 14)
                }

                Text(values.title)
                    .font(FormFlowStyle.title(18))
                    .foregroundColor(FormFlowStyle.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)

                if let section = values.sectionKey {
                    FormFlowLayout(items: [section], spacing: 7) { key in
                        FormFlowPreviewChip(title: TagsUtils.showTagTranslated(key))
                    }
                    .padding(.bottom, 10)
                }

                if !values.placeName.isEmpty {
                    FormFlowMetaRow(systemImage: "mappin.and.ellipse", text: values.placeName)
                }

                if !values.descriptionText.isEmpty {
                    Text(values.descriptionText)
                        .font(FormFlowStyle.regular(14))
                        .foregroundColor(FormFlowStyle.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
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
