//
//  InjectTool.swift
//  injectX
//
//  Created by injectX on 2024/11/5.
//

import Foundation
import SwiftUI


class InjectHelper {
    
    
    @StateObject private var logManager = LogManager.shared
    
    let passwordManager = PasswordManager()
    
    func canInject(_ bundleIdentifier: String, _ bundleShortVersion: String, _ bundleVersion: String) -> Bool {
        
        guard let config = ConfigManager.shared.getConfig(),
              let appConfig = config[bundleIdentifier] as? NSDictionary,
              let supportBundleShortVersion = appConfig["bundleShortVersion"] as? String,
              let supportBundleVersion = appConfig["bundleVersion"] as? String,
              let supportedArchs = appConfig["arch"] as? [String] else {
            return false
        }
        
        
        #if arch(x86_64)
        if supportedArchs.contains("x86_64") {
            if supportBundleShortVersion == "ALL" && supportBundleVersion == "ALL" {
                return true
            } else {
                return supportBundleShortVersion == bundleShortVersion && supportBundleVersion == bundleVersion
            }
        }
        #elseif arch(arm64)
        if supportedArchs.contains("arm64") {
            if supportBundleShortVersion == "ALL" && supportBundleVersion == "ALL" {
                return true
            } else {
                return supportBundleShortVersion == bundleShortVersion && supportBundleVersion == bundleVersion
            }
        }
        #endif
        return false
    }
    
    func injected(_ bundleIdentifier: String,_ url: URL) -> Bool {
        
        guard let config = ConfigManager.shared.getConfig(),
              let appConfig = config[bundleIdentifier] as? NSDictionary else {
            return false
        }
        
        if let injectFile = appConfig["injectFile"] {
            let executablePath = url.appendingPathComponent("Contents/MacOS").appendingPathComponent(injectFile as! String).path
            let result = InjectHelper.listSharedLibraries(forPath: executablePath)
            if result.contains("injectX.dylib") {
                return true
            }
        }
        return false
    }
    
    
    private static func listSharedLibraries(forPath path: String) -> String {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/otool")
            task.arguments = ["-L", path]

            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe

            do {
                try task.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                task.waitUntilExit()
                
                if let output = String(data: data, encoding: .utf8) {
                    return output
                } else {
                    return "Error: Unable to decode output"
                }
            } catch {
                return "Error: \(error.localizedDescription)"
            }
        }
    
    
    func validRootPassword(password: String) -> Bool {
        
        let script = """
            do shell script "echo \(password) | sudo -S sudo -v"
        """

        var error: NSDictionary?
        if (NSAppleScript(source: script)?.executeAndReturnError(&error)) != nil {
            logManager.addLog("Password verification successful.", type: .success)
            return true
        } else if error != nil {
            logManager.addLog("Password verification failed.", type: .error)
            return false
        }
        return false
    }
    
    func shell(_ command: String, _ isDebug: Bool, _ root: Bool = true) -> Bool {

        let escapedCommand = command.replacingOccurrences(of: "\"", with: "\\\"")

        let password = passwordManager.getPassword(forKey: "Admin")!
        
        
        
        let appleScript = """
            do shell script "\(root ? "echo \(password) | sudo -S " : "")\(escapedCommand)"
            """
        if isDebug {
            logManager.addLog(appleScript, type: .debug)
        }
        
        

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScript) {
            let output = scriptObject.executeAndReturnError(&error)
            if let error = error {
                logManager.addLog("Error: \(error)", type: .error)
                return false
            } else {
                if isDebug {
                    logManager.addLog(output.description, type: .debug)
                    logManager.addLog("--------------------------------------------------------------------------------------------------------", type: .debug)
                }
                return true
            }
        }

