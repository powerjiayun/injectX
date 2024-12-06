//
//  ConfigManager.swift
//  injectX
//
//  Created by BliZzard on 2024-12-06.
//

import SwiftUI

class ConfigManager {
    // 使用静态属性作为全局单例
    static let shared = ConfigManager()
    
    // 私有初始化方法，确保只能通过shared单例访问
    private init() {
        loadConfig()
    }
    
    // 私有配置存储属性
    private var configDict: NSDictionary?
    
    // 私有方法，用于加载配置
    private func loadConfig() {
        guard let plistPath = Bundle.main.path(forResource: "config", ofType: "plist") else {
            print("Error: Cannot find config.plist")
            return
        }
        
        configDict = NSDictionary(contentsOfFile: plistPath)
    }
    
    // 获取完整配置
    func getConfig() -> NSDictionary? {
        return configDict
    }
    
    // 获取特定App的配置
    func getAppConfig(_ bundleIdentifier: String) -> NSDictionary? {
        guard let config = configDict,
              let appConfig = config[bundleIdentifier] as? NSDictionary else {
            print("Error: Cannot find app-specific config for bundle identifier \(bundleIdentifier)")
            return nil
        }
        
        return appConfig
    }
    
}
