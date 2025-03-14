//
//  QuestListViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 21.01.2025.
//

import UIKit
import SnapKit
import Firebase

struct QuestPoint {
    let title: String
    let description: String
    let question: String?
    let options: [String]?
    let requiresStreetAnswer: Bool
    let correctAnswer: String?
    let hints: [String]
}

struct Quest {
    let title: String
    let steps: [QuestPoint]
}

class QuestListViewController: UIViewController {
    
//    var event = EventDetailsTest()
    
    private var questPoints: [QuestPoint] = [
//        QuestPoint(title: "Начало экскурсии", description: "Добро пожаловать! Найдите первый объект: старинный фонтан на главной площади.", question: nil, options: nil, requiresStreetAnswer: true, correctAnswer: "Фонтан", hints: ["Рядом есть большая статуя", "Ищите в центре площади"]),
//        QuestPoint(title: "Старинная церковь", description: "В каком году была построена эта церковь?", question: "Выберите правильный год.", options: ["1820", "1850", "1900"], requiresStreetAnswer: false, correctAnswer: "1850", hints: ["Эта церковь была построена в 19 веке", "Она младше, чем 1900 год"]),
//        QuestPoint(title: "Памятник", description: "Какой герой изображён на памятнике?", question: nil, options: nil, requiresStreetAnswer: true, correctAnswer: "Петр 1", hints: ["Этот человек был первым императором России", "Он известен как реформатор"]),
//        QuestPoint(title: "Парк в центре города", description: "Сколько деревьев растёт в этом парке?", question: "Выберите правильный ответ.", options: ["50", "100", "150"], requiresStreetAnswer: false, correctAnswer: "100", hints: ["Это больше, чем 50", "Меньше 150"]),
//        QuestPoint(title: "Мост через реку", description: "Какое его название?", question: nil, options: nil, requiresStreetAnswer: true, correctAnswer: "Мост Дружбы", hints: ["Его название символизирует объединение", "Он соединяет два берега реки"])
    ]
    
    private var currentPointIndex: Int = 0
    private var isCorrectAnswer = false
    private var currentHintIndex = 0
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let backButton = UIButton()
    private let titleLabelTop = UILabel()
    var event: EventDetailsTest?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите ответ здесь"
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        textField.isHidden = true
        return textField
    }()
    
    private let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.isHidden = true
        return stackView
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemRed
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    private let revealAnswerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "questionmark.square"), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Продолжить", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getQuest(questID: event?.eventQuestId ?? "") { [weak self] quest in
            guard let self = self, let quest = quest else {
                print("Failed to load quest.")
                return
            }

            DispatchQueue.main.async {
                self.titleLabel.text = quest.title
                self.questPoints = quest.steps
                self.updateUI(for: self.questPoints.first ?? QuestPoint(title: "", description: "", question: nil, options: nil, requiresStreetAnswer: false, correctAnswer: nil, hints: []))
            }
        }
//        updateUI(for: questPoints[currentPointIndex])
    }
    
