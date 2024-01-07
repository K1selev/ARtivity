//
//  CauseOfError.swift
//  ARtivity
//
//  Created by Сергей Киселев on 29.11.2023.
//

import Foundation

enum CauseOfError {
    case loginOrPassword
    case shortPassword
    case mailNotFound
    case invalidEmail
    case unknownError
    case serverError
    case entranceFC
    case verificationTimer
    case inactiveAccount
    case passwordMismatch
}

extension CauseOfError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .loginOrPassword:
            return "Неверный логин или пароль"
        case .shortPassword:
            return "Слишком короткий пароль"
        case .mailNotFound:
            return "Email не найден"
        case .invalidEmail:
            return "Неверный email"
        case .unknownError:
            return "Неизвестная ошибка"
        case .serverError:
            return "Ошибка сервера"
        case .entranceFC:
            return "Ошибка входа"
        case .inactiveAccount:
            return "Неактивный аккаунт"
        case .passwordMismatch:
            return "Пароли не совпадают"
        case .verificationTimer:
            return "Verification timer"
        }
    }
}

