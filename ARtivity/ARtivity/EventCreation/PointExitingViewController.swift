import UIKit
import FirebaseAuth
import Firebase
import SnapKit
import CoreLocation
//import YandexMapsMobile
import AVFoundation
import PhotosUI

class PointExitingViewController: UIViewController {
    
    
    var post: EventsModel? = nil
    var postDetail: EventDetails?
    var pointInf = [PointDetail]()
    var filterName = String()
    var pointsArrayEvent = [String]()
    
    var topView = AppHeaderView()
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    private let mainView = UIView()
    private let pointName = UILabel()
    private let createMainText = UILabel()
    
    var tableView: UITableView!
    
    private var createPoint = UIButton()
    private var searchBar: UISearchBar!
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar = UISearchBar()
        searchBar.tintColor = UIColor(named: "mainGreen")
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(EventPointTableViewCell.self, forCellReuseIdentifier: "EventPointTableViewCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.backgroundColor = UIColor(named: "appBackground")
        
        if filterName == "" {
            searchBar.placeholder = "Найти"
        } else {
            searchBar.placeholder = filterName
        }
        self.setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPoints()
        makeConstraints()
    }
    
    func getPostDetails(completion: @escaping (_ posts: EventDetails) -> Void) {
        
        let ref = Database.database().reference().child("eventDetails").child(post?.id ?? "0")
        
        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPost = EventDetails()
            
            let lastPost = self.postDetail
            if let childSnapshot = snapshot as? DataSnapshot,
               let data = childSnapshot.value as? [String: Any],
               let post = EventDetails.parse(childSnapshot.key, data)
            {
                self.postDetail = post
            }
        })
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "appBackground")
        
        
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        
        topView.rightButton.isHidden = true
        topView.title.isHidden = true
        
        view.addSubview(createMainText)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(topView)
        view.addSubview(createPoint)
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        
        setupData()
        setupNoDataInf()
    }
    
    func makeConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        createMainText.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(createMainText.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(15)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setupNoDataInf() {
        
        createMainText.text = "Выбор точки экскурсии"
        
        pointName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        createMainText.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        createPoint.setTitle("Добавить точку", for: .normal)
        createPoint.setTitleColor(.black, for: .normal)
        createPoint.isUserInteractionEnabled = true
        createPoint.backgroundColor = UIColor(named: "mainGreen")
        createPoint.layer.cornerRadius = 14
        createPoint.addTarget(self, action: #selector(self.createPointButtonPressed), for: .touchUpInside)
    }
    
    func setupData() {
        pointName.text = post?.eventName
    }
    
    func getPoints() {
        
        let ref = Database.database().reference().child("points")
        
        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPoint = [PointDetail]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let post = PointDetail.parse(childSnapshot.key, data) {
                    self.pointInf.append(post)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    @objc func buttonProfileClicked()
    {
        if isLogin {
            print("already loged in")
        } else {
            let vc = AuthViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    
    @objc func buttonBackClicked() {
        let vc = EventCreationViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)
//    }
    
    @objc func createPointButtonPressed() {
        let vc = EventCreationViewController()
        vc.pointsArrayEvent = pointsArrayEvent
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func getFilteredData(searchedText: String = String()) {
        let filteredListData: [PointDetail] = pointInf.filter{ $0.name!.lowercased().contains(searchedText.lowercased()) }
        pointInf = filteredListData
        tableView.reloadData()
    }
}

extension PointExitingViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            pointInf.removeAll()
            getPoints()
        } else {
            getFilteredData(searchedText: searchBar.text ?? String())
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = String()
        pointInf.removeAll()
        getPoints()
    }
    
}

extension PointExitingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointInf.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventPointTableViewCell", for: indexPath) as! EventPointTableViewCell
        if pointInf.isEmpty == false {
            cell.set(point: pointInf[indexPath.row])
            cell.numberLabel.text = "\(indexPath.row + 1)"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EventCreationViewController()
        pointsArrayEvent.append(pointInf[indexPath.row].id!)
        vc.pointsArrayEvent = pointsArrayEvent
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.selectionStyle = .none
    }
}
