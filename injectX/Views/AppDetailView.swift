//
//  AppDetailView.swift
//  injectX
//
//  Created by injectX on 2024/11/4.
//
import SwiftUI

struct AppDetailView: View {
    let app: AppInfo
    
    @Binding var hasRootPassword: Bool
    @State private var icon: NSImage?
    @State private var isIconLoaded = false
    @StateObject private var logManager = LogManager.shared
    @State private var isDebugModeEnabled = false
    @State private var injected = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                // App Icon and Title section
                HStack(spacing: 16) {
                    Group {
                        if let icon = icon, isIconLoaded {
                            Image(nsImage: icon)
                                .resizable()
                                .interpolation(.high)
                                .frame(width: 64, height: 64)
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "app.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.name)
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Version \(app.bundleShortVersion) (\(app.bundleVersion))")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Status Badges section
                HStack(spacing: 8) {
                    MacStatusBadge(title: "Can Inject", icon: app.canInject ? "checkmark.circle.fill" : "xmark.circle.fill", isActive: app.canInject)
                    MacStatusBadge(title: "Injected", icon: injected ? "checkmark.circle.fill" : "xmark.circle.fill", isActive: injected)
                    
                    
                    
                    
                    if app.source != "" {
                        MacStatusBadge(title: LocalizedStringKey(app.source), icon: "cart", isActive: true)
                    }
                    
                    ForEach(app.supportArch, id: \.self) { arch in
                        MacStatusBadge(title: LocalizedStringKey(arch),
                                     icon: "cpu",
                                     isActive: app.canInject)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // App Information section
                VStack(alignment: .leading, spacing: 12) {
                    Text("App Information")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 10) {
                        InfoRow(title: "Bundle ID", value: app.bundleIdentifier, icon: "info.circle.fill")
                        InfoRow(title: LocalizedStringKey("Location"), value: app.path, icon: "folder.fill")
                        InfoRow(title: "Support Version", value: app.supportVersion, icon: "checkmark.shield.fill")
                        InfoRow(title: "Support Arch", value: "[\(app.supportArch.joined(separator: "  "))]", icon: "cpu")
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Action Buttons section - Reorganized into a grid
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 120, maximum: 130), spacing: 12),
                    ], spacing: 12) {
                        
                        // Inject Button
                            ActionButton(
                                title: "Inject",
                                icon: "bolt.circle",
                                isPrimary: true,
                                isDisabled: !app.canInject,
                                action: {
                                    if hasRootPassword {
                                        let injectHelper = InjectHelper()
                                        injectHelper.inject(app, isDebugModeEnabled)
                                        if let url = URL(string: app.path) {
                                            DispatchQueue.main.async {
                                                injected = injectHelper.injected(app.bundleIdentifier, url)
                                                    // 更新全局状态
                                                    InjectionStateManager.shared.setInjected(
                                                        bundleId: app.bundleIdentifier,
                                                        injected: injected
                                                    )
                                            }
                                        }
                                    } else {
                                        logManager.addLog("Please enter the password first for injection use!", type: .warning)
                                    }
                                }
                            )
                        // Run App Button
                        ActionButton(
                            title: "Run App",
                            icon: "play.fill",
                            action: { NSWorkspace.shared.open(URL(fileURLWithPath: app.path)) }
                        )
                        
                        // Copy Bundle ID Button
                            ActionButton(
                                title: "Copy Bundle ID",
                                icon: "doc.on.clipboard",
                                action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(app.bundleIdentifier, forType: .string)
                                }
                            )
                        
                        // Show in Finder Button
                            ActionButton(
                                title: "Show in Finder",
                                icon: "folder",
                                action: {
                                    NSWorkspace.shared.selectFile(app.path, inFileViewerRootedAtPath: "")
                                }
                            )
                        
                       
                        
                        // Copy License Button (if available)
//                            if !app.license.isEmpty {
//                                ActionButton(
//                                    title: "Copy License",
//                                    icon: "doc.on.clipboard",
//                                    isDisabled: !injected,
//                                    action: {
//                                        NSPasteboard.general.clearContents()
//                                        NSPasteboard.general.setString(app.license, forType: .string)
//                                    }
//                                )
//                            }
                    }
                }
                .padding(14)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding(16)
            
            Divider()
            
            // Console Output section (unchanged)
            VStack(spacing: 0) {
                HStack {
                    Label {
                        Text("Console Output")
                            .font(.system(size: 13, weight: .medium))
                    } icon: {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Toggle("Debug Mode", isOn: $isDebugModeEnabled)
                        .padding(.trailing, 8)
                    
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(logManager.getLogs(), forType: .string)
                    }) {
                        Label("Copy Logs", systemImage: "doc.on.clipboard")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    
                    Button(action: { logManager.clearLogs() }) {
                        Label("Clear", systemImage: "trash")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .frame(height: 36)
                
                Divider()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 1) {
                            ForEach(logManager.logs) { log in
                                MacLogEntryView(log: log)
                                    .id(log.id)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onChange(of: logManager.logs.count) { _ in
                        if let lastLog = logManager.logs.last {
                            proxy.scrollTo(lastLog.id, anchor: .bottom)
                        }
                    }
                }
                .background(Color(NSColor.textBackgroundColor))
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .task(id: app.id) {
            let injectHelper = InjectHelper()
            
            if let url = URL(string: app.path) {
                injected = injectHelper.injected(app.bundleIdentifier, url)
            }
            
            icon = nil
            isIconLoaded = false
            
            let newIcon = NSWorkspace.shared.icon(forFile: app.path)
            newIcon.size = NSSize(width: 64, height: 64)
            
            if !Task.isCancelled {
                icon = newIcon
                isIconLoaded = true
            }
            
            logManager.clearLogs()
            setupInitialLogs()
        }
        .onDisappear {
            logManager.clearLogs()
        }
    }
    
    private func setupInitialLogs() {
        logManager.addLog("Started monitoring \(app.name)", type: .debug)
        logManager.addLog("Bundle identifier: \(app.bundleIdentifier)", type: .debug)
    }
}

struct ActionButton: View {
    let title: LocalizedStringKey
    let icon: String
    var isPrimary: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .frame(minWidth: 100, maxWidth: 130)
            .frame(height: 28)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isPrimary ? Color.blue : Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 0.5, x: 0, y: 0.5)
            )
            .foregroundColor(isPrimary ? .white : .primary)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}
