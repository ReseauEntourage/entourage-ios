//
//  EventPreviewViewController.swift
//  entourage
//
//  Aperçu de l'événement avant publication (création : « Publier », modification : « Modifier »).
//  Écran partagé par les deux parcours, alimenté par `EventFormStore`. L'action finale est
//  portée par le bouton du pied de page du conteneur.
//
//  Les pastilles « fauteuil » et « famille » y apparaissent quand l'organisateur les a cochées,
//  même si elles ne sont pas encore envoyées au backend (EN-9582).
//

import UIKit
import SwiftUI

class EventPreviewViewController: UIViewController {

    private let store: EventFormStore

    init(store: EventFormStore, delegate: EventCreateMainDelegate?) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        embedSwiftUI(EventPreviewView(store: store))
    }
}

// MARK: - Vue SwiftUI -

struct EventPreviewChip: Hashable {
    let id: String
    let title: String
    var symbolNames: [String]? = nil
}

struct EventPreviewView: View {
    @ObservedObject var store: EventFormStore

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.getPreferredLocale()
        formatter.dateFormat = "EEE d MMM"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.getPreferredLocale()
        formatter.dateFormat = "HH'h'mm"
        return formatter
    }()

    private var values: EventFormValues { store.values }

    private var dateText: String? {
        guard let start = values.startDate else { return nil }
        let day = Self.dayFormatter.string(from: start).capitalized
        if let end = values.endDate {
            return String(format: "event_form_preview_time_range".localized, day, Self.timeFormatter.string(from: start), Self.timeFormatter.string(from: end))
        }
        return "\(day) · \(Self.timeFormatter.string(from: start))"
    }

    private var placeText: String? {
        if values.isOnline {
            return values.onlineUrl.isEmpty ? "event_create_phase3_online".localized : values.onlineUrl
        }
        let text = values.addressName.isEmpty ? values.streetAddress : values.addressName
        return text.isEmpty ? nil : text
    }

    private func interestName(_ key: String) -> String {
        let tags = Metadatas.sharedInstance.tagsInterest?.getTags() ?? []
        return tags.first { $0.key == key }?.name ?? key
    }

    private var chips: [EventPreviewChip] {
        var chips = [EventPreviewChip]()
        if !values.isOnline && values.isWheelchairAccessible {
            chips.append(EventPreviewChip(id: "wheelchair", title: "event_form_chip_wheelchair".localized, symbolNames: ["figure.roll", "accessibility", "person.fill"]))
        }
        if values.isFamilyFriendly {
            chips.append(EventPreviewChip(id: "family", title: "event_form_chip_family".localized, symbolNames: ["figure.2.and.child.holdinghands", "person.2.fill"]))
        }
        if values.isReservedFemale {
            chips.append(EventPreviewChip(id: "women", title: "event_form_chip_women".localized, symbolNames: ["figure.stand.dress", "person.fill"]))
        }
        if values.hasPlaceLimit && values.placeLimit > 0 {
            chips.append(EventPreviewChip(id: "places", title: String(format: "event_form_chip_places".localized, values.placeLimit)))
        }
        for key in values.interests {
            chips.append(EventPreviewChip(id: "interest_\(key)", title: interestName(key)))
        }
        return chips
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                EventStepHeader(eyebrow: "event_form_preview_eyebrow".localized, title: "event_form_preview_title".localized, isSmall: true)

                photo
                    .padding(.bottom, 14)

                Text(values.title)
                    .font(EventFormStyle.title(18))
                    .foregroundColor(EventFormStyle.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)

                if let dateText = dateText {
                    metaRow(systemImage: "calendar", text: dateText)
                }
                if let placeText = placeText {
                    metaRow(systemImage: values.isOnline ? "link" : "mappin.and.ellipse", text: placeText)
                }

                if !chips.isEmpty {
                    EventFlowLayout(items: chips, spacing: 7) { chip in
                        chipView(chip)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                }

                if !values.descriptionText.isEmpty {
                    Text(values.descriptionText)
                        .font(EventFormStyle.regular(14))
                        .foregroundColor(EventFormStyle.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 18)
                }

                if !values.groups.isEmpty {
                    groupsNotice
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
    }

    @ViewBuilder
    private var photo: some View {
        let image = EventPhotoImage(localImage: store.localPhoto, remoteUrl: values.imageDisplayUrl)
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 243 / 255, green: 236 / 255, blue: 230 / 255), Color(red: 231 / 255, green: 221 / 255, blue: 211 / 255)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            if image.hasImage {
                image
            }
            else {
                Image(systemName: "photo")
                    .font(.system(size: 34, weight: .light))
                    .foregroundColor(EventFormStyle.ink3)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 158)
        .clipped()
        .cornerRadius(16)
    }

    private func metaRow(systemImage: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(EventFormStyle.ink2)
                .frame(width: 16)
                .padding(.top, 2)
            Text(text)
                .font(EventFormStyle.regular(13.5))
                .foregroundColor(EventFormStyle.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 6)
    }

    private func chipView(_ chip: EventPreviewChip) -> some View {
        HStack(spacing: 5) {
            if let symbols = chip.symbolNames {
                Image(systemName: EventFormStyle.symbol(symbols))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(EventFormStyle.accent)
            }
            Text(chip.title)
                .font(EventFormStyle.semibold(11.5))
                .foregroundColor(EventFormStyle.ink)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 5)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(EventFormStyle.line, lineWidth: 1))
    }

    /// Rappel : « N groupes sélectionnés. Les membres de ces groupes recevront une notification. »
    private var groupsNotice: some View {
        let count = values.groups.count
        let isPlural = count > 1
        let headline = String(format: (isPlural ? "event_form_preview_groups_many" : "event_form_preview_groups_one").localized, count)
        let notice = (isPlural ? "event_form_preview_groups_notice_many" : "event_form_preview_groups_notice_one").localized

        return HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(EventFormStyle.tint)
                Image(systemName: "info.circle")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(EventFormStyle.accent)
            }
            .frame(width: 34, height: 34)

            (Text(headline).font(EventFormStyle.bold(12.5)).foregroundColor(EventFormStyle.ink)
                + Text(" " + notice).font(EventFormStyle.regular(12.5)).foregroundColor(EventFormStyle.ink2))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(13)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(EventFormStyle.line, lineWidth: 1))
    }
}
