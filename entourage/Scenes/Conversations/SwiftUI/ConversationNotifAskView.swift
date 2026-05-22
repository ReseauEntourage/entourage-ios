import SwiftUI

struct ConversationNotifAskView: View {
    var onRequestSelected: (() -> Void)?

    var body: some View {
        Button(action: {
            onRequestSelected?()
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image("ic_notif_ask")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 10)

                // For proper formatting we use a fallback or simply standard text because iOS 15+ supports Markdown in Text
                // We'll mimic the underlined text
                Text(getAttributedString())
                    .font(.custom("NunitoSans-Regular", size: 15))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(15)
            .background(Color("Beige")) // Beige background like the original
            .cornerRadius(15)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }

    private func getAttributedString() -> AttributedString {
        let fullText = "conversation_notif_text".localized
        let highlightedText = "conversation_notif_highlight".localized

        var attributed = AttributedString(fullText)

        if let range = attributed.range(of: highlightedText) {
            attributed[range].font = Font.custom("NunitoSans-Bold", size: 15)
            attributed[range].underlineStyle = .single
        }

        return attributed
    }
}
