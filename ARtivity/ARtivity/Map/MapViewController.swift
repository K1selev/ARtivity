//
//  MapViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 22.12.2023.
//

import UIKit
import SnapKit

class MapViewController: UIViewController {
    var topView = AppHeaderView()
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topView)
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        makeConstraints()
    }
    
    func makeConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    @objc func buttonProfileClicked()
    {
        if isLogin {
            print("already loged in")
        } else {
            let vc = AuthViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    @objc func buttonBackClicked() {
      dismiss(animated: true)
    }
}
