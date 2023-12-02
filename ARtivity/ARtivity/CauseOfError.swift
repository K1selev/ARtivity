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
            return "wrongLoginPass"
        case .shortPassword:
            return "shortPassword"
        case .mailNotFound:
            return "mailNotFound"
        case .invalidEmail:
            return "invalidEmail"
        case .unknownError:
            return "unknownError"
        case .serverError:
            return "serverError"
        case .entranceFC:
            return "entranceFC"
        case .inactiveAccount:
            return "inactiveAccount"
        case .passwordMismatch:
            return "passwordMismatch"
        case .verificationTimer:
            return "verificationTimer"
        }
    }
}

