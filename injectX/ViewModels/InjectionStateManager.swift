//
//  InjectionStateManager.swift
//  injectX
//
//  Created by BliZzard on 2024/11/25.
//

import Foundation

class InjectionStateManager: ObservableObject {
    static let shared = InjectionStateManager()
    @Published private(set) var injectedApps: [String: Bool] = [:] // bundleId: isInjected
    
    func updateInjectionStatus(bundleId: String, path: String) {
        if let url = URL(string: path) {
            let injectHelper = InjectHelper()
            let injected = injectHelper.injected(bundleId, url)
            DispatchQueue.main.async {
                self.injectedApps[bundleId] = injected
            }
        }
    }
    
    func setInjected(bundleId: String, injected: Bool) {
        DispatchQueue.main.async {
            self.injectedApps[bundleId] = injected
        }
    }
}
