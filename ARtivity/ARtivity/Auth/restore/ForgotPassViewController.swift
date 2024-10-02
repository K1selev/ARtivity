//
//  ForgotPassViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 02.12.2023.
//

import UIKit

class ForgotPassViewController: UIViewController, UITextFieldDelegate, ForgotPasswordScreenView {

    private var presenter: ForgotPasswordScreenPresenter?

    private let sectionTitle = UILabel()
    private var emailField = CustomTextField()
    private var buttonThrowOff = CustomButton()
    private var buttonGoBack = UIButton()
    private let subView = UILabel()

    private let copyEmail = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "appBackground")

        emailField.clearButtonMode = .whileEditing

        emailField = CustomTextField(placeholderText: "email",
                                     color: .white,
                                     security: false)
        buttonThrowOff = CustomButton(title: "Восстановить пароль")
        buttonGoBack.setImage(UIImage(named: "navBackButton"), for: .normal)

        sectionTitle.text = "Восстановление пароля"
        sectionTitle.font = UIFont(name: "Arial", size: 28)
        sectionTitle.textColor = UIColor(named: "appTextMain")
        
        subView.text = "Введите почту для сброса пароля"
        subView.font = UIFont(name: "Arial", size: 16)
        subView.textColor = UIColor(named: "appTextMain")
        subView.numberOfLines = 0
        subView.textAlignment = .center

        emailField.returnKeyType = .go

        emailField.delegate = self
        emailField.clearButtonMode = .whileEditing

        buttonThrowOff.isUserInteractionEnabled = true
        buttonGoBack.isUserInteractionEnabled = true

        buttonGoBack.addTarget(self, action: #selector(didTapButtonGoBack), for: .touchUpInside)
        buttonThrowOff.addTarget(self, action: #selector(didTapButtonThrowOff), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPiece))
        self.view.addGestureRecognizer(tapGesture)

        [sectionTitle, subView, emailField, buttonThrowOff, buttonGoBack].forEach {
            view.addSubview($0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sectionTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(250)
         }

        subView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(sectionTitle).offset(50)
            make.width.equalTo(343)
         }

        emailField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subView).offset(100)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        buttonThrowOff.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(emailField).offset(60)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        buttonGoBack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalTo(20)
            make.width.equalTo(45)
            make.height.equalTo(45)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if buttonThrowOff.isUserInteractionEnabled {
            didTapButtonThrowOff()
        }

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 0.7
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.layer.borderWidth = 0
        } else {
            textField.layer.borderWidth = 0.7
            textField.layer.borderColor = UIColor.gray.cgColor
        }
    }

//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        if buttonThrowOff.isUserInteractionEnabled != false {
//            buttonThrowOff.isUserInteractionEnabled = false
//        }
//
//        return true
//    }

//    func textField(_ textField: UITextField,
//                   shouldChangeCharactersIn range: NSRange,
//                   replacementString string: String) -> Bool {
//        let recordField = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
//
//        if recordField?.isEmpty == false {
//            buttonThrowOff.isUserInteractionEnabled = true
//        } else {
//            buttonThrowOff.isUserInteractionEnabled = false
//        }
//
//        return true
//    }

    @objc func tapPiece(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    func conclusion(title: String, message: String?) {
//        let when = DispatchTime.now() + 1.2
//
//        buttonGoBack.isEnabled = true
//        buttonThrowOff.isEnabled = true
//        buttonThrowOff.loadingStop()
//
//        if title == "" {
//            let forgotPasswordView = SuccessfullyRestored()
//            forgotPasswordView.userName = emailField.text!
//
//            forgotPasswordView.modalTransitionStyle = .crossDissolve
//            forgotPasswordView.modalPresentationStyle = .overCurrentContext
//            self.present(forgotPasswordView, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title: title,
//                                          message: message,
//                                          preferredStyle: .alert)
//
//            self.present(alert, animated: true, completion: nil)
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                alert.dismiss(animated: true, completion: nil)
//            }
//        }
    }

    @objc func didTapButtonThrowOff() {
//        guard let email = emailField.text else {
//            return
//        }
//
//        buttonGoBack.isEnabled = true
//        buttonThrowOff.isEnabled = false
//        buttonThrowOff.loadingStart()
//
//        presenter = ForgotPasswordPresenter(view: self, email: email)
//
//        self.presenter?.checkForSending()
    }

    @objc func didTapButtonGoBack() {
        dismiss(animated: true, completion: nil)
    }
}

