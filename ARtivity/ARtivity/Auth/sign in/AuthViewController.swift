//
//  AuthViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 29.11.2023.
//

import UIKit

class AuthViewController: UIViewController, UITextFieldDelegate, AuthScreenView {

    private var presenter: AuthPresenter?

    private let logoPetGeoAuth = UIView()
    private let titleName = UILabel()

    private var emailField = CustomTextField()
    private var passwordField = CustomTextField()
    private var buttonSignIn = CustomButton()

    private var buttonSignUp = UIButton()
    private var buttonSignUpAs = UIButton()

    private var buttonRestore = UIButton()
//    private let alternativeWaySignIn = UIView()
//    private let appleButton = UIButton()
//    private let googleButton = UIButton()

    override func viewDidLoad() {

        super.viewDidLoad()
        view.backgroundColor = .systemGray5

        buttonSignIn.isUserInteractionEnabled = true

        emailField = CustomTextField(placeholderText: "email",
                                     color: .white,
                                     security: false)
        passwordField = CustomTextField(placeholderText: "password",
                                        color: .white,
                                        security: true)
        buttonSignIn = CustomButton(title: "sign in")
        buttonSignUp.setTitle("sign up", for: .normal)
        buttonSignUp.setTitleColor(.systemGray, for: .normal)

        buttonRestore.setTitle("forgot password", for: .normal)
        buttonRestore.setTitleColor(.systemGray, for: .normal)

        logoPetGeoAuth.layer.contents = UIImage(named: "figure.roll")?.cgImage

        titleName.text = "sign in"
        titleName.font = UIFont(name: "Arial", size: 28)
        titleName.textColor = .black

        emailField.returnKeyType = .next
        passwordField.returnKeyType = .go

        emailField.delegate = self
        passwordField.delegate = self
        emailField.clearButtonMode = .whileEditing
        passwordField.enablePasswordToggle()

//        alternativeWaySignIn.layer.contents = Asset.authAlternativeWayReg.image.cgImage
//        appleButton.addTapGestureRecognizer {
//            self.didTapAppleButton()
//        }
//        googleButton.addTapGestureRecognizer {
//            self.didTapGoogleButton()
//        }

//        appleButton.setImage(Asset.authAppleButton.image, for: .normal)
//        googleButton.setImage(Asset.authGoogleButton.image, for: .normal)
//
        buttonSignIn.addTarget(self, action: #selector(didTapButtonSignIn), for: .touchUpInside)
        buttonSignUp.addTarget(self, action: #selector(didTapButtonSignUp), for: .touchUpInside)
        buttonRestore.addTarget(self, action: #selector(didTapRestoreButton), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPiece))
        self.view.addGestureRecognizer(tapGesture)

        [logoPetGeoAuth,
         titleName,
         emailField,
         passwordField,
         buttonSignIn,
         buttonSignUp,
         buttonRestore].forEach {
            view.addSubview($0)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logoPetGeoAuth.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
            make.width.equalTo(375)
            make.top.equalToSuperview().inset(116)
        }

        titleName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(200)
        }

        emailField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleName).offset(60)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        passwordField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emailField).offset(61)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }
        buttonRestore.snp.makeConstraints { make in
            make.top.equalTo(passwordField).offset(50)
            make.trailing.equalTo(-20)
            make.height.equalTo(45)
        }

        buttonSignIn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(buttonRestore).offset(60)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

//        alternativeWaySignIn.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.height.equalTo(20)
//            make.width.equalTo(375)
//            make.top.equalTo(buttonSignIn).offset(80)
//        }
//
//        appleButton.snp.makeConstraints { make in
//            make.centerX.equalToSuperview().offset(-40)
//            make.height.equalTo(48)
//            make.width.equalTo(64)
//            make.top.equalTo(alternativeWaySignIn).offset(40)
//        }
//
//        googleButton.snp.makeConstraints { make in
//            make.centerX.equalToSuperview().offset(40)
//            make.height.equalTo(48)
//            make.width.equalTo(64)
//            make.top.equalTo(alternativeWaySignIn).offset(40)
//        }

        buttonSignUp.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview().offset(100)
            make.height.equalTo(45)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }

//        if buttonSignIn.isUserInteractionEnabled {
            if textField == passwordField {
                didTapButtonSignIn()
            }
//        }

        return true
    }

//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        if buttonSignIn.isUserInteractionEnabled != false {
//            buttonSignIn.isUserInteractionEnabled = false
//        }
//
//        return true
//    }
//
//    func textField(_ textField: UITextField,
//                   shouldChangeCharactersIn range: NSRange,
//                   replacementString string: String) -> Bool {
//        return true
//    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1.6
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.blue.cgColor
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
//        let recordField = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
//        let secondField = (textField == passwordField) ? emailField.text : passwordField.text

//        if recordField != "" && secondField != "" {
//            buttonSignIn.isUserInteractionEnabled = true
//        } else {
//            buttonSignIn.isUserInteractionEnabled = false
//        }

        return true
    }

    @objc func tapPiece(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    func processingResult(error: String?) {
//        let tabBar = TabBar()
        let vc = EventsViewController()
        buttonSignIn.loadingStop()
        buttonSignIn.isEnabled = true
        buttonSignUp.isEnabled = true

        if error == nil {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "error",
                                          message: error, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 1.2
            DispatchQueue.main.asyncAfter(deadline: when) {
              alert.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc func didTapButtonSignIn() {
        buttonSignIn.loadingStart()
        buttonSignIn.isEnabled = false
        buttonSignUp.isEnabled = false

        presenter = AuthPresenter(view: self, email: emailField.text, password: passwordField.text)
        self.presenter?.dataProcessing()
    }

    @objc func didTapButtonSignUp() {
        let regView = RegView()
        regView.modalTransitionStyle = .crossDissolve
        regView.modalPresentationStyle = .overCurrentContext
        self.present(regView, animated: true, completion: nil)
    }

    @objc func didTapRestoreButton() {
        let forgotPasswordView = ForgotPassViewController()

        forgotPasswordView.modalTransitionStyle = .crossDissolve
        forgotPasswordView.modalPresentationStyle = .overCurrentContext
        self.present(forgotPasswordView, animated: true, completion: nil)
    }
}
