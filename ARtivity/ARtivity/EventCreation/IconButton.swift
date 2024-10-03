//
//  IconButton.swift
//  ARtivity
//
//  Created by Сергей Киселев on 03.10.2024.
//

import UIKit
import SnapKit

class IconButton: UIButton {

    private var icon = UIImage()
    private var background = UIColor()

    private var loading = UIActivityIndicatorView(style: .large)

    convenience init(background: UIColor = UIColor.clear,
                     icon: UIImage) {
        self.init(type: .custom)
        self.background = background
        self.icon = icon
        setup()
    }

    private func setup() {
        self.isEnabled = true
        self.layer.cornerRadius = 14
        self.setTitle("", for: .normal)
        self.backgroundColor = background
        self.setImage(icon, for: .normal)
        self.tintColor = .black
    }

    func loadingStart() {
        self.addSubview(loading)
        loading.startAnimating()
        loading.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        loading.isHidden = false
    }

    func loadingStop() {
        loading.removeFromSuperview()
        loading.stopAnimating()
        loading.isHidden = true
    }
}
