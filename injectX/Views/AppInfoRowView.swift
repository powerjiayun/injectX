//
//  AppInfoRow.swift
//  injectX
//
//  Created by injectX on 2024/10/30.
//
import SwiftUI

struct AppInfoRowView: View {
    let app: AppInfo
    @State private var icon: NSImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(nsImage: icon ?? NSWorkspace.shared.icon(forFile: app.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .fill(app.canInject ? Color.green : Color.gray)
                            .frame(width: 6, height: 6)
                            .offset(x: 0, y: 24)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.title3)
                        .lineLimit(1)
                    
                    HStack {
                        Text(app.bundleShortVersion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            if app.source != "" {
                                Text(app.source)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            ForEach(app.supportArch, id: \.self) { arch in
                                Text(arch)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .onAppear {
            loadIcon()
        }
    }
    
    private func loadIcon() {
        Task {
            let icon = NSWorkspace.shared.icon(forFile: app.path)
            await MainActor.run {
                self.icon = icon
            }
        }
    }
}
