//
//  MacLogEntryView.swift
//  injectX
//
//  Created by injectX on 2024/11/11.
//

import SwiftUI

struct MacLogEntryView: View {
    let log: LogEntry
    
    private var typeColor: Color {
        switch log.type {
        case .info: return .blue
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        case .debug: return .secondary
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(typeColor)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(log.timestamp, style: .time)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(log.message)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
