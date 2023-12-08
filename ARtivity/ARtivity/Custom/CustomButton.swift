//
//  CustomButton.swift
//  ARtivity
//
//  Created by Сергей Киселев on 29.11.2023.
//

import UIKit

class CustomButton: UIButton {

    private var textColor = UIColor()
    private var title = String()
    private var background = UIColor()

    private var loading = UIActivityIndicatorView()

    convenience init(textColor: UIColor = .white
                     ,
                     background: UIColor = .blue,
                     title: String) {
        self.init(type: .custom)
        self.textColor = textColor
        self.title = title
        self.background = background
        setup()
    }

    private func setup() {
        self.isEnabled = true
        self.layer.cornerRadius = 14
        self.setTitle(title, for: .normal)
        self.backgroundColor = background
        self.setTitleColor(textColor, for: .normal)
        self.tintColor = textColor
//        self.titleLabel?.font = AppFont.bodyBold
    }

    override var isHighlighted: Bool {
        didSet {
            guard let background = backgroundColor, let color = titleColor(for: self.state) else { return }

            UIView.animate(withDuration: self.isHighlighted ? 0 : 0.4,
                           delay: 0.0,
                           options: [.beginFromCurrentState, .allowUserInteraction],
                           animations: {
                self.backgroundColor = background.withAlphaComponent(self.isHighlighted ? 0.3 : 1)
                self.setTitleColor(color.withAlphaComponent(self.isHighlighted ? 0.3 : 1), for: .normal)
            })
        }
    }

    override var isUserInteractionEnabled: Bool {
        didSet {
            guard let background = backgroundColor, let color = titleColor(for: self.state) else { return }

            UIView.animate(withDuration: self.isUserInteractionEnabled ? 0.0 : 0,
                           delay: 0.0,
                           options: [.beginFromCurrentState],
                           animations: {
                self.backgroundColor = background.withAlphaComponent(self.isUserInteractionEnabled ? 1 : 0.3)
                self.setTitleColor(color.withAlphaComponent(self.isUserInteractionEnabled ? 1 : 0.3), for: .normal)
            })
        }
    }

    func loadingStart() {
        self.setTitle("", for: .normal)
        self.addSubview(loading)
        loading.startAnimating()
        loading.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        loading.isHidden = false
    }

    func loadingStop() {
        self.setTitle(title, for: .normal)
        loading.removeFromSuperview()
        loading.stopAnimating()
        loading.isHidden = true
    }
}