        return false
    }


    
    
    func inject(_ app: AppInfo, _ isDebugModeEnabled: Bool) {
            
            logManager.addLog("Debug mode: \(isDebugModeEnabled)", type: .info)

            guard let password = passwordManager.getPassword(forKey: "Admin"), validRootPassword(password: password) else {
                logManager.addLog("Password verification failed. Update your password to continue.", type: .error)
                return
            }
        
        

        
            guard let appConfig = ConfigManager.shared.getAppConfig(app.bundleIdentifier) else {
                logManager.addLog("App configuration not found.", type: .error)
                return
            }
            
            if let commandValues = appConfig["command"] as? [String], !commandValues.isEmpty {
                
                let alert = NSAlert()
                alert.messageText = NSLocalizedString("Choose Injection Mode", comment: "")
                alert.informativeText = NSLocalizedString("If Non-invasive Mode does not work, try invasive Mode.", comment: "")
                alert.addButton(withTitle: NSLocalizedString("Non-invasive Mode", comment: ""))
                alert.addButton(withTitle: NSLocalizedString("invasive Mode", comment: ""))
                alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
                
                let invasiveButton = alert.buttons[1]
                invasiveButton.bezelColor = NSColor.red
                invasiveButton.contentTintColor = NSColor.white
                
                let response = alert.runModal()

                switch response {
                case .alertFirstButtonReturn:
                    logManager.addLog("Executing Non-invasive Mode.", type: .info)
                    
                    for commandValue in commandValues {
                        _ = shell(commandValue, isDebugModeEnabled, false)
                    }
                    logManager.addLog("App injection completed.", type: .success)
                    logManager.addLog("If Non-invasive Mode does not work, try Injection Mode.", type: .info)
                    
                case .alertSecondButtonReturn:
                    commonInject(app, appConfig, isDebugModeEnabled)
                    
                default:
                    logManager.addLog("Injection process canceled by user.", type: .warning)
                }
                
            } else {
                commonInject(app, appConfig, isDebugModeEnabled)
            }
        }

    func commonInject(_ app: AppInfo, _ appConfig: NSDictionary, _ isDebug: Bool) {
        logManager.addLog("Using Injection Mode.", type: .info)
        
        guard let injectX_dylib = Bundle.main.path(forResource: "injectX", ofType: "dylib") else {
            logManager.addLog("injectX.dylib file not found.", type: .error)
            return
        }
        
        guard let helperTool = Bundle.main.path(forResource: "helperTool", ofType: "") else {
            logManager.addLog("helperTool file not found.", type: .error)
            return
        }
        
        guard let optool = Bundle.main.path(forResource: "optool", ofType: "") else {
            logManager.addLog("optool file not found.", type: .error)
            return
        }
        
        _ = shell("""
                sudo cp -rf "\(injectX_dylib)" "\(app.path)/Contents/MacOS" && sudo chflags hidden "\(app.path)/Contents/MacOS/injectX.dylib"
                """, isDebug)
        logManager.addLog("injectX.dylib copied successfully.", type: .success)
        
        if let fixHelper = (appConfig["fixHelper"] as? String).flatMap({ Bool($0) }), fixHelper {
            logManager.addLog("Fixing helper tools in progress.", type: .info)
            _ = shell("\(helperTool) -i \"\(app.path)/Contents/info.plist\"", isDebug)
            logManager.addLog("Info.plist fixed successfully.", type: .success)
            
            if let launchServices = appConfig["launchServices"] as? [String] {
                for launchService in launchServices {
                    // Construct the full path by combining app.path with the launch service path
                    let fullLaunchServicePath = "\(app.path)/Contents/Library/LaunchServices/\(launchService)"
                    
                    _ = shell("\(helperTool) -h \"\(fullLaunchServicePath)\"", isDebug)
                    logManager.addLog("Helper tool fixed successfully for path: \(launchService)", type: .success)
                    
                    if let injectHelper = (appConfig["injectHelper"] as? String).flatMap({ Bool($0) }), injectHelper {
                        _ = shell("""
                            sudo \(optool) install -c load -p "\(app.path)/Contents/MacOS/injectX.dylib" -t "\(fullLaunchServicePath)"
                        """, isDebug)
                        logManager.addLog("Helper tool injected successfully for path: \(launchService)", type: .success)
                    }
                    
                    _ = shell("sudo codesign -f -s - --timestamp=none --all-architectures --deep \"\(fullLaunchServicePath)\"", isDebug)
                    logManager.addLog("Helper tool codesigned successfully for path: \(launchService)", type: .success)
                }
            } else {
                logManager.addLog("launchServices not found or not an array in app configuration.", type: .error)
            }
        }
        
        if let injectFile = appConfig["injectFile"] as? String {
            _ = shell("""
                sudo \(optool) install -c load -p "\(app.path)/Contents/MacOS/injectX.dylib" -t "\(app.path)/Contents/\(injectFile)"
            """, isDebug)
            logManager.addLog("Main app injected successfully.", type: .success)

            _ = shell("sudo codesign -f -s - --timestamp=none --all-architectures --deep \"\(app.path)/Contents/\(injectFile)\"", isDebug)
            logManager.addLog("Main app codesigned successfully.", type: .success)
        } else {
            logManager.addLog("injectFile not found in app configuration.", type: .error)
        }
        
        _ = shell("sudo xattr -rd com.apple.quarantine \"\(app.path)\"", isDebug)
        logManager.addLog("Removed app quarantine attributes.", type: .success)
        logManager.addLog("App injection completed.", type: .success)
        
        
        let alert = NSAlert()
        alert.messageText = app.name
        alert.informativeText = NSLocalizedString("Injection successful.See GitHub for licensing information.", comment: "")
        alert.runModal()
        

    }
}
