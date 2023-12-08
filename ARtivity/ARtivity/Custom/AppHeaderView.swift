//
//  AppHeaderView.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import UIKit
import SnapKit
import Firebase

class AppHeaderView: UIView {

    private lazy var title: UILabel = {
        let label = UILabel()
        label.textColor = .blue
        label.text = "ARtivity"
        return label
    }()

    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        button.setTitle("", for: .normal)
        return button
    }()

    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            guard let user = Auth.auth().currentUser else { return button}
            button.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
            button.setTitle(" \(user.email ?? "User name")", for: .normal)
        } else {
            button.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
            button.setTitle(" Profile", for: .normal)
        }
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .white
        setupConstraints()
        setupActions()
    }

    private func setupConstraints() {
        addSubview(leftButton)
        addSubview(title)
        addSubview(rightButton)

        leftButton.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.leading.equalToSuperview().offset(20)
            make.bottom.top.equalToSuperview()
        }
        rightButton.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(130)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.top.equalToSuperview()
        }
        title.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 83, height: 29))
            make.center.equalToSuperview()
        }
    }

    private func setupActions() {

    }
}

