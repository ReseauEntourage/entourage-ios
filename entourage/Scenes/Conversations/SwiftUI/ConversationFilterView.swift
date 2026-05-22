import SwiftUI

struct ConversationFilterView: View {
    let filters: [String]
    @Binding var selectedFilter: String
    var onFilterSelected: ((String) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        onFilterSelected?(filter)
                    }) {
                        Text(filter)
                            .font(.custom("Quicksand-Bold", size: 13))
                            .padding(.vertical, 0)
                            .padding(.horizontal, 20)
                            .frame(height: 40)
                            .foregroundColor(filter == selectedFilter ? .white : Color("orange_app"))
                            .background(filter == selectedFilter ? Color("orange_app_conv_event_clicked") : Color("orange_app_conv_event_unclicked"))
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
        }
    }
}
