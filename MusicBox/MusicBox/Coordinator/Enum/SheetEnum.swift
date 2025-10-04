//
//  SheetEnum.swift
//  MusicBox
//
//  Created by Luca Lacerda on 03/10/25.
//

public enum SheetEnum: Identifiable {

    case sheet1

    public var id: String {
        switch self {
        case .sheet1:
            return "1"
        }
    }
}
