//
//  MacStatusBadge.swift
//  injectX
//
//  Created by injectX on 2024/11/11.
//

import SwiftUI

struct MacStatusBadge: View {
    let title: LocalizedStringKey
    let icon: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(title)
                .font(.system(size: 12))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isActive ? Color.green.opacity(0.1) : Color.secondary.opacity(0.1))
        .foregroundColor(isActive ? .green : .secondary)
        .cornerRadius(4)
    }
}
