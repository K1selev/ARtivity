//
//  TestVCCity.swift
//  ARtivity
//
//  Created by Сергей Киселев on 18.01.2025.
//
import UIKit
import SnapKit

class TestVCCity: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate {

    private let cities = [
        "Москва", "Санкт-Петербург", "Минск", "Киев", "Алматы", "Ташкент", "Бишкек", "Ереван", "Баку", "Астана",
        "Новосибирск", "Екатеринбург", "Казань", "Нижний Новгород", "Челябинск", "Самара", "Омск", "Ростов-на-Дону"
    ]

    private var filteredCities: [String] = []

    private let textField = UITextField()
    private let dropdownTableView = UITableView()
    private let clearButton = UIButton()
    private var isDropdownVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Настраиваем текстовое поле
        textField.placeholder = "Выберите город"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }

        // Настраиваем кнопку очистки
        clearButton.setTitle("×", for: .normal)
        clearButton.setTitleColor(.black, for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.isHidden = true
        view.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.right.equalTo(textField.snp.right).offset(-10)
            make.centerY.equalTo(textField)
        }

        // Настраиваем UITableView
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cityCell")
        dropdownTableView.isHidden = true
        view.addSubview(dropdownTableView)
        dropdownTableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200) // Ограничиваем высоту выпадающего списка
        }

        filteredCities = cities
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text else { return }

        if searchText.isEmpty {
            filteredCities = cities
        } else {
            filteredCities = cities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }

        dropdownTableView.reloadData()

        if !searchText.isEmpty {
            showDropdown()
        } else {
            hideDropdown()
        }
    }

    @objc private func clearTextField() {
        textField.text = ""
        filteredCities = cities
        dropdownTableView.reloadData()
        hideDropdown()
        textField.resignFirstResponder()
    }

    @objc private func hideDropdown() {
        isDropdownVisible = false
        dropdownTableView.isHidden = true
        clearButton.isHidden = true
    }

    private func showDropdown() {
        isDropdownVisible = true
        dropdownTableView.isHidden = false
        clearButton.isHidden = false
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        cell.textLabel?.text = filteredCities[indexPath.row]
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = filteredCities[indexPath.row]
        textField.text = selectedCity
        hideDropdown()
        textField.resignFirstResponder()
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        filteredCities = cities
        dropdownTableView.reloadData()
        return false
    }
}
