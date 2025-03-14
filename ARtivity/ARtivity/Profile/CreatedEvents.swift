//
//  CreatedEvents.swift
//  ARtivity
//
//  Created by Сергей Киселев on 18.01.2025.
//

import UIKit
import SnapKit
import Firebase

class CreatedEventsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let headerView = UIView()
    private let navigationBarView = UIView()
    
    var events = [""]
    var eventsName = [""]
    var eventsImgs = [""]
    var eventsFull: [EventDetailsTest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getFinishedEvent()
    }
    
    private func setupUI() {
        setupNavigationBar()
        view.backgroundColor = UIColor(named: "appBackground")
        
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
        titleLabel.text = "Созданные экскурсии"
        titleLabel.textColor = .black
        
        let backButton = UIButton()
        backButton.backgroundColor = .clear
        backButton.setImage(UIImage(named: "navBackButton"), for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        navigationBarView.addSubview(titleLabel)
        navigationBarView.addSubview(backButton)
        
        navigationBarView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(-50)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100) // Увеличенная шапка для удобства
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
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
                if let completedEvents = userProfile?["userEvents"] as? [String] {
                    self.events.remove(at: 0)
                    for item in completedEvents {
                        self.events.append(item)
                    }
                    for event in self.events {
                            let databaseRef = Database.database().reference().child("event/\(event)")
                            databaseRef.observeSingleEvent(of: .value, with: { snapshot in
                                let eventInfo = snapshot.value as? [String: Any]
                                if let eventName = eventInfo?["eventName"] as? String {
                                    self.eventsName.append(eventName)
                                    print(self.eventsName)
                                    if let eventImg = eventInfo?["eventImage"] as? String {
                                        self.eventsImgs.append(eventImg)
                                        print(self.eventsImgs)
                                        self.tableView.reloadData()
                                    }
                                }
                            })
                    }
                }
        })
        let dbRef = Database.database().reference().child("event/")
        dbRef.observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [EventDetailsTest]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let post = EventDetailsTest.parse(childSnapshot.key, data)
                {
                    tempPosts.insert(post, at: 0)
                }
            }
            self.eventsFull = tempPosts
        })
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CreatedEventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsName.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: eventsName[indexPath.row + 1], img: eventsImgs[indexPath.row + 1])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 150
        }
}

extension CreatedEventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tourName = eventsName[indexPath.row + 1]
        for item in eventsFull {
            if item.eventName == tourName {
                print("o da")
                if !(item.eventQuest ?? true) {
                    let alert = CustomAlertView(frame: self.view.bounds)
                    alert.onYesButtonTapped = {
                        print("Пользователь выбрал 'Да'")
                        let vc = CreateQuestViewController()
                        vc.id = item.id ?? ""
                        vc.event = item
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                    alert.onNoButtonTapped = {
                        print("Пользователь выбрал 'Нет'")
                    }
                    self.view.addSubview(alert)
                } else {
                    let alert = UIAlertController(title: "Информация", message: "Вы выбрали экскурсию: \(tourName)", preferredStyle: .alert)
                           alert.addAction(UIAlertAction(title: "ОК", style: .default))
                           present(alert, animated: true)
                }
            }
        }
    }
}
