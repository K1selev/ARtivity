//
//  AchievementCell.swift
//  ARtivity
//
//  Created by Сергей Киселев on 18.01.2025.
//

import UIKit

class AchievementCell: UICollectionViewCell {
    static let identifier = "AchievementCell"
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = UIColor.systemGray4
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        iconImageView.contentMode = .scaleAspectFit
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(4)
        }
    }
    
    func configure(with title: String, icon: String, isUnlocked: Bool) {
        contentView.backgroundColor = isUnlocked ? UIColor(named: "mainGreen") : .systemGray4
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)?.withTintColor(isUnlocked ? .black : .systemGray, renderingMode: .alwaysOriginal)
    }
}
