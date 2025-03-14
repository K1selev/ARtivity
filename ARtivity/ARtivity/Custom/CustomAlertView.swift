//
//  CustomAlertView.swift
//  ARtivity
//
//  Created by Сергей Киселев on 24.01.2025.
//

import UIKit
import SnapKit

class CustomAlertView: UIView {
    var onYesButtonTapped: (() -> Void)?
    var onNoButtonTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Основной контейнер для алерта
        let alertView = UIView()
        alertView.backgroundColor = .white
        alertView.layer.cornerRadius = 14
        self.addSubview(alertView)

        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "Хотели бы вы добавить квест?"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        alertView.addSubview(titleLabel)

        // Подзаголовок
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Это может привлечь больше путешественников к вашей экскурсии и вызвать больший интерес"
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        alertView.addSubview(subtitleLabel)

        // Кнопка "Да"
        let yesButton = UIButton(type: .system)
        yesButton.setTitle("Да", for: .normal)
        yesButton.setTitleColor(.black, for: .normal)
        yesButton.backgroundColor = UIColor(named: "mainGreen")
        yesButton.layer.cornerRadius = 12
        yesButton.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        alertView.addSubview(yesButton)

        // Кнопка "Нет"
        let noButton = UIButton(type: .system)
        noButton.setTitle("Нет", for: .normal)
        noButton.setTitleColor(.black, for: .normal)
        noButton.backgroundColor = .systemRed
        noButton.layer.cornerRadius = 12
        noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        alertView.addSubview(noButton)

        // Используем SnapKit для ограничения
        alertView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(210)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        yesButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }

        noButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
    }

    @objc private func yesButtonTapped() {
        onYesButtonTapped?()
        dismiss()
    }

    @objc private func noButtonTapped() {
        onNoButtonTapped?()
        dismiss()
    }

    private func dismiss() {
        self.removeFromSuperview()
    }
}
