//
//  CustomTextField.swift
//  ARtivity
//
//  Created by Сергей Киселев on 29.11.2023.
//

import UIKit
import SnapKit

class CustomTextField: UITextField, UITextFieldDelegate {

    private var isSecure = Bool()
    private var placeholderText = String()
    private var bgColor = UIColor()

    convenience init(placeholderText: String, color: UIColor, security: Bool) {
        self.init()
        self.placeholderText = placeholderText
        self.bgColor = color
        self.isSecure = security
        entryField()
    }

    private func entryField() {
        self.textColor = .black
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 0.1
        self.autocorrectionType = .no
        self.isSecureTextEntry = isSecure
        self.autocapitalizationType = .none
        self.backgroundColor = bgColor
        self.layer.borderColor = UIColor.gray.cgColor
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.height))
        self.leftViewMode = .always

        self.snp.makeConstraints { make in
            make.height.equalTo(51)
            make.width.equalTo(UIScreen.main.bounds.width - 32)
        }
    }

    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if isSecureTextEntry {
            button.setImage(UIImage(named: "eyePassHide"), for: .normal)
        } else {
            button.setImage(UIImage(named: "eyePass"), for: .normal)

        }
    }

    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 16),
                              y: CGFloat(5),
                              width: CGFloat(16),
                              height: CGFloat(16))
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }

    @objc func togglePasswordView(_ sender: UIButton) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender)
    }
}


class CustomTextFieldCreate: UITextField, UITextFieldDelegate {
    
    private var placeholderText = String()
    private var bgColor = UIColor()
    private var nameText = String()
    var borderColor = UIColor.gray.cgColor
    
    convenience init(placeholderText: String, color: UIColor, nameText: String) {
        self.init()
        self.placeholderText = placeholderText
        self.bgColor = color
        self.nameText = nameText
        entryField()
    }
    
    private func entryField() {
        self.textColor = .black
        if nameText != "" {
            self.text = nameText
        }
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0, weight: .light)]
        )
        self.font = UIFont.systemFont(ofSize: 14.0)
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.backgroundColor = bgColor
        self.layer.borderColor = borderColor
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.height))
        self.leftViewMode = .always
        
        self.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(UIScreen.main.bounds.width - 64)
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Клавиатура открылась")
    }

        // Завершение редактирования (при уходе фокуса)
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Редактирование завершено")
    }

}
