//
//  injectXApp.swift
//  injectX
//
//  Created by injectX on 2024/10/30.
//


import SwiftUI
import Sparkle

// 保持 CheckForUpdatesViewModel 和 CheckForUpdatesView 不变
final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false
    
    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

struct CheckForUpdatesView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updater: SPUUpdater
    
    init(updater: SPUUpdater) {
        self.updater = updater
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }
    
    var body: some View {
        Button("Check for Updates…", action: updater.checkForUpdates)
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let updaterController: SPUStandardUpdaterController
    
    override init() {
        // 创建更新控制器，使用默认的界面和行为
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        
        super.init()
        
        // 配置自动更新
        let updater = updaterController.updater
        updater.automaticallyChecksForUpdates = true      // 启用自动检查更新
//        updater.automaticallyDownloadsUpdates = false     // 不自动下载更新
        updater.updateCheckInterval = 3600              // 检查间隔设为1小时（3600秒）
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 应用启动时在后台检查更新
        updaterController.updater.checkForUpdatesInBackground()
    }
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: appDelegate.updaterController.updater)
            }
        }
    }
}
