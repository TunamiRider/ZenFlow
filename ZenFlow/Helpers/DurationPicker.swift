//
//  DurationPicker.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//

import SwiftUI

struct DurationPicker: View {
    @Binding var minutes: Int
    let steps: [Int] = Array(stride(from: 2, through: 60, by: 5))
    let isRunning: Bool
    private let tickSpacing: CGFloat = 48
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    @State private var dragOffset: CGFloat = 0
    @State private var baseOffset: CGFloat = 0
    
    private var minTotalOffset: CGFloat {
        -CGFloat(steps.count - 1) * tickSpacing
    }
    private var maxTotalOffset: CGFloat { 0 }

    private var selectedMinutes: Int {
        let total = dragOffset + baseOffset
        let index = Int((-total / tickSpacing).rounded())
        let clamped = max(0, min(steps.count - 1, index))
        return steps[clamped]
    }

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let totalOffset = dragOffset + baseOffset

            for (i, step) in steps.enumerated() {
                let x = centerX + CGFloat(i) * tickSpacing + totalOffset
                guard x >= -tickSpacing, x <= size.width + tickSpacing else { continue }

                let distFromCenter = abs(x - centerX)
                let fade = max(0, 1 - distFromCenter / (size.width * 0.45))

                // ✅ Scale factor: 1.0 at edges → 1.6 at center
                let scale = 1.0 + 0.6 * max(0, 1 - distFromCenter / (tickSpacing * 0.8))

                let tickH: CGFloat = 14 * scale
                let tickW: CGFloat = 1.5 * scale

                let rect = CGRect(x: x - tickW / 2, y: size.height - tickH, width: tickW, height: tickH)
                context.fill(
                    Path(roundedRect: rect, cornerRadius: tickW / 2),
                    with: .color(.white.opacity((0.35 + 0.65 * (scale - 1.0)) * fade))
                )

                // Label — larger and brighter at center
                let fontSize: CGFloat = 11 * scale
                let labelAlpha = 0.35 + 0.65 * max(0, 1 - distFromCenter / (tickSpacing * 0.8))
                context.draw(
                    Text("\(step)")
                        .font(.system(size: fontSize, weight: scale > 1.2 ? .semibold : .regular))
                        .foregroundColor(.white.opacity(labelAlpha * fade)),
                    at: CGPoint(x: x, y: size.height - tickH - 6),
                    anchor: .bottom
                )
            }
        }
        .frame(height: 52)
        .gesture(
            isRunning ? nil : DragGesture(minimumDistance: 1)
                .onChanged { value in
                    let rawTotal = baseOffset + value.translation.width
                    let clampedTotal = max(minTotalOffset, min(maxTotalOffset, rawTotal))
                    dragOffset = clampedTotal - baseOffset
                    
                    let newMinutes = selectedMinutes
                    if newMinutes != minutes {
                        minutes = newMinutes
                        feedbackGenerator.impactOccurred()
                    }
                    
                    
//                    dragOffset = value.translation.width
//                    let newMinutes = selectedMinutes
//                    if newMinutes != minutes {
//                        minutes = newMinutes
//                        feedbackGenerator.impactOccurred()
//                    }
                }
                .onEnded { _ in
                    let total = dragOffset + baseOffset
                    let snapped = (total / tickSpacing).rounded() * tickSpacing
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        baseOffset = snapped
                        dragOffset = 0
                    }
                    minutes = selectedMinutes
                }
        )
        .onAppear {
            feedbackGenerator.prepare()
            let index = steps.firstIndex(of: minutes) ?? 0
            baseOffset = -CGFloat(index) * tickSpacing
        }
    }
}

#Preview {
    @Previewable @State var minutes: Int = 5
    @Previewable @State var isRunning = false
    DurationPicker(minutes: $minutes, isRunning: isRunning).background(Color.blue).border(Color.red)
}
