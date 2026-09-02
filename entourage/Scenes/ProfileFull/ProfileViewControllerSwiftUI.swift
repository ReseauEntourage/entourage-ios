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

// MARK: - Activity Stats (shared, isMe controls title only)

struct MainStatUserView: View {
    let isMe: Bool
    let user: User

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale.getPreferredLocale()
        fmt.dateFormat = "MM/yyyy"
        return fmt.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(isMe ? "mainUserTitleActivity".localized : "detail_user_his_activity".localized)
                .font(.custom("Quicksand-Bold", size: 16))
                .foregroundColor(.black)
                .padding(.top, 10)
                .padding(.bottom, 18)

            if let date = user.creationDate {
                VStack(spacing: 2) {
                    Text("memberSince".localized)
                        .font(.custom("NunitoSans-Regular", size: 14))
                        .foregroundColor(.black)
                    Text(formatDate(date))
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(UIColor.appOrangeLight), lineWidth: 1))
                .padding(.bottom, 12)
            }

            HStack(spacing: 8) {
                let groups = user.stats?.neighborhoodsCount ?? 0
                let outings = max(0, user.stats?.outingsCount ?? 0)

                statCard(
                    count: groups,
                    label: groups <= 1 ? "mainUserTitleGroup".localized : "mainUserTitleGroups".localized,
                    systemIcon: "person.2.fill"
                )
                statCard(
                    count: outings,
                    label: outings <= 1 ? "mainUserTitleOuting".localized : "mainUserTitleOutings".localized,
                    systemIcon: "calendar"
                )
            }
        }
        .padding(10)
        .background(Color.appBeige)
        .cornerRadius(10)
    }

    private func statCard(count: Int, label: String, systemIcon: String) -> some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.custom("Quicksand-Bold", size: 17))
                .foregroundColor(count == 0 ? Color(UIColor.appGris112) : .black)

            HStack(spacing: 4) {
                Image(systemName: systemIcon)
                    .font(.system(size: 12))
                    .foregroundColor(Color(UIColor.appOrange))
                Text(label)
                    .font(.custom("NunitoSans-Regular", size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(UIColor.appOrangeLight), lineWidth: 1))
    }
}

// MARK: - Extension String

extension String {
    func isNullOrEmpty() -> Bool {
        return self.isEmpty || self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
