//
//  RegView.swift
//  ARtivity
//
//  Created by Сергей Киселев on 02.12.2023.
//

import UIKit
import Firebase

class RegView: UIViewController, UITextFieldDelegate, RegScreenView {

    private var presenter: RegScreenPresenter?
    private var isError = false

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleName = UILabel()
    
    private var buttonSignIn = UIButton()
    private var signInText = UILabel()
    private let logoAppText = UILabel()

    private var continueButton = CustomButton()
    private var nameField = CustomTextField()
    private var emailField = CustomTextField()
    private var passwordField = CustomTextField()
    private var repeatPasswordField = CustomTextField()

    override func viewDidLoad() {

        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.backgroundColor = .white
        contentView.backgroundColor = .white

        titleName.text = "Регистрация"
        titleName.font = UIFont(name: "Arial", size: 18)
        titleName.textColor = UIColor(named: "mainGreen")
        
        logoAppText.text = "ARtivity"
        logoAppText.font = UIFont(name: "Arial", size: 38)
        logoAppText.textColor = UIColor(named: "mainGreen")

        nameField.returnKeyType = .next
        emailField.returnKeyType = .next
        passwordField.returnKeyType = .next
        repeatPasswordField.returnKeyType = .go

        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self

        continueButton.addTarget(self, action: #selector(didTapButtonContinue), for: .touchUpInside)
        buttonSignIn.addTarget(self, action: #selector(didTapButtonBack), for: .touchUpInside)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPiece))
//        contentView.addGestureRecognizer(tapGesture)
        self.hideKeyboardWhenTappedAround()

        [logoAppText,
         titleName,
         nameField,
         emailField,
         repeatPasswordField,
         passwordField,
         continueButton,
         buttonSignIn,
         signInText].forEach {
            view.addSubview($0)
        }

        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        makeConstraints()
    }

    func makeConstraints() {
        
        logoAppText.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(140)
        }
        
        titleName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(logoAppText.snp.bottom).offset(60)
        }

        nameField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleName.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }
        
        emailField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameField.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        passwordField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emailField.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        repeatPasswordField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        continueButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(repeatPasswordField).offset(77)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }
        signInText.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-80)
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
        }

        buttonSignIn.snp.makeConstraints { make in
            make.top.equalTo(signInText.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
        }
    }

    func setupUI() {
        buttonSignIn.setTitle("Войти", for: .normal)
        buttonSignIn.setTitleColor(UIColor(named: "mainGreen"), for: .normal)

        signInText.text = "Зарегистрированы?"
//        signInText.font = UIFont(name: "Arial", size: 20)
//        signInText.textColor = .black

        continueButton = CustomButton(title: "Зарегистрироваться")
        nameField = CustomTextField(placeholderText: "Имя", color: .white, security: false)
        nameField.clearButtonMode = .whileEditing
        emailField = CustomTextField(placeholderText: "Email", color: .white, security: false)
        emailField.clearButtonMode = .whileEditing
        passwordField = CustomTextField(placeholderText: "Пароль", color: .white, security: true)
        passwordField.clearButtonMode = .never
        passwordField.enablePasswordToggle()
        repeatPasswordField = CustomTextField(placeholderText: "Повторите пароль", color: .white, security: true)
        repeatPasswordField.clearButtonMode = .never
        repeatPasswordField.enablePasswordToggle()
    }

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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            repeatPasswordField.becomeFirstResponder()
        case repeatPasswordField:
            if continueButton.isUserInteractionEnabled {
                didTapButtonContinue()
            }
        default:
            textField.resignFirstResponder()
        }
        return true
    }

//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        if continueButton.isUserInteractionEnabled != false {
//            continueButton.isUserInteractionEnabled = false
//        }
//        return true
//    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
//        let recordField = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
//        let otherFields = [emailField, passwordField]
//        var emptyFields = 0

//        for (index, excess) in otherFields.enumerated() {
//            if excess != textField {
//                emptyFields += otherFields[index].text == "" ? 1 : 0
//            }
//        }

//        if recordField?.isEmpty == false && emptyFields == 0 {
//            continueButton.isUserInteractionEnabled = true
//        } else {
//            continueButton.isUserInteractionEnabled = false
//        }

        return true
    }

    @objc func tapPiece(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    func processingResult(error: String?) {
//        let tabBar = TabBar()
        let vc = EventsViewController()
        buttonSignIn.isEnabled = true
        continueButton.isEnabled = true
        continueButton.loadingStop()

        if error == nil {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: error,
                                          preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 1.2
            DispatchQueue.main.asyncAfter(deadline: when) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }

    func showError(error: String?, textField: UITextField?) {

//        isError = true

        textField?.layer.borderColor = UIColor.red.cgColor
        textField?.layer.borderWidth = 0.7
        self.processingResult(error: error)

//        let errorText = UILabel()
//        errorText.text = CauseOfError.shortPassword.localizedDescription
//        errorText.font = UIFont(name: "Raleway", size: 12)
//        errorText.textColor = .red

//        view.addSubview(errorText)

//        errorText.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(textField!).offset(30)
//            make.leading.equalTo(20)
//            make.height.equalTo(45)
//        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    @objc private func didTapButtonContinue() {
        guard let email = emailField.text, let password = passwordField.text, let repeatPassword = repeatPasswordField.text else {
            return
        }

        if !isValidEmail(email) {
            showError(error: CauseOfError.invalidEmail.localizedDescription, textField: emailField)
            return
        }

        if password.count < 6 {
            // MARK: fix
            showError(error: CauseOfError.shortPassword.localizedDescription, textField: passwordField)
            return
        } else if password != repeatPassword {
            // MARK: fix
            showError(error: CauseOfError.passwordMismatch.localizedDescription, textField: repeatPasswordField)
//            self.processingResult(error: CauseOfError.passwordMismatch.localizedDescription)
            return
        }
        buttonSignIn.isEnabled = false
        continueButton.isEnabled = false
        continueButton.loadingStart()
        self.presenter = RegPresenter(view: self,
                                      email: email,
                                      password: password)

        self.presenter?.dataProcessing()
    }

    @objc private func didTapButtonPrivatePolicy() {
//        if let url = URL(string: "https://pages.flycricket.io/") {
//            UIApplication.shared.open(url)
//        }
//        let vc = PrivatePolicyVC()
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }

    @objc private func didTapButtonBack() {
        dismiss(animated: true, completion: nil)
    }}
