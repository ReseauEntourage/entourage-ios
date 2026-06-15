import SwiftUI

private struct DotConfig {
    let xRatio: CGFloat
    let yRatio: CGFloat
    let radius: CGFloat
    let color: Color
    let phaseOffset: Double
}

private let dotConfigs: [DotConfig] = {
    let positions: [(CGFloat, CGFloat)] = [
        (0.15, 0.18), (0.75, 0.12), (0.88, 0.35),
        (0.08, 0.55), (0.92, 0.60), (0.20, 0.82),
        (0.80, 0.80), (0.50, 0.08), (0.55, 0.90),
        (0.35, 0.25), (0.65, 0.22), (0.30, 0.70),
        (0.70, 0.68), (0.42, 0.50), (0.10, 0.38)
    ]
    let colors: [Color] = [.orange, Color(red: 0.2, green: 0.7, blue: 0.3), Color(red: 0.2, green: 0.5, blue: 0.9), Color(red: 0.8, green: 0.2, blue: 0.2)]
    return positions.enumerated().map { i, pos in
        DotConfig(
            xRatio: pos.0,
            yRatio: pos.1,
            radius: CGFloat(4 + (i % 3) * 2),
            color: colors[i % colors.count],
            phaseOffset: Double(i) / Double(positions.count)
        )
    }
}()

struct BadgeDotsAnimationView: View {
    @State private var phase: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<dotConfigs.count, id: \.self) { i in
                    let dot = dotConfigs[i]
                    let currentPhase = (phase + dot.phaseOffset).truncatingRemainder(dividingBy: 1.0)
                    let alpha = sin(currentPhase * .pi)
                    Circle()
                        .fill(dot.color)
                        .frame(width: dot.radius * 2, height: dot.radius * 2)
                        .opacity(Double(alpha).clamped(to: 0.15...0.85))
                        .position(
                            x: geo.size.width * dot.xRatio,
                            y: geo.size.height * dot.yRatio
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
