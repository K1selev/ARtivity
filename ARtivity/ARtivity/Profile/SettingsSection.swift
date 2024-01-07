//
//  SettingsSection.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.01.2024.
//

import UIKit

// MARK: - SectionType

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
    var image: String { get }
}

// MARK: - SettingsSection

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Account
    case Other

    var description: String {
        switch self {
        case .Account:
            return "Аккаунт"
        case .Other:
            return "Другое"
        }
    }
}

// MARK: - AccountOptions

enum AccountOptions: Int, CaseIterable, SectionType {
    case personalDataSettings
    case achievements
    case history
    case beGuide
    case changeTheme

    var containsSwitch: Bool {
        false
    }

    var description: String {
        switch self {
        case .personalDataSettings:
            return "Персональные данные"
        case .achievements:
            return "Достижения"
        case .history:
            return "История прогулок"
        case .beGuide:
            return "Стать экскурсоводом"
        case .changeTheme:
            return "Сменить тему"
        }
    }

    var image: String {
        switch self {
        case .personalDataSettings:
            return "person"
        case .achievements:
            return "trophy"
        case .history:
            return "doc.text"
        case .beGuide:
            return "person.badge.plus"
        case .changeTheme:
            return "cloud.sun"
        }
    }
}

// MARK: - OtherOptions

enum OtherOptions: Int, CaseIterable, SectionType {
    case contactUs
    case privacyPolicy
    case signOut

    var containsSwitch: Bool {
        false
    }

    var description: String {
        switch self {
        case .contactUs:
            return "Свяжитесь с нами"
        case .privacyPolicy:
            return "Политика конфиденциальности"
        case .signOut:
            return "Выйти из аккаунта"
        }
    }

    var image: String {
        switch self {
        case .contactUs:
            return "square.and.pencil"
        case .privacyPolicy:
            return "checkmark.shield"
        case .signOut:
            return "multiply.circle"
        }
    }
}
