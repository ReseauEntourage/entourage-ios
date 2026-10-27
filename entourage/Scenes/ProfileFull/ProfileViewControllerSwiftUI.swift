import SwiftUI
import SDWebImage

// MARK: - Color Extensions
extension Color {
    static var appBeige: Color {
        return Color(red: 1, green: 0.91764705882352937, blue: 0.86274509803921573)
    }
}

// MARK: - Shared UI Components

struct ProfileImageView: UIViewRepresentable {
    let urlString: String?
    let size: CGSize

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.frame = CGRect(origin: .zero, size: size)
        let placeholder = UIImage(named: "placeholder_user")?.withRenderingMode(.alwaysOriginal)
        if let urlString = urlString, let url = URL(string: urlString) {
            uiView.sd_setImage(with: url, placeholderImage: placeholder) { image, _, _, _ in
                uiView.image = image?.withRenderingMode(.alwaysOriginal)
            }
        } else {
            uiView.image = placeholder
        }
    }
}

struct PartnerLogoView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if let url = URL(string: urlString) {
            uiView.sd_setImage(with: url, placeholderImage: nil)
        }
    }
}

// MARK: - Helpers

enum ProfileViewHelpers {
    static func formatPhoneNumber(_ number: String) -> String {
        var formatted = number
        if number.hasPrefix("+33") {
            formatted = "0" + number.dropFirst(3)
        }
        let digits = formatted.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        guard digits.count == 10 else { return number }
        return stride(from: 0, to: digits.count, by: 2).map { i -> String in
            let start = digits.index(digits.startIndex, offsetBy: i)
            let end = digits.index(start, offsetBy: 2, limitedBy: digits.endIndex) ?? digits.endIndex
            return String(digits[start..<end])
        }.joined(separator: " ")
    }

    static func formatBirthdate(_ raw: String) -> String {
        if let date = Utils.getDateFromWSDateString(raw) {
            return Utils.formatEventDate(date: date)
        }
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        if let date = parser.date(from: raw) {
            let display = DateFormatter()
            display.dateFormat = "dd/MM/yyyy"
            return display.string(from: date)
        }
        return raw
    }
}

// MARK: - Interest Tags

struct InterestTagsView: View {
    let interests: [String]

    var body: some View {
        WrappingHStack(alignment: .center, spacing: 8) {
            ForEach(interests, id: \.self) { interest in
                InterestTagView(text: Metadatas.sharedInstance.tagsInterest?.getTagNameFrom(key: interest) ?? interest)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct InterestTagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Font(UIFont(name: "NunitoSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)))
            .foregroundColor(Color(UIColor.appOrange))
            .padding(.horizontal, 15)
            .padding(.vertical, 9)
            .background(Color(UIColor.appOrangeLight_50))
            .cornerRadius(15)
    }
}

struct WrappingHStack<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content

    init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        _VariadicView.Tree(Layout()) {
            content()
        }
    }

    private struct Layout: _VariadicView_MultiViewRoot {
        func body(children: _VariadicView.Children) -> some View {
            let views = children.map { AnyView($0) }
            return WrappingHStackLayout(views: views, alignment: .center, spacing: 8)
        }
    }
}

struct WrappingHStackLayout: View {
    let views: [AnyView]
    let alignment: HorizontalAlignment
    let spacing: CGFloat

    @State private var totalHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(0..<self.views.count, id: \.self) { i in
                self.views[i]
                    .padding(.trailing, self.spacing)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) < 1) { return 0 }
                        return d[.leading]
                    })
                    .alignmentGuide(.trailing, computeValue: { d in
                        let result = width
                        width += d.width + self.spacing
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if abs(width - d.width) < 1 {
                            width = 0
                            height += d.height + self.spacing
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

// MARK: - Shared Row

struct ProfileStandardRow: View {
    let imageName: String
    let title: String
    let subtitle: String
    let isMe: Bool
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)))
                    .foregroundColor(isDestructive ? .orange : .black)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                        .foregroundColor(Color(UIColor.appGris112))
                }
            }

            Spacer()

            if isMe {
                Image(systemName: "chevron.right")
                    .foregroundColor(isDestructive ? Color(UIColor.appOrange) : .black)
            }
        }
        .padding()
        .background(Color.white)
        .contentShape(Rectangle())
    }
}

// MARK: - Impact counter (shared, isMe controls title/rows) — EN-9468/EN-9470

private struct ImpactRow: Identifiable {
    let id: String
    let count: Int
    let label: String
    let icon: String
}

struct SeniorityPill: View {
    let date: Date

    private var text: String {
        let parts = Calendar.current.dateComponents([.year, .month], from: date, to: Date())
        let years = parts.year ?? 0
        let months = parts.month ?? 0
        let fmt = DateFormatter()
        fmt.locale = Locale.getPreferredLocale()
        fmt.dateFormat = "LLLL yyyy"
        let monthYear = fmt.string(from: date)

        if years >= 2 {
            return String(format: "member_since_years_format".localized, years, monthYear)
        } else if years == 1 {
            return String(format: "member_since_year_format".localized, years, monthYear)
        } else if months > 0 {
            return String(format: "member_since_months_format".localized, months, monthYear)
        } else {
            return String(format: "member_since_recent_format".localized, monthYear)
        }
    }

