//
//  PlugViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 08.01.2024.
//

import UIKit

// MARK: - PlugViewController

final class PlugViewController: UIViewController {
    //    var output: ProfileViewOutput
    private let moduleImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "gear")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        return iv
    }()

    private let moduleLabel: UILabel = {
        let label = UILabel()
        label.text = "Модуль в разработке"
        label.textColor = .gray//.prog.Dynamic.text
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }

    private func configureUI() {
        let imageSize = 150
        view.addSubview(moduleImageView)
        view.addSubview(moduleLabel)
        moduleImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(imageSize)
            make.height.equalTo(imageSize)
        }

        moduleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.moduleImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
}

