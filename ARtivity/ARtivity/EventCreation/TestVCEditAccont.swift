//
//  TestVCCity.swift
//  ARtivity
//
//  Created by Сергей Киселев on 18.01.2025.
//
import UIKit
import SnapKit

class TestVCEditAccont: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let changeAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Avatar", for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Profile"

        view.addSubview(avatarImageView)
        view.addSubview(changeAvatarButton)
        view.addSubview(usernameTextField)
        view.addSubview(saveButton)

        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        avatarImageView.layer.cornerRadius = 60

        changeAvatarButton.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(changeAvatarButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseAvatar))
        avatarImageView.addGestureRecognizer(tapGesture)
        changeAvatarButton.addTarget(self, action: #selector(chooseAvatar), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveUserProfile), for: .touchUpInside)
    }

    @objc private func chooseAvatar() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @objc private func saveUserProfile() {
        let username = usernameTextField.text ?? ""
        print("Saved UserProfile: Username - \(username)")
        // Здесь вы можете добавить сохранение данных
        let alert = UIAlertController(title: "Success", message: "Your profile has been updated!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            avatarImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
