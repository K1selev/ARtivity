//
//  SelectedImagesCell.swift
//  ARtivity
//
//  Created by Сергей Киселев on 03.10.2024.
//

import UIKit
import Reusable
import SnapKit

class SelectedImagesCell: UICollectionViewCell, Reusable {

    let imageView = UIImageView()
    let closeButton = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(image: UIImage) {
        imageView.image = image
    }

    private func setupUI() {
        addSubview(imageView)
        addSubview(closeButton)
        self.backgroundColor = .clear
        imageView.layer.cornerRadius = 14
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        closeButton.image = UIImage(systemName: "xmark.square")
        closeButton.tintColor = .black

        imageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 56, height: 56))
            make.left.bottom.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.top.right.equalToSuperview()
        }
    }
}

