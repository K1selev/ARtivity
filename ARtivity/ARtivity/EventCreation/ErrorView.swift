//
//  ErrorView.swift
//  ARtivity
//
//  Created by Сергей Киселев on 03.10.2024.
//

import UIKit
import SnapKit

class ErrorView: UIView {

    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        return label
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(16)
        }
        return imageView
    }()

    lazy var errorStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [label,
                                                imageView])
        sv.spacing = 4
        sv.axis = .horizontal
        sv.alignment = .leading
        return sv
    }()

    convenience init(errorText: String) {
        self.init()
        label.text = errorText
        setup()
    }

    private func setup() {
        self.isHidden = true

        addSubview(errorStackView)
        self.snp.makeConstraints { make in
            make.height.equalTo(16)
        }

        errorStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

