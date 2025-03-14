//
//  UserInfoHeader.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.01.2024.
//

import UIKit
import Firebase

final class UserInfoHeader: UIView {
    struct DisplayData {
        let username: String
        let status: String
    }

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "person.crop.circle")?.withTintColor(UIColor(named: "mainGreen")! , renderingMode: .alwaysOriginal)

        iv.layer.shadowOpacity = ProfileViewConstants.Header.shadowOpacity
        iv.layer.shadowRadius = ProfileViewConstants.Header.cornerRadius
        iv.layer.cornerRadius = ProfileViewConstants.Header.cornerRadius
        iv.layer.shadowColor = ProfileViewConstants.Header.shadowColor.cgColor

        return iv
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        guard let user = Auth.auth().currentUser else { return UILabel()}
        label.text = user.email ?? "Имя пользователя"
        label.textColor = UIColor(named: "appTextMain")
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        if isMaker == 1 {
            label.text = "Экскурсовод"
        } else {
            label.text = "Пользователь"
        }
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "appTextMain")
        return label
    }()

    private enum Constants {
        static let offset: CGFloat = 10
        static let imagesSize: CGFloat = 60
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        [profileImageView,
                    usernameLabel,
                    statusLabel].forEach {
            self.addSubview($0)
           }
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(Constants.imagesSize)
            make.height.equalTo(Constants.imagesSize + 4)
        }

        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top).offset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.trailing.greaterThanOrEqualToSuperview().offset(-20)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
            make.leading.equalTo(usernameLabel.snp.leading)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ displayData: DisplayData) {
        usernameLabel.text = displayData.username
        statusLabel.text = displayData.status
    }
}
