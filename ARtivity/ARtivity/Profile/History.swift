//
//  History.swift
//  ARtivity
//
//  Created by Сергей Киселев on 16.01.2025.
//
import UIKit
import SnapKit
import Firebase

class HistoryViewController: UIViewController {
    
//    private var completedTours: [String] = [] // Список пройденных экскурсий
    
    private let tableView = UITableView()
    private let headerView = UIView()
    private let navigationBarView = UIView()
    
    var events = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка интерфейса
        setupUI()
        
        // Загрузка данных
//        loadCompletedTours()
        getFinishedEvent()
    }
    
    private func setupUI() {
//        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        
        // Настройка "навигационной панели"
        setupNavigationBar()
        view.backgroundColor = UIColor(named: "appBackground")
        
        // Настройка таблицы
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        navigationBarView.backgroundColor = .clear
        view.addSubview(navigationBarView)
        
        let titleLabel = UILabel()
        titleLabel.text = "История прогулок"
        titleLabel.textColor = .black
        
        let backButton = UIButton()
        backButton.backgroundColor = .clear
        backButton.setImage(UIImage(named: "navBackButton"), for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        navigationBarView.addSubview(titleLabel)
        navigationBarView.addSubview(backButton)
        
        // Расположение навигационной панели
        navigationBarView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(-50)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100) // Увеличенная шапка для удобства
        }
        
        // Расположение кнопки "Назад"
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // Расположение заголовка
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }
    }
    
    func getFinishedEvent() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let databaseRef = Database.database().reference().child("users/\(uid)")
            databaseRef.observeSingleEvent(of: .value, with: { snapshot in
                let userProfile = snapshot.value as? [String: Any]
                if let completedEvents = userProfile?["completedEvent"] as? [String] {
                    self.events.remove(at: 0)
                    for item in completedEvents {
                        self.events.append(item)
                    }
//                    completedTours = ["Исторический парк", "Городская башня", "Национальный музей"]
                    self.tableView.reloadData()
                }
        })
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: events[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100 // Высота ячейки
        }
}

// MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tourName = events[indexPath.row]
        let alert = UIAlertController(title: "Информация", message: "Вы выбрали экскурсию: \(tourName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
