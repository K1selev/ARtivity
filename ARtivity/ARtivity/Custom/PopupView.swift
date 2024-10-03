//
//  PopupView.swift
//  ARtivity
//
//  Created by Сергей Киселев on 03.10.2024.
//

import UIKit
import SnapKit

class PopupView: UIView {

    let width = UIScreen.main.bounds.width - 90
//    let font = FontFamily.Raleway.medium.font(size: 15)
    var height = 0

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
//        label.textColor = Asset.textBaseOnDark.color
//        label.font = FontFamily.Raleway.medium.font(size: 15)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    lazy var trailingImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = Asset.popupOrange.image
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(16)
        }
        return imageView
    }()

    convenience init(text: String, image: UIImage) {
        self.init()
//        height = Int(text.heightOfString(width: width,
//                                         font: font))
        titleLabel.text = text
        trailingImageView.image = image
        setupUI()
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(trailingImageView)

//        self.backgroundColor = Asset.overlapBlack80.color
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        let width = UIScreen.main.bounds.width - 90
//        let font = FontFamily.Raleway.medium.font(size: 15)
//        let height = titleLabel.text?.heightOfString(width: width,
//                                                  font: font)

        titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 12, left: 16,
                                            bottom: 12, right: 42))
//            guard let height = height else { return }
            make.height.equalTo(height)
        }
        trailingImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
    }
}

