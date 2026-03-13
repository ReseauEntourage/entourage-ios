import SwiftUI

struct HomeInitialPedagoCarouselView: View {
    let pedagos: [PedagogicResource]
    let onPedagoClick: ((PedagogicResource) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(pedagos, id: \.id) { pedago in
                    Button(action: {
                        onPedagoClick?(pedago)
                    }) {
                        HomePedagoCardView(pedago: pedago, onPedagoClick: nil)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 120) // Approximate height for pedago cards
    }
}
