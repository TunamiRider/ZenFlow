//
//  OceanBackground.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//
import SwiftUI
// MARK: - Ocean Background
struct OceanBackground: View {
    let imagePath: String
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(imagePath)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                Color.black.opacity(0.35)

                LinearGradient(
                    colors: [
                        Color(red: 0.42, green: 0.48, blue: 0.55).opacity(0.25),
                        Color(red: 0.55, green: 0.52, blue: 0.50).opacity(0.15),
                        Color(red: 0.65, green: 0.55, blue: 0.48).opacity(0.10),
                        Color(red: 0.50, green: 0.52, blue: 0.55).opacity(0.20),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RadialGradient(
                    colors: [
                        Color(red: 0.85, green: 0.65, blue: 0.45).opacity(0.20),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: 0.55),
                    startRadius: 0,
                    endRadius: geo.size.width * 0.7
                )

                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [Color.black.opacity(0.30), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geo.size.height * 0.22)
                    Spacer()
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geo.size.height * 0.35)
                }
            }
        }
    }
}
