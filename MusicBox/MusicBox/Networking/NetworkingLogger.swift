//
//  NetworkingLogger.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation
import OSLog

extension Logger {
    private static let bundle = Bundle.main.bundleIdentifier!
    static let networkingManager = Logger(subsystem: bundle, category: "Networking")
}