    var body: some View {
        Text(text)
            .font(.custom("NunitoSans-SemiBold", size: 13))
            .foregroundColor(Color(UIColor.appOrange))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color(UIColor.appOrangeLight_50))
            .clipShape(Capsule())
    }
}

struct ImpactCounterView: View {
    let isMe: Bool
    let user: User
    /// Own profile only: past outings, actions created, neighborhood messages, conversation members (from `home/summary`).
    var counts: [Int] = []
    /// Called when the new-member state's CTA is tapped (own profile only) — should navigate to the events tab.
    var onDiscoverNearby: (() -> Void)? = nil

    private var rows: [ImpactRow] {
        var all: [ImpactRow]

        if isMe {
            let c = counts + Array(repeating: 0, count: max(0, 4 - counts.count))
            all = [
                ImpactRow(id: "events", count: c[0], label: "impact_row_events_me".localized, icon: "🎉"),
                ImpactRow(id: "entraides", count: c[1], label: "impact_row_entraides_me".localized, icon: "🤝"),
                ImpactRow(id: "groups", count: c[2], label: "impact_row_groups_me".localized, icon: "🏘️"),
                ImpactRow(id: "exchanges", count: c[3], label: "impact_row_exchanges_me".localized, icon: "💬")
            ]
        } else {
            let stats = user.stats
            all = [
                ImpactRow(id: "events", count: stats?.eventsParticipatedCount ?? 0, label: "impact_row_events_other".localized, icon: "🎉"),
                ImpactRow(id: "entraides", count: stats?.entraidesCount ?? 0, label: "impact_row_entraides_other".localized, icon: "🤝"),
                ImpactRow(id: "groups", count: stats?.neighborhoodsCount ?? 0, label: "impact_row_groups_other".localized, icon: "🏘️")
            ]
        }

        // Etat faible activité : une typologie à 0 n'est pas affichée.
        return all.filter { $0.count > 0 }
    }

    private var totalCount: Int {
        rows.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        if isMe || totalCount > 0 {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(isMe ? "impact_title_me".localized : "impact_title_other".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)))
                .foregroundColor(.black)
                .padding(.top, 10)
                .padding(.bottom, 18)

            if isMe && totalCount == 0 {
                newMemberState
            } else {
                VStack(spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(totalCount)")
                            .font(Font(UIFont(name: "Quicksand-Bold", size: 46) ?? UIFont.boldSystemFont(ofSize: 46)))
                            .foregroundColor(Color(UIColor.appOrange))
                        Text((isMe ? "impact_hero_unit_me" : "impact_hero_unit_other").localized)
                            .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)))
                            .foregroundColor(.black)
                    }
                    if isMe {
                        Text((rows.count <= 2 ? "impact_hero_subtitle_low" : "impact_hero_subtitle_me").localized)
                            .font(Font(UIFont(name: "Quicksand-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)))
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.bottom, 6)

                if isMe {
                    Text("impact_detail_title".localized.uppercased())
                        .font(Font(UIFont(name: "NunitoSans-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)))
                        .foregroundColor(Color(UIColor.appGris112))
                        .padding(.top, 12)
                        .padding(.leading, 4)
                        .padding(.bottom, 8)
                }

                VStack(spacing: 8) {
                    ForEach(rows) { row in
                        impactRow(row)
                    }
                }
            }
        }
        .padding(10)
        .background(Color.appBeige)
        .cornerRadius(10)
    }

    private var newMemberState: some View {
        VStack(spacing: 0) {
            Text("🌱")
                .font(.system(size: 36))
                .padding(.bottom, 12)

            Text("impact_new_member_title".localized)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 6)

            Text("impact_new_member_message".localized)
                .font(.custom("NunitoSans-Regular", size: 14))
                .foregroundColor(Color(UIColor.appGris112))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: { onDiscoverNearby?() }) {
                Text("impact_new_member_cta".localized)
                    .font(.custom("Quicksand-Bold", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.appOrange))
                    .clipShape(Capsule())
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.bottom, 6)
    }

    private func impactRow(_ row: ImpactRow) -> some View {
        HStack(spacing: 12) {
            Text(row.icon)
                .font(.system(size: 18))
                .frame(width: 38, height: 38)
                .background(Color(UIColor.appOrangeLight_50))
                .clipShape(Circle())

            Text(row.label)
                .font(Font(UIFont(name: "Quicksand-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Text("\(row.count)")
                .font(Font(UIFont(name: "Quicksand-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(14)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Extension String

extension String {
    func isNullOrEmpty() -> Bool {
        return self.isEmpty || self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
