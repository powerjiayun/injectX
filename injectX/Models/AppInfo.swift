//
//  AppInfo.swift
//  injectX
//
//  Created by injectX on 2024/10/30.
//

import Foundation

struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let bundleShortVersion: String
    let bundleVersion: String
    let bundleIdentifier: String
    let path: String
//    let injected: Bool
    let canInject: Bool
    let supportVersion: String
    let supportArch: [String]
    let source: String
    let license: String
}
