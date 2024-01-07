//
//  AuthViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 29.11.2023.
//

import UIKit

class AuthViewController: UIViewController, UITextFieldDelegate, AuthScreenView {

    private var presenter: AuthPresenter?

    private let logoApp = UIView()
    private let titleName = UILabel()
    private let backButton = UIButton()
    private var emailField = CustomTextField()
    private var passwordField = CustomTextField()
    private var buttonSignIn = CustomButton()
    private var buttonSignUp = UIButton()
    private let signUpText = UILabel()
    private var buttonRestore = UIButton()

    override func viewDidLoad() {

        super.viewDidLoad()
        view.backgroundColor = .white

        buttonSignIn.isUserInteractionEnabled = true

        emailField = CustomTextField(placeholderText: "email",
                                     color: .white,
                                     security: false)
        passwordField = CustomTextField(placeholderText: "пароль",
                                        color: .white,
                                        security: true)
        buttonSignIn = CustomButton(title: "Войти")
        buttonSignUp.setTitle("Зарегистрироваться", for: .normal)
        buttonSignUp.setTitleColor(UIColor(named: "mainGreen"), for: .normal)
        
        signUpText.text = "Нет аккаунта?"

        buttonRestore.setTitle("забыли пароль?", for: .normal)
        buttonRestore.setTitleColor(.systemGray, for: .normal)

        logoApp.layer.contents = UIImage(named: "logo")?.cgImage

        titleName.text = "Вход"
        titleName.font = UIFont(name: "Arial", size: 18)
        titleName.textColor = UIColor(named: "mainGreen")

        emailField.returnKeyType = .next
        passwordField.returnKeyType = .go

        emailField.delegate = self
        passwordField.delegate = self
        emailField.clearButtonMode = .whileEditing
        passwordField.enablePasswordToggle()
        
        backButton.setImage(UIImage(named: "navBackButton"), for: .normal)
        backButton.addTarget(self,action:#selector(buttonBackClicked), for:.touchUpInside)
        
        buttonSignIn.addTarget(self, action: #selector(didTapButtonSignIn), for: .touchUpInside)
        buttonSignUp.addTarget(self, action: #selector(didTapButtonSignUp), for: .touchUpInside)
        buttonRestore.addTarget(self, action: #selector(didTapRestoreButton), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPiece))
        self.view.addGestureRecognizer(tapGesture)

        [logoApp,
         titleName,
         emailField,
         passwordField,
         buttonSignIn,
         buttonSignUp,
         buttonRestore,
        backButton,
         signUpText].forEach {
            view.addSubview($0)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logoApp.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(150)
            make.width.equalTo(150)
            make.top.equalToSuperview().offset(120)
        }

        titleName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(logoApp.snp.bottom).offset(60)
        }

        emailField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleName.snp.bottom).offset(20)
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
            make.height.equalTo(51)
        }
        
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(70)
        }
        
        signUpText.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-80)
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
        }

        buttonSignUp.snp.makeConstraints { make in
            make.top.equalTo(signUpText.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
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
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.gray.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.layer.borderWidth = 0
        } else {
            textField.layer.borderWidth = 0.7
            textField.layer.borderColor = UIColor.gray.cgColor
        }
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
    
    @objc func buttonBackClicked() {
      dismiss(animated: true)
    }
}
