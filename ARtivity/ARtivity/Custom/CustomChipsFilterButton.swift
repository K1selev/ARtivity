//
//  CustomChipsFilterButton.swift
//  ARtivity
//
//  Created by Сергей Киселев on 25.06.2024.
//


import UIKit

class CustomChipsFilterButton: UIButton {
    
    private var textColor = UIColor()
    private var title = String()
    private var background = UIColor()
    
    private var loading = UIActivityIndicatorView()
    
    convenience init(title: String) {
        self.init(type: .custom)
        self.textColor = UIColor(named: "appTextMain")!
        self.title = title
        self.background = UIColor(named: "mainGreen")!
        setup()
    }
    
    private func setup() {
        self.isEnabled = true
        self.layer.cornerRadius = 14
        self.titleLabel?.font = .systemFont(ofSize: 16)
        self.setTitle(title, for: .normal)
        self.backgroundColor = background.withAlphaComponent(0.5)
        self.setTitleColor(textColor, for: .normal)
        self.tintColor = textColor
    }
}
