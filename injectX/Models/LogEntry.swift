//
//  LogEntry.swift
//  injectX
//
//  Created by injectX on 2024/11/11.
//

import SwiftUI

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let type: LogType
    let message: String
}
