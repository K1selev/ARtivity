////
////  ProfileViewController.swift
////  ARtivity
////
////  Created by Сергей Киселев on 07.01.2024.
////
//
//import UIKit
//
//private let reuseIdentifier = "SettingsCell"
//
//class ProfileViewController: UIViewController {
//
//
//    var tableView: UITableView!
//    var userInfoHeader: UserInfoHeader!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//    }
//
//    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
//    return UIColor(
//    red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//    green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//    blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//    alpha: CGFloat(1.0)
//    )
//    }
//
//    func configureTableView() {
//        tableView = UITableView()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.rowHeight = 60
//
//        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
//        view.addSubview(tableView)
//        tableView.frame = view.frame
//
//        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
//        userInfoHeader = UserInfoHeader(frame: frame)
//        tableView.tableHeaderView = userInfoHeader
//        tableView.tableFooterView = UIView()
//    }
//
//    func configureUI() {
//        configureTableView()
//
//        navigationController?.navigationBar.barTintColor = UIColorFromRGB(rgbValue: 0x4680C2)
//        navigationItem.title = "Настройки"
//    }
//}
//
//extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return SettingsSection.allCases.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        guard let section = SettingsSection(rawValue: section) else { return 0 }
//
//
//        switch section {
//        case .Social:
//            return SocialOptions.allCases.count
//        case .Information:
//            return InformationOptions.allCases.count
//        case .Communications:
//            return CommunicationOptions.allCases.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = UIColorFromRGB(rgbValue: 0x4680C2)
//
//        print("Section is \(section)")
//
//        let title = UILabel()
//        title.font = UIFont.boldSystemFont(ofSize: 16)
//        title.textColor = .white
//        title.text = SettingsSection(rawValue: section)?.description
//        view.addSubview(title)
//        title.translatesAutoresizingMaskIntoConstraints = false
//        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
//
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
//        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
//
//        switch section {
//        case .Social:
//            let social = SocialOptions(rawValue: indexPath.row)
//            cell.sectionType = social
//        case .Information:
//            let information = InformationOptions(rawValue: indexPath.row)
//            cell.sectionType = information
//        case .Communications:
//            let communications = CommunicationOptions(rawValue: indexPath.row)
//            cell.sectionType = communications
//        }
//        return cell
//
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
//
//        switch section {
//        case .Social:
//            print(SocialOptions(rawValue: indexPath.row)?.description as Any)
//         case .Information:
//            print(InformationOptions(rawValue: indexPath.row)?.description as Any)
//        case .Communications:
//            print(CommunicationOptions(rawValue: indexPath.row)?.description as Any)
//        }
//    }
//}
//













import UIKit
import SnapKit
import MessageUI

private let reuseIdentifier = "SettingsCell"
private let imagePicker = UIImagePickerController()

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
    
    private let userInfoHeader = UserInfoHeader(frame: .zero)
    private var tableView = UITableView()
    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "navBackButton"), for: .normal)
        button.setTitle("", for: .normal)
        return button
    }()
    lazy var titleNav: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Профиль"
        return label
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
        configureUI()
