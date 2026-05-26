//
//  SoundPickerSheet.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//

import SwiftUI
import AVPlayerPlus
// MARK: - Ocean Theme

private enum OceanTheme {
    /// Warm sandy background
    static let sand         = Color(red: 0.82, green: 0.68, blue: 0.50)
    static let sandLight    = Color(red: 0.88, green: 0.76, blue: 0.60)
    static let sandDeep     = Color(red: 0.72, green: 0.58, blue: 0.42)

    /// Deep blue-slate — selected circle fill & icon tint
    static let deepSlate    = Color(red: 0.22, green: 0.27, blue: 0.40)
    static let slateLight   = Color(red: 0.30, green: 0.36, blue: 0.50)

    /// Sea-green for the toggle
    static let seaGreen     = Color(red: 0.20, green: 0.55, blue: 0.48)

    /// Unselected circle fill — slightly muted sand
    static let circleIdle   = Color(red: 0.70, green: 0.57, blue: 0.42).opacity(0.45)

    /// Card / row background
    static let cardBg       = Color(red: 0.87, green: 0.74, blue: 0.57).opacity(0.55)
    static let divider      = Color(red: 0.65, green: 0.52, blue: 0.37).opacity(0.40)

    /// Text
    static let textPrimary  = Color(red: 0.15, green: 0.18, blue: 0.26)
    static let textMuted    = Color(red: 0.38, green: 0.32, blue: 0.24)
    static let textSelected = deepSlate
}

// MARK: - Font Helpers

private extension Font {
    static var oceanTitle: Font {
        .system(.headline, design: .rounded, weight: .semibold)
    }
    static var oceanBody: Font {
        .system(.body, design: .rounded, weight: .regular)
    }
    static var oceanCaption: Font {
        .system(.caption, design: .rounded, weight: .medium)
    }
    static var oceanCaptionSmall: Font {
        .system(size: 10, weight: .medium, design: .rounded)
    }
    static var oceanSubhead: Font {
        .system(.subheadline, design: .rounded, weight: .medium)
    }
}

// MARK: - Waveform View

struct WaveformView: View {
    let bars: [CGFloat]
    let isSelected: Bool
    let isAnimating: Bool

    @State private var animationPhase: CGFloat = 0

    private let barCount = 8
    private let barWidth: CGFloat = 2.5
    private let spacing: CGFloat = 2.0

    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .frame(width: barWidth, height: barHeight(for: index))
            }
        }
        .onAppear {
            guard isAnimating else { return }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                animationPhase = 1
            }
        }
        .onChange(of: isAnimating) { animating in
            if animating {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    animationPhase = 1
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) { animationPhase = 0 }
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let base = bars[index]
        let maxH: CGFloat = 28, minH: CGFloat = 4
        if isAnimating {
            let wave = sin(animationPhase * .pi + CGFloat(index) * 0.15)
            let scaled = base + wave * 0.25 * (1 - base)
            return minH + scaled * (maxH - minH)
        }
        return minH + base * (maxH - minH)
    }
}

// MARK: - Sound Circle Item

struct SoundCircleItem: View {
    let sound: SoundResource
    let isSelected: Bool
    let onTap: () -> Void

    private let circleSize: CGFloat = 64

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if isSelected {
                    Circle()
                        .stroke(OceanTheme.deepSlate.opacity(0.25), lineWidth: 3)
                        .frame(width: circleSize + 8, height: circleSize + 8)
                }

                Circle()
                    .fill(isSelected ? OceanTheme.deepSlate : OceanTheme.circleIdle)
                    .frame(width: circleSize, height: circleSize)
                    .shadow(
                        color: isSelected ? OceanTheme.deepSlate.opacity(0.35) : .clear,
                        radius: 8, x: 0, y: 4
                    )

                WaveformView(
                    bars: sound.waveformBars,
                    isSelected: isSelected,
                    isAnimating: isSelected
                )
                .foregroundColor(.white)
            }
            .onTapGesture(perform: onTap)
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

            Text(sound.displayName)
                .font(.oceanCaptionSmall)
                .foregroundColor(isSelected ? OceanTheme.textSelected : OceanTheme.textMuted)
                .multilineTextAlignment(.center)
                .frame(width: circleSize + 8)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }
}

// MARK: - Ocean Toggle Style

struct OceanToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? OceanTheme.textSelected : Color.gray.opacity(0.5))
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
                        .frame(width: 24, height: 24)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.spring(response: 0.28, dampingFraction: 0.75), value: configuration.isOn)
                )
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

// MARK: - Ding Settings Section

