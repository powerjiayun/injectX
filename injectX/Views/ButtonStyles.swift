//
//  ButtonStyles.swift
//  injectX
//
//  Created by injectX on 2024/11/11.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .cornerRadius(8)
            .contentShape(Rectangle())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .foregroundColor(.primary)
            .background(configuration.isPressed ?
                        Color(NSColor.controlBackgroundColor).opacity(0.8) :
                        Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .contentShape(Rectangle())
    }
}