//    func getQuest() {
//        let ref = Database.database().reference().child("quests/\(event?.eventQuestId ?? "")")
//        
//        ref.observeSingleEvent(of: .value) { snapshot in
//            guard let data = snapshot.value as? [[String: Any]] else { return }
//            
//            self.questPoints = data.compactMap { dict in
//                guard
//                    let title = dict["title"] as? String,
//                    let description = dict["description"] as? String,
//                    let hints = dict["hints"] as? [String]
//                else { return nil }
//                
//                let question = dict["question"] as? String
//                let options = dict["options"] as? [String]
//                let requiresStreetAnswer = dict["requiresStreetAnswer"] as? Bool ?? false
//                let correctAnswer = dict["correctAnswer"] as? String
//                
//                return QuestPoint(
//                    title: title,
//                    description: description,
//                    question: question,
//                    options: options,
//                    requiresStreetAnswer: requiresStreetAnswer,
//                    correctAnswer: correctAnswer,
//                    hints: hints
//                )
//            }
//            
//            if !self.questPoints.isEmpty {
//                self.updateUI(for: self.questPoints[self.currentPointIndex])
//            }
//        }
//    }
    
    func getQuest(questID: String, completion: @escaping (Quest?) -> Void) {
        let ref = Database.database().reference().child("quests").child(questID)

        ref.observeSingleEvent(of: .value) { snapshot in
            guard let questData = snapshot.value as? [String: Any],
                  let title = questData["title"] as? String,
                  let stepsData = questData["steps"] as? [[String: Any]] else {
                completion(nil)
                return
            }

            let steps = stepsData.compactMap { stepData -> QuestPoint? in
                guard let title = stepData["title"] as? String,
                      let description = stepData["description"] as? String,
                      let question = stepData["question"] as? String?,
                      let options = stepData["options"] as? [String]?,
                      let correctAnswer = stepData["correctAnswer"] as? String?,
                      let requiresStreetAnswer = stepData["requiresStreetAnswer"] as? Bool,
                      let hints = stepData["hints"] as? [String] else {
                    return nil
                }

                return QuestPoint(
                    title: title,
                    description: description,
                    question: question,
                    options: options,
                    requiresStreetAnswer: requiresStreetAnswer,
                    correctAnswer: correctAnswer,
                    hints: hints
                )
            }

            let quest = Quest(title: title, steps: steps)
            completion(quest)

        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        backButton.backgroundColor = .clear
        backButton.setImage(UIImage(named: "navBackButton"), for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleLabelTop.text = "Квесты"
        titleLabelTop.textAlignment = .center
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        view.addSubview(backButton)
        view.addSubview(titleLabelTop)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(inputTextField)
        view.addSubview(optionsStackView)
        view.addSubview(hintLabel)
        view.addSubview(revealAnswerButton)
        view.addSubview(nextButton)
        
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(20)
        }
        
        titleLabelTop.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(120)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        inputTextField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        optionsStackView.snp.makeConstraints { make in
            make.top.equalTo(inputTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(optionsStackView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        revealAnswerButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-28)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(45)
            make.width.equalTo(45)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalTo(revealAnswerButton.snp.leading).offset(-20)
            make.height.equalTo(45)
        }
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        revealAnswerButton.addTarget(self, action: #selector(revealAnswerTapped), for: .touchUpInside)
        inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func updateUI(for questPoint: QuestPoint) {
        titleLabel.text = questPoint.title
        descriptionLabel.text = questPoint.description
        
        inputTextField.isHidden = questPoint.requiresStreetAnswer
        optionsStackView.isHidden = questPoint.options == nil
        
        inputTextField.text = ""
        hintLabel.text = ""
        currentHintIndex = 0
        isCorrectAnswer = false
        nextButton.isEnabled = true
        nextButton.backgroundColor = .systemGray
        
        if let options = questPoint.options {
            configureOptions(options)
        }
    }
    
    private func configureOptions(_ options: [String]) {
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .systemBackground
            button.layer.borderColor = UIColor.systemGray4.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .systemGray
            return
        }
        nextButton.isEnabled = true
        nextButton.backgroundColor = UIColor(named: "mainGreen")
    }
    
    @objc private func optionSelected(_ sender: UIButton) {
        guard let answer = sender.title(for: .normal) else { return }
        
        if answer == questPoints[currentPointIndex].correctAnswer {
            sender.layer.borderColor = UIColor.green.cgColor
            sender.layer.borderWidth = 1
            isCorrectAnswer = true
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor(named: "mainGreen")
            hintLabel.text = "Ответ правильный!"
            hintLabel.textColor = .systemGreen
        } else {
            sender.layer.borderColor = UIColor.red.cgColor
            sender.layer.borderWidth = 1
            hintLabel.text = "Неправильно. Попробуйте ещё раз."
            hintLabel.textColor = .systemRed
        }
    }
    
    @objc private func backButtonTapped() {
        let vc = EventViewController()
        vc.event = event
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc private func nextButtonTapped() {
        let answer = inputTextField.text
        let correctAnswer = questPoints[currentPointIndex].correctAnswer ?? "(нет ответа)"
        if answer == correctAnswer {
            isCorrectAnswer = true
        }
        if isCorrectAnswer {
            inputTextField.layer.borderColor = UIColor.lightGray.cgColor
            currentPointIndex += 1
            if currentPointIndex < questPoints.count {
                updateUI(for: questPoints[currentPointIndex])
            } else {
                showCompletionAlert()
            }
        } else {
            inputTextField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @objc private func revealAnswerTapped() {
        let currentPoint = questPoints[currentPointIndex]
        hintLabel.textColor = .systemOrange
        if currentHintIndex < currentPoint.hints.count {
            hintLabel.text = currentPoint.hints[currentHintIndex]
            currentHintIndex += 1
        } else {
            hintLabel.text = "Правильный ответ: \(currentPoint.correctAnswer ?? "Неизвестно")"
        }
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(title: "Квест завершен!", message: "Вы успешно прошли все этапы.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {
            UIAlertAction in
            self.backButtonTapped()
            print("OK Pressed")
        }
        alert.addAction(okAction)
        //           alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true, completion: nil)
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