//        userInfoHeader.configure(output.headerDisplayData)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        userInfoHeader.configure(output.headerDisplayData)
    }

    private func configureUI() {
        view.addSubview(userInfoHeader)
        view.addSubview(leftButton)
        view.addSubview(titleNav)
        
        leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        
        leftButton.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        titleNav.snp.makeConstraints { make in
            make.centerY.equalTo(leftButton.snp.centerY)
            make.centerX.equalToSuperview()
        }

        userInfoHeader.snp.makeConstraints { make in
            make.top.equalTo(leftButton.snp.bottom)
                .offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(65)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.userInfoHeader.snp.bottom)
                .offset(ProfileViewConstants.TableView.topOffset)
            make.leading.equalToSuperview()
                .offset(ProfileViewConstants.TableView.offset)
            make.trailing.equalToSuperview()
                .inset(ProfileViewConstants.TableView.offset)
            make.height.equalTo(ProfileViewConstants.TableView.height)
        }
    }

    private func configureTableView() {
        tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = ProfileViewConstants.TableView.rowHeight
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.contentInset.top = ProfileViewConstants.TableView.contentInsetTop
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = false

        tableView.subviews.forEach { view in
            view.layer.masksToBounds = false
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = ProfileViewConstants.Shadow.shadowRadius
            view.layer.shadowOpacity = ProfileViewConstants.Shadow.shadowOpacity
            view.layer.shadowColor = ProfileViewConstants.Shadow.shadowColor.cgColor
        }
    }

    private func setupTableViewHeader(section: Int) -> UIView {
        let view = UIView()
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .black
        title.text = SettingsSection(rawValue: section)?.description
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
                .offset(ProfileViewConstants.TableView.leftAnchor)
        }
        return view
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        SettingsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }

        switch section {
        case .Account:
            return AccountOptions.allCases.count
        case .Other:
            return OtherOptions.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        setupTableViewHeader(section: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        ProfileViewConstants.TableView.heightForHeader
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? SettingsCell
        cell?.selectionStyle = .none
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .Account:
            let account = AccountOptions(rawValue: indexPath.row)
            cell?.sectionType = account
        case .Other:
            let other = OtherOptions(rawValue: indexPath.row)
            cell?.sectionType = other
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }

        switch section {
        case .Account:
            switch AccountOptions(rawValue: indexPath.row)!.rawValue {
            case 0:
                present(PlugViewController(), animated: true) // Заглушка
//                print(TextConstantsProfile.titlePersonalData)
            case 1:
                present(PlugViewController(), animated: true) // Заглушка
//                print(TextConstantsProfile.titleAchievements)
            case 2:
                present(PlugViewController(), animated: true) // Заглушка
//                print(TextConstantsProfile.titleHistory)
            case 3:
                showMailComposer(message: "TextConstantsProfile.beGuideMessage")
            case 4:
//                if UserDefaults.standard.bool(forKey: UserKeys.isDarkMode.rawValue) == true {
//                    UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .light
//                    UserDefaults.standard.set(false, forKey: UserKeys.isDarkMode.rawValue)
//                } else {
//                    UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark
//                    UserDefaults.standard.set(true, forKey: UserKeys.isDarkMode.rawValue)
//                }
//                UserDefaults.standard.synchronize()
                print("changeTheme")
            default:
                print("no action")
            }
        case .Other:
            switch OtherOptions(rawValue: indexPath.row)!.rawValue {
            case 0:
                showMailComposer(message: "TextConstantsProfile.contactUsMessageTitle")
            case 1:
                if let url = URL(string: "https://pages.flycricket.io/progulki/privacy.html") {
                    UIApplication.shared.open(url)
                }
            case 2:
                let alert = UIAlertController(title: "Вы уверены, что хотите выйти?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Продолжить", style: .default, handler: { action in
                    self.goToLogin()
                }))
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)

            default:
                print("no action")
            }
        }
    }

    func goToLogin() {
        UserDefaults.standard.set(false, forKey: "isLogin")
        let vc = AuthViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc func buttonBackClicked() {
        let vc = EventsViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    func showMailComposer(message: String) {
        guard MFMailComposeViewController.canSendMail() else {
            print("can't send")
            return
        }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["TextConstantsProfile.contactUsMail]"])
        composer.setSubject(message)

        present(composer, animated: true)
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension ProfileViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Cancelled")
        case .failed:
            print("Failed to send")
        case .saved:
            print("Saved")
        case .sent:
            print("Email Sent")
        @unknown default:
            break
        }

        controller.dismiss(animated: true)
    }
}

// MARK: Здесь делаю аву пользователя

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

// extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//        }
//
//        imagePicker.dismiss(animated: true, completion: nil)
//    }
// }
