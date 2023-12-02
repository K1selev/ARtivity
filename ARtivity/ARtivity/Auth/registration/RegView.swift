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
    
    private var backButton = UIButton()
    private var backText = UILabel()

    private var continueButton = CustomButton()
    private var emailField = CustomTextField()
    private var passwordField = CustomTextField()
    private var repeatPasswordField = CustomTextField()

    override func viewDidLoad() {

        super.viewDidLoad()
        view.backgroundColor = .systemGray5

        setupUI()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.backgroundColor = .white
        contentView.backgroundColor = .white

        titleName.text = "create account"
        titleName.font = UIFont(name: "Arial", size: 28)
        titleName.textColor = .black

        emailField.returnKeyType = .next
        passwordField.returnKeyType = .next
        repeatPasswordField.returnKeyType = .go

        emailField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self

        continueButton.addTarget(self, action: #selector(didTapButtonContinue), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapButtonBack), for: .touchUpInside)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPiece))
//        contentView.addGestureRecognizer(tapGesture)
        self.hideKeyboardWhenTappedAround()

        [
         titleName,
         emailField,
         repeatPasswordField,
         passwordField,
         continueButton,
         backButton,
         backText].forEach {
            view.addSubview($0)
        }

        emailField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        makeConstraints()
    }

    func makeConstraints() {
        
        titleName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(219)
        }

        emailField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleName).offset(60)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        passwordField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            if isError {
//                make.centerY.equalTo(emailField).offset(61)
//            } else {
                make.centerY.equalTo(emailField).offset(61)
//            }
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        repeatPasswordField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            if isError {
//                make.centerY.equalTo(passwordField).offset(61)
//            } else {
                make.centerY.equalTo(passwordField).offset(61)
//            }
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }

        continueButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(repeatPasswordField).offset(77)
            make.leading.equalTo(20)
            make.height.equalTo(45)
        }
        backButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview().offset(90)
            make.height.equalTo(45)
        }

        backText.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50)
            make.trailing.equalTo(backButton).offset(-60)
            make.height.equalTo(45)
        }
    }

    func setupUI() {
        backButton.setTitle("sign in", for: .normal)
        backButton.setTitleColor(.blue, for: .normal)

        backText.text = "already reged"
        backText.font = UIFont(name: "Arial", size: 20)
        backText.textColor = .black

        continueButton = CustomButton(title: "sign up")
        emailField = CustomTextField(placeholderText: "email", color: .white, security: false)
        emailField.clearButtonMode = .whileEditing
        passwordField = CustomTextField(placeholderText: "password", color: .white, security: true)
        passwordField.clearButtonMode = .never
        passwordField.enablePasswordToggle()
        repeatPasswordField = CustomTextField(placeholderText: "repeate password", color: .white, security: true)
        repeatPasswordField.clearButtonMode = .never
        repeatPasswordField.enablePasswordToggle()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blue.cgColor
        textField.layer.borderWidth = 1.6
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray.cgColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
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
        let tabBar = TabBar()

        backButton.isEnabled = true
        continueButton.isEnabled = true
        continueButton.loadingStop()

        if error == nil {
            self.present(tabBar, animated: true, completion: nil)
//            let vc = MailConfirmation()
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
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
        textField?.layer.borderWidth = 5
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
        backButton.isEnabled = false
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
