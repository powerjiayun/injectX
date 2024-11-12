//
//  AppHomePageView.swift
//  injectX
//
//  Created by injectX on 2024/11/7.
//
import SwiftUI

struct AppHomePageView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: backgroundGradientColors()),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Spacer()
                
                Text("Welcome to App InjectX")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(titleColor())
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                
                Text("Please select an app from the left panel to view its details and manage injections.")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(descriptionColor())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Image(nsImage: getAppIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
                
                Spacer()
                
                // Add GitHub link as text
                Link("GitHub", destination: URL(string: "https://github.com/inject-X")!)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleColor())
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.secondary.opacity(0.2))
                    )
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 80)
        }
    }

    func getAppIcon() -> NSImage {
        let appIcon = NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
        return appIcon
    }

    func backgroundGradientColors() -> [Color] {
        return colorScheme == .dark ? [Color.black, Color.gray] : [Color.white, Color.silver]
    }
    
    func titleColor() -> Color {
        return colorScheme == .dark ? Color.white : Color.primary
    }

    func descriptionColor() -> Color {
        return colorScheme == .dark ? Color.white.opacity(0.8) : Color.secondary
    }
}

private extension Color {
    static let steel = Color(red: 0.6, green: 0.6, blue: 0.65)
    static let silver = Color(red: 0.75, green: 0.75, blue: 0.78)
}
