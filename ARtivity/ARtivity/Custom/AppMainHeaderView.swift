//
//  AppHeaderView.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import UIKit
import SnapKit
import Firebase

var isMaker = 0

class AppMainHeaderView: UIView {
    lazy var title: UIButton = {
        let button = UIButton()
        button.setTitle("ARtivity", for: .normal)
        button.setTitleColor(UIColor(named: "mainGreen"), for: .normal)
        return button
    }()

    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "navMapPoint"), for: .normal)
        button.setTitle("", for: .normal)
        return button
    }()

    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            guard let user = Auth.auth().currentUser else { return button}
            
            let ref = Database.database().reference()
            let userRef = ref.child("users").child(user.uid)
            userRef.observeSingleEvent(of: .value, with: {(snapshot) in
                let dictUserInfo = snapshot.value as? [String:AnyObject]
                let maker = dictUserInfo?["isMaker"]
                guard let makerNonOpt = maker else {
                    return
                }
                isMaker = makerNonOpt as! Int
                if isMaker == 1 {
                    button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                    button.tintColor = UIColor(named: "mainGreen") ?? .green
                    button.setTitle("", for: .normal)
                } else {
                    button.setImage(UIImage(named: "profileAvaDef"), for: .normal)
                    button.setTitle(" \(user.email ?? "User name")", for: .normal)
                }
            })
           
        } else {
            button.setImage(UIImage(named: "profileAvaDef"), for: .normal)
            button.setTitle(" Profile", for: .normal)
        }
        button.setTitleColor(.gray, for: .normal)
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
        backgroundColor = UIColor(named: "appHeader")
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

    }}

