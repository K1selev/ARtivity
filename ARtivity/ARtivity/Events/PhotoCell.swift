//
//  PhotoCell.swift
//  ARtivity
//
//  Created by Сергей Киселев on 27.12.2023.
//

import UIKit
import SnapKit

final class PhotoCell: UICollectionViewCell {
    
    private let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    private func setup() {
        backgroundColor = .systemGray5
        layer.cornerRadius = 16
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        
        addSubview(imageView)
    }
    
    func configure(with model: UIImage?) {
        imageView.image = model
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}