struct DingSettingsSection: View {
    @Binding var dingEnabled: Bool
    @Binding var dingInterval: Int

    private let intervalOptions = [1, 3, 5, 10]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
//            Text("Ding (start/end)")
//                .font(.oceanTitle)
//                .foregroundColor(OceanTheme.textPrimary)
//                .padding(.horizontal)
//                .padding(.bottom, 10)
            
            Text("Interval Ding")
                .font(.oceanTitle)
                .foregroundColor(OceanTheme.textPrimary)
                .padding(.horizontal)
                .padding(.bottom, 10)

            VStack(spacing: 0) {
                // Toggle row
                Toggle(isOn: $dingEnabled) {
                    Label {
                        Text("Ding Sound")
                            .font(.oceanBody)
                            .foregroundColor(OceanTheme.textPrimary)
                    } icon: {
                        Image(systemName: "bell.fill")
                            .foregroundColor(OceanTheme.deepSlate)
                    }
                }
                .toggleStyle(OceanToggleStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                //.background(OceanTheme.cardBg)

                if dingEnabled {
                    Rectangle()
                        .fill(OceanTheme.divider)
                        .frame(height: 1)
                        .padding(.leading, 44)

                    HStack {
                        Label {
                            Text("Repeat Every")
                                .font(.oceanBody)
                                .foregroundColor(OceanTheme.textPrimary)
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(OceanTheme.deepSlate)
                        }
                        Spacer()
                        Menu {
                            ForEach(intervalOptions, id: \.self) { minutes in
                                Button {
                                    dingInterval = minutes
                                } label: {
                                    HStack {
                                        Text(intervalLabel(minutes))
                                        if dingInterval == minutes {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(intervalLabel(dingInterval))
                                    .font(.oceanSubhead)
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(OceanTheme.textSelected)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    //.background(OceanTheme.cardBg)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(OceanTheme.sandDeep.opacity(0.30), lineWidth: 1)
            )
            .padding(.horizontal)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dingEnabled)
    }

    private func intervalLabel(_ minutes: Int) -> String {
        minutes == 1 ? "1 min" : "\(minutes) mins"
    }
}

// MARK: - Sound Picker Sheet

struct SoundPickerSheet: View {
    @Binding var selectedSound: SoundResource
    @Binding var dingEnabled: Bool
    @Binding var dingInterval: Int
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 80), spacing: 16)]

    var body: some View {
        NavigationStack {
            ZStack {
                //OceanTheme.sand.ignoresSafeArea()
                Color(red: 0.38, green: 0.44, blue: 0.53).opacity(0.05).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {

                        DingSettingsSection(
                            dingEnabled: $dingEnabled,
                            dingInterval: $dingInterval
                        )

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Sound")
                                .font(.oceanTitle)
                                .foregroundColor(OceanTheme.textPrimary)
                                .padding(.horizontal)

                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(SoundResource.allCases, id: \.self) { sound in
                                    SoundCircleItem(
                                        sound: sound,
                                        isSelected: selectedSound == sound
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedSound = sound
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)   // increased from default → 24
                            .padding(.vertical, 13)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(OceanTheme.sandDeep.opacity(0.30), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Sound Settings")
            .navigationBarTitleDisplayMode(.inline)
            //.toolbarBackground(OceanTheme.sand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sound Settings")
                        .font(.oceanTitle)
                        .foregroundColor(OceanTheme.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.oceanSubhead)
                        .foregroundColor(OceanTheme.deepSlate)
                        .background(
                            Capsule()
                                .fill(OceanTheme.sand.opacity(0.5))
                        )
                        .overlay(
                            Capsule()
                                .stroke(OceanTheme.deepSlate.opacity(0.15), lineWidth: 1)
                        )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: AVPlayerPlus.SoundResource = .seaLagoonWaves
        @State private var dingEnabled: Bool = true
        @State private var dingInterval: Int = 10
        @State private var showSheet = false

        var body: some View {
            ZStack {
                //OceanTheme.sand.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Selected: \(selected.displayName)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(OceanTheme.textPrimary)
                    Text("Ding: \(dingEnabled ? "On" : "Off") · Every \(dingInterval) min")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(OceanTheme.textMuted)
                    Button("Open Sound Settings") { showSheet = true }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(OceanTheme.deepSlate)
                        .clipShape(Capsule())
                }
            }
            .sheet(isPresented: $showSheet) {
                ZStack {
                    Color.black.opacity(0.05)
                    SoundPickerSheet(
                        selectedSound: $selected,
                        dingEnabled: $dingEnabled,
                        dingInterval: $dingInterval
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                }
                

            }
        }
    }
    return PreviewWrapper()
}
