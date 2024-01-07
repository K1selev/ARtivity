//
//  ProfileViewConstants.swift
//  ARtivity
//
//  Created by Сергей Киселев on 08.01.2024.
//

import UIKit

struct ProfileViewConstants {
    enum Header {
        static let topOffset: CGFloat = 50
        static let height: CGFloat = 100
        static let cornerRadius: CGFloat = 30
        static let shadowColor: UIColor = .gray
        static let shadowOpacity: Float = 0.6
    }

    enum TableView {
        static let topOffset: CGFloat = 20
        static let rowHeight: CGFloat = 50
        static let offset: CGFloat = 0
        static let cornerRadius: CGFloat = 16
        static let heightForHeader: CGFloat = 40
        static let height: CGFloat = 550
        static let contentInsetTop: CGFloat = 0
        static let leftAnchor: CGFloat = 16
    }

    enum Shadow {
        static let shadowRadius: CGFloat = 9 // Радиус тени
        static let shadowOpacity: Float = 0.4 // Прозрачность тени
        static let shadowColor: UIColor = .gray
    }

    enum DeleteBtn {
        static let offset: CGFloat = 20
        static let heightBtn: CGFloat = 20
        static let fontSize: CGFloat = 12
    }
}

