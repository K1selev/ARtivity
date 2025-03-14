////
////  CreateQuestViewController.swift
////  ARtivity
////
////  Created by Сергей Киселев on 24.01.2025.

import UIKit
import SnapKit
import Firebase

class CreateQuestViewController: UIViewController {
    
    private let titleLabelTop = UILabel()
    private let backButton = UIButton()
    var event = EventDetailsTest()
    var id = String()

    private var questTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название квеста"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private var stepTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название шага"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private var stepDescriptionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Описание шага"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private var hintTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Добавить подсказку"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private var firstHintTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Первая подсказка"
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.systemOrange.cgColor
        return textField
    }()

    private var secondHintTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Вторая подсказка"
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.systemOrange.cgColor
        return textField
    }()

    private var correctAnswerTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Правильный ответ"
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor(named: "mainGreen")?.cgColor
        
        return textField
    }()

    private var typeOfAnswerSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Текстовый ответ", "Выбор из вариантов"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private var optionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Вариант ответа"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private var hints: [String] = []
    private var options: [String] = []
    private var steps: [QuestPoint] = []
    
    private var requiresStreetAnswer: Bool = false // Эта переменная указывает, нужно ли отображать вариант выбора ответа

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    private let addHintOrAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить вариант ответа", for: .normal)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.backgroundColor = .systemBlue
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        
        return button
    }()

    private let addStepButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить шаг", for: .normal)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.backgroundColor = .systemOrange
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        
        return button
    }()

    private let saveQuestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить квест", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "mainGreen")
        button.layer.cornerRadius = 16
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        answerTypeChanged()
        view.backgroundColor = .systemBackground
        setupUI()
        tableView.dataSource = self

        addHintOrAnswerButton.addTarget(self, action: #selector(addHintOrAnswerTapped), for: .touchUpInside)
        addStepButton.addTarget(self, action: #selector(addStepTapped), for: .touchUpInside)
        saveQuestButton.addTarget(self, action: #selector(saveQuestTapped), for: .touchUpInside)
        
        typeOfAnswerSegmentedControl.addTarget(self, action: #selector(answerTypeChanged), for: .valueChanged)
    }

    private func setupUI() {
        titleLabelTop.text = "Квесты"
        titleLabelTop.textAlignment = .center
        
        backButton.backgroundColor = .clear
        backButton.setImage(UIImage(named: "navBackButton"), for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        view.addSubview(backButton)
        view.addSubview(titleLabelTop)
        view.addSubview(questTitleTextField)
        view.addSubview(stepTitleTextField)
        view.addSubview(stepDescriptionTextField)
        view.addSubview(typeOfAnswerSegmentedControl)
        view.addSubview(firstHintTextField)
        view.addSubview(secondHintTextField)
        view.addSubview(correctAnswerTextField)
        view.addSubview(optionTextField)
        view.addSubview(addHintOrAnswerButton)
        view.addSubview(saveQuestButton)
        view.addSubview(tableView)
        view.addSubview(addStepButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(20)
        }
        
        titleLabelTop.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
        
        questTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        stepTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(questTitleTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        stepDescriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(stepTitleTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        typeOfAnswerSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(stepDescriptionTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }

        firstHintTextField.snp.makeConstraints { make in
            make.top.equalTo(typeOfAnswerSegmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        secondHintTextField.snp.makeConstraints { make in
            make.top.equalTo(firstHintTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        correctAnswerTextField.snp.makeConstraints { make in
            make.top.equalTo(secondHintTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        optionTextField.snp.makeConstraints { make in
            make.top.equalTo(correctAnswerTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        addHintOrAnswerButton.snp.makeConstraints { make in
            make.top.equalTo(optionTextField.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
//            make.width.equalTo(200)
        }

        
        saveQuestButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        addStepButton.snp.makeConstraints { make in
            make.bottom.equalTo(saveQuestButton.snp.top).offset(-20)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(addHintOrAnswerButton.snp.bottom).offset(20)
            make.bottom.equalTo(saveQuestButton.snp.top).offset(-20)
            make.leading.trailing.equalToSuperview()
        }
    }

    @objc private func addHintOrAnswerTapped() {
        if requiresStreetAnswer {
            guard let option = optionTextField.text, !option.isEmpty else { return }

            options.append(option)
            if options.count > 4 {
                options = Array(options.prefix(4)) // Ограничиваем количество вариантов
            }

            if options.count == 4 {
                addHintOrAnswerButton.isEnabled = false
                addHintOrAnswerButton.backgroundColor = .gray
            }

            optionTextField.text = ""
        } else {
            guard let text = hintTextField.text, !text.isEmpty else { return }

            hints.append(text)
            if hints.count > 4 {
                hints = Array(hints.prefix(4))
            }

            if hints.count == 4 {
                addHintOrAnswerButton.isEnabled = false
                addHintOrAnswerButton.backgroundColor = .gray
            }

            hintTextField.text = ""
        }
    }

    @objc private func answerTypeChanged() {
        if typeOfAnswerSegmentedControl.selectedSegmentIndex == 0 {
            requiresStreetAnswer = false
            optionTextField.isHidden = true
            addHintOrAnswerButton.isHidden = true
        } else {
            addHintOrAnswerButton.isHidden = false
            requiresStreetAnswer = true // Выбор из вариантов
            optionTextField.isHidden = false // Показать поле для вариантов
            addHintOrAnswerButton.setTitle("Добавить вариант ответа", for: .normal)
        }
    }

    @objc private func addStepTapped() {
        guard
            let title = stepTitleTextField.text, !title.isEmpty,
            let description = stepDescriptionTextField.text, !description.isEmpty
        else {
            return
        }

        var question: String?
        var correctAnswer: String?

        if requiresStreetAnswer {
            // Вопрос с вариантами ответа
            if let correctText = correctAnswerTextField.text, !correctText.isEmpty {
                correctAnswer = correctText
            }

            question = "Выберите правильный вариант"
        } else {
            // Вопрос с текстовым ответом
            if let correctText = correctAnswerTextField.text, !correctText.isEmpty {
                correctAnswer = correctText
            }

            question = "Введите текстовый ответ"
        }
        
        let step = QuestPoint(
            title: title,
            description: description,
            question: question ?? "",
            options: requiresStreetAnswer ? options : [],
            requiresStreetAnswer: requiresStreetAnswer,
            correctAnswer: correctAnswer,
            hints: [firstHintTextField.text ?? "", secondHintTextField.text ?? ""]
        )

        steps.append(step)
        stepTitleTextField.text = ""
        stepDescriptionTextField.text = ""
        hintTextField.text = ""
        firstHintTextField.text = ""
        secondHintTextField.text = ""
        correctAnswerTextField.text = ""
        options.removeAll()
        addHintOrAnswerButton.setTitle("Добавить вариант ответа", for: .normal)
        addHintOrAnswerButton.isEnabled = true
        addHintOrAnswerButton.backgroundColor = .systemBlue
        tableView.reloadData()
    }
    @objc private func saveQuestTapped() {
        addStepTapped()
        guard let questTitle = questTitleTextField.text, !questTitle.isEmpty else {
            let alert = UIAlertController(title: "Невозможно создать квест", message: "Вы не добавили название вашего квеста", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
            return
        }
        
        if steps.isEmpty {
            let alert = UIAlertController(title: "Невозможно создать квест", message: "Вы не добавили ни одного шага", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        } else {
            let ref = Database.database().reference()
            let questData: [String: Any] = [
                "title": questTitle,
                "steps": steps.map { step in
                    [
                        "title": step.title,
                        "description": step.description,
                        "question": step.question ?? "",
                        "options": step.options ?? [],
                        "correctAnswer": step.correctAnswer ?? "",
                        "requiresStreetAnswer": step.requiresStreetAnswer,
                        "hints": step.hints
                    ] as [String: Any]
                }
            ]
            let newRef = ref.child("quests").childByAutoId()
            newRef.setValue(questData) { error, _ in
                if let error = error {
                    print("Error saving quest: \(error)")
                } else {
                    let generatedID = newRef.key
                    print("Quest successfully saved! ID: \(generatedID ?? "")")
                    self.updateEventInfo(generatedID: generatedID ?? "")
                    self.steps.removeAll()
                    self.tableView.reloadData()
                }
            }
        }
    }


    func updateEventInfo(generatedID: String) {
        let databaseRef = Database.database().reference().child("event/\(id)")
        databaseRef.observeSingleEvent(of: .value, with: { snapshot in
            self.event.eventQuest = true
            self.event.eventQuestId = generatedID
            databaseRef.setValue(self.event.representation) { error, _ in
                self.backButtonTapped()
            }
        })
    }

    @objc private func backButtonTapped() {
        let vc = EventsViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension CreateQuestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let step = steps[indexPath.row]
        cell.textLabel?.text = step.title
        return cell
    }
}
