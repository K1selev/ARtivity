import UIKit
import Firebase
import SnapKit

class AchievementsViewController: UIViewController, UICollectionViewDataSource {
    // UI Elements
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let distanceRingView = CircularProgressView()
    private let distanceLabel = UILabel()
    private let stepsLabel = UILabel()
    private let stepsRingView = CircularProgressView()
    private let toursLabel = UILabel()
    private let pointsLabel = UILabel()
    private let achievementsCollectionView: UICollectionView
    
//    private let stepsLabelText = UILabel()
//    private let toursLabelText = UILabel()
//    private let pointsLabelText = UILabel()
    
    var events = [EventDetailsTest]()
    var eventIDs = [""]
    // Data
    private var totalDistance: Double = 0 // km
    private var distanceGoal: Double = 50.0
    private var stepsGoal: Double = 100000.0
    private var totalTours: Int = 0
    private var totalPoints: Int = 0
    
    
    private let achievementsEvents = [
        (condition: 3, title: "3 экскурсии пройдено", icon: "lock.fill"),
        (condition: 5, title: "5 экскурсий пройдено", icon: "lock.fill"),
        (condition: 7, title: "7 экскурсий пройдено", icon: "lock.fill"),
        (condition: 10, title: "10 экскурсий пройдено", icon: "lock.fill"),
        (condition: 20, title: "20 экскурсий пройдено", icon: "lock.fill")
    ]
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        achievementsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        achievementsCollectionView.dataSource = self // Устанавливаем dataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFinishedEvent()
        setupView()
    }
    
    func getFinishedEvent() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/\(uid)")
        databaseRef.observeSingleEvent(of: .value, with: { snapshot in
            let userProfile = snapshot.value as? [String: Any]
            if let completedEvents = userProfile?["completedEvent"] as? [String] {
                self.events.remove(at: 0)
                for item in completedEvents {
                    self.eventIDs.append(item)
                }
                for event in self.eventIDs {
                        let databaseRef = Database.database().reference().child("event/\(event)")
                        databaseRef.observeSingleEvent(of: .value, with: { snapshot in
                            let eventInfo = snapshot.value as? [String: Any]
                            if let eventDistance = eventInfo?["eventDistance"] as? Int {
                                self.totalDistance += Double(eventDistance / 1000)
                            }
                            if let eventPoints = eventInfo?["eventPointCount"] as? Int {
                                self.totalPoints += eventPoints
                                self.totalTours += 1
                            }
                            self.updateUI()
                        })
//                        self.tableView.reloadData()
                }
//                    self.tableView.reloadData()
            }
    })
}
    
    private func setupView() {
        
//        for item in events {
//            totalDistance += Double(item.eventDistance ?? 0)
//            totalTours += 1
//            totalPoints += item.eventPointCount ?? 0
//        }
//        
//        totalDistance = events
        view.backgroundColor = UIColor.systemBackground
        
        backButton.backgroundColor = .clear
        backButton.setImage(UIImage(named: "navBackButton"), for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleLabel.text = "Достижения"
//        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        
        [distanceLabel, stepsLabel, toursLabel, pointsLabel].forEach { label in
            label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            label.textAlignment = .center
        }
        distanceLabel.text = "Пройдено километров: 0 км"
        stepsLabel.text = "Пройдено шагов: 0"
        toursLabel.text = "Пройдено экскурсий: 0"
        pointsLabel.text = "Пройдено точек: 0"
        
        achievementsCollectionView.backgroundColor = .clear
        achievementsCollectionView.showsHorizontalScrollIndicator = false
        achievementsCollectionView.register(AchievementCell.self, forCellWithReuseIdentifier: AchievementCell.identifier)
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(distanceRingView)
        view.addSubview(distanceLabel)
        view.addSubview(stepsRingView)
        view.addSubview(stepsLabel)
        view.addSubview(toursLabel)
        view.addSubview(pointsLabel)
        view.addSubview(achievementsCollectionView)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(34)
        }
        
        distanceRingView.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 150, height: 150))
        }
        stepsLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceRingView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(34)
//            make.left.right.equalToSuperview().inset(20)
        }
        
        stepsRingView.snp.makeConstraints { make in
            make.top.equalTo(stepsLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 150, height: 150))
        }
        
        toursLabel.snp.makeConstraints { make in
            make.top.equalTo(stepsRingView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(34)
//            make.left.right.equalToSuperview().inset(20)
        }
        
        achievementsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(toursLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(140)
        }
        
        pointsLabel.snp.makeConstraints { make in
            make.top.equalTo(achievementsCollectionView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
//            make.left.right.equalToSuperview().inset(20)
        }
    }
    
    private func updateUI() {
        let progressDistance = totalDistance / distanceGoal
        distanceRingView.setProgress(progressDistance, animated: true)
        let progressSteps = totalDistance * 1312 / stepsGoal
        stepsRingView.setProgress(progressSteps, animated: true)
        
        stepsLabel.text = "Пройдено шагов: \(Int(totalDistance * 1312))"
        toursLabel.text = "Пройдено экскурсий: \(totalTours)"
        pointsLabel.text = "Пройдено точек: \(totalPoints)"
        distanceLabel.text = "Пройдено километров: \(Int(totalDistance)) км"
        achievementsCollectionView.reloadData()
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource Implementation
extension AchievementsViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return achievementsEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AchievementCell.identifier, for: indexPath) as? AchievementCell else {
            return UICollectionViewCell()
        }
        
        let achievement = achievementsEvents[indexPath.item]
        let isUnlocked = totalTours >= achievement.condition
        cell.configure(with: achievement.title, icon: isUnlocked ? "checkmark.seal" : "lock.fill", isUnlocked: isUnlocked)
        return cell
    }
}
