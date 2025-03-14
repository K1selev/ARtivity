//
//  EventsViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import UIKit
import SnapKit
import Firebase
import AVFoundation

var isMaker = 0
var tapCount = 0
var videoShown = false

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var searchBar: UISearchBar!
//    let searchBarController = UISearchController(searchResultsController: nil)
    private var filterCityBtn = UIButton()
    private var filterBtn = UIButton()
    private var filtersView = UIView()
    
    private let citiesTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemGray5.cgColor
        return tableView
    }()
    private let cities = ["Москва", "Санкт-Петербург", "Минск", "Киев", "Алматы", "Ташкент", "Бишкек", "Ереван", "Баку", "Астана", "Новосибирск", "Екатеринбург", "Казань", "Нижний Новгород", "Челябинск", "Самара", "Омск", "Ростов-на-Дону"
                      ]
    private var isTableViewVisible = false
    
    private let filterLabel = UILabel()
    private let filterDistanceLabel = UILabel()
    private var filterDistanceLessKMBtn = CustomChipsFilterButton()
    private var filterDistanceMoreKMLessThreeKMBtn = CustomChipsFilterButton()
    private var filterDistanceMoreThreeKMBtn = CustomChipsFilterButton()
    
    private let filterTimeLabel = UILabel()
    private var filterTimeLessHourBtn = CustomChipsFilterButton()
    private var filterTimeMoreHourLessThreeHourBtn = CustomChipsFilterButton()
    private var filterTimeMoreThreeHourBtn = CustomChipsFilterButton()
    
    var filterName = String()
    private var isSearch = false
    var topView = AppMainHeaderView()
    private var hasFetched = false
    var tableView: UITableView!
    var cellHeights: [IndexPath: CGFloat] = [:]
    var event = [EventDetailsTest]()
    let nothingLabel = UILabel()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching: CGFloat = 3.0
//    var refreshControl: UIRefreshControl!
    private let buttonNewPost = UIButton()
    var lastUploadedPostID: String?
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    
    private let buttonResetFilter = UIButton()
    private let buttonCreatePost = UIButton()
    
    var postsRef: DatabaseReference {
        return Database.database().reference().child("event")
    }

    var oldPostsQuery: DatabaseQuery {
        var queryRef: DatabaseQuery
        let lastPost = event.last
        if lastPost != nil {
            let lastTimestamp = (lastPost!.eventTimestamp?.timeIntervalSince1970)! * 1000
            queryRef = postsRef.queryOrdered(byChild: "eventTimestamp").queryEnding(atValue: lastTimestamp)
        } else {
            queryRef = postsRef//.queryOrdered(byChild: "eventTimestamp")
        }
        return queryRef
    }

    var newPostsQuery: DatabaseQuery {
        var queryRef: DatabaseQuery
        let firstPost = event.first
        if firstPost != nil {
            let firstTimestamp = (firstPost!.eventTimestamp?.timeIntervalSince1970 ?? 0) * 1000
            queryRef = postsRef.queryOrdered(byChild: "eventTimestamp").queryStarting(atValue: firstTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "eventTimestamp")
        }
        return queryRef
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.buttonCreatePost.isHidden = true
        self.buttonResetFilter.isHidden = true
        
        guard let user = Auth.auth().currentUser else { return}
        let ref = Database.database().reference()
        let userRef = ref.child("users").child(user.uid)
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let dictUserInfo = snapshot.value as? [String:AnyObject]
            let maker = dictUserInfo?["isMaker"]
            guard let makerNonOpt = maker else {
                return
            }
            isMaker = makerNonOpt as! Int
            if isMaker != 1 && self.isLogin {
                self.buttonCreatePost.isHidden = true
            } else {
                self.buttonCreatePost.isHidden = false
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "appBackground")
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(EventsTableViewCell.self, forCellReuseIdentifier: "EventsTableViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AdCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.backgroundColor = UIColor(named: "appBackground")
        searchBar = UISearchBar()
        
        filterLabel.textColor = UIColor(named: "mainGreen")
        filterLabel.font = .systemFont(ofSize: 20, weight: .bold)
        filterLabel.text = "Фильтры".uppercased()
        filterDistanceLabel.text = "Дистанция"
        filterDistanceLessKMBtn = CustomChipsFilterButton(title: "  < 1 км  ")
        filterDistanceLessKMBtn.addTarget(self,action:#selector(filterDistanceLessKMBtnClicked),
                                           for:.touchUpInside)
        filterDistanceMoreKMLessThreeKMBtn = CustomChipsFilterButton(title: "  > 1 км и < 3км  ")
        filterDistanceMoreKMLessThreeKMBtn.addTarget(self,action:#selector(filterDistanceMoreKMLessThreeKMBtnClicked),
                                           for:.touchUpInside)
        filterDistanceMoreThreeKMBtn = CustomChipsFilterButton(title: "  > 3 км  " )
        filterDistanceMoreThreeKMBtn.addTarget(self,action:#selector(filterDistanceMoreThreeKMBtnClicked),
                                           for:.touchUpInside)
        
        filterTimeLabel.text = "Продолжительность"
        filterTimeLessHourBtn = CustomChipsFilterButton(title: "  < 1 часа  ")
        filterTimeMoreHourLessThreeHourBtn = CustomChipsFilterButton(title: "  > 1 часа и < 3 часов  ")
        filterTimeMoreThreeHourBtn = CustomChipsFilterButton(title: "  > 3 часов  " )
        filterTimeLessHourBtn.addTarget(self,action:#selector(filterTimeLessHourBtnClicked),
                                        for:.touchUpInside)
        filterTimeMoreHourLessThreeHourBtn.addTarget(self,action:#selector(filterTimeMoreHourLessThreeHourBtnClicked),
                                                     for:.touchUpInside)
        filterTimeMoreThreeHourBtn.addTarget(self,action:#selector(filterTimeMoreThreeHourBtnClicked),
                                             for:.touchUpInside)
                
        buttonCreatePost.setTitle("", for: .normal)
        buttonCreatePost.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        buttonCreatePost.tintColor = UIColor(named: "mainGreen") ?? .green
//        buttonCreatePost.imageView?.contentMode = .scaleAspectFit
        buttonCreatePost.contentVerticalAlignment = .fill
        buttonCreatePost.contentHorizontalAlignment = .fill
        buttonCreatePost.addTarget(self,action:#selector(createPost),
                                    for:.touchUpInside)
        
        buttonResetFilter.setTitle("  Сбросить фильтры  ", for: .normal)
//        buttonResetFilter.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
//        buttonResetFilter.tintColor = UIColor(named: "mainGreen") ?? .green
        buttonResetFilter.setTitleColor(.white, for: .normal)
        buttonResetFilter.backgroundColor = UIColor(named: "mainGreen") ?? .green
        buttonResetFilter.contentVerticalAlignment = .fill
        buttonResetFilter.contentHorizontalAlignment = .fill
        buttonResetFilter.addTarget(self,action:#selector(resetFilter),
                                    for:.touchUpInside)
        buttonResetFilter.layer.cornerRadius = 12
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        citiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
        
        view.addSubview(topView)
        view.addSubview(tableView)
        view.addSubview(buttonNewPost)
        view.addSubview(searchBar)
//        view.addSubview(searchBarController.searchBar)
        view.addSubview(filterBtn)
        view.addSubview(filterCityBtn)
        view.addSubview(filtersView)
        view.addSubview(citiesTableView)
        view.addSubview(buttonCreatePost)
        view.addSubview(buttonResetFilter)
        
        [filterLabel,
         filterDistanceLabel,
         filterDistanceLessKMBtn,
         filterDistanceMoreKMLessThreeKMBtn,
         filterDistanceMoreThreeKMBtn,
         filterTimeLabel,
         filterTimeLessHourBtn,
         filterTimeMoreHourLessThreeHourBtn,
         filterTimeMoreThreeHourBtn
        ].forEach {
            filtersView.addSubview($0)
        }
        

        tableView.translatesAutoresizingMaskIntoConstraints = false

        makeConstraints()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.rowHeight = 370
        tableView.separatorStyle = .none

        buttonNewPost.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)

//        refreshControl = UIRefreshControl()
//        tableView.refreshControl = refreshControl
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        buttonNewPost.backgroundColor = .orange
        buttonNewPost.setTitle("new post", for: .normal)
        buttonNewPost.titleLabel?.textColor = .white
        buttonNewPost.layer.cornerRadius = 16
        buttonNewPost.isHidden = true
        
        topView.isUserInteractionEnabled = true
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        topView.leftButton.addTarget(self,action:#selector(buttonMapClicked),
                                     for:.touchUpInside)
        
        topView.title.addTarget(self,action:#selector(tapTitle),
                                 for:.touchUpInside)
        filterBtn.addTarget(self,action:#selector(tapFilter),
                            for:.touchUpInside)
        
        filterCityBtn.addTarget(self,action:#selector(toggleDropdownMenu),
                            for:.touchUpInside)
        
        beginBatchFetch()

        self.hideKeyboardWhenTappedAround()
        self.tableView.keyboardDismissMode = .onDrag
        
        searchBar.isHidden = true
        filterBtn.isHidden = true
        filterCityBtn.isHidden = true
        filtersView.isHidden = true
        filtersView.backgroundColor = UIColor(named: "appBackground")
        filterBtn.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        filterBtn.tintColor = UIColor(named: "mainGreen")
        filterCityBtn.setImage(UIImage(named: "navMapPoint"), for: .normal)
        filterCityBtn.tintColor = UIColor(named: "mainGreen")
        searchBar.tintColor = UIColor(named: "mainGreen")
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        if filterName == "" {
            searchBar.placeholder = "Найти"
        } else {
            searchBar.placeholder = filterName
        }
    }

    func makeConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        filterCityBtn.snp.makeConstraints { make in
            make.centerY.equalTo(searchBar.snp.centerY)
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(20)
        }
        
        citiesTableView.snp.makeConstraints { make in
            make.top.equalTo(filterCityBtn.snp.bottom).offset(10)
//            make.centerX.equalToSuperview()
            make.leading.equalTo(filterCityBtn.snp.leading)
            make.width.equalTo(200)
            make.height.equalTo(300)
        }


        searchBar.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.equalTo(filterCityBtn.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(40)
        }
        
        filterBtn.snp.makeConstraints { make in
            make.centerY.equalTo(searchBar.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(20)
        }
        
        filtersView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(250)
            make.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            if isSearch {
                make.top.equalTo(topView.snp.bottom).offset(50)
            } else {
                make.top.equalTo(topView.snp.bottom)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        buttonNewPost.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.centerX.equalToSuperview()
            make.height.equalTo(32)
            make.width.equalTo(150)
        }
        
        filterLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
        filterDistanceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.equalTo(filterLabel.snp.bottom).offset(10)
        }
        
        filterDistanceLessKMBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.equalTo(filterDistanceLabel.snp.bottom).offset(10)
        }
         filterDistanceMoreKMLessThreeKMBtn.snp.makeConstraints { make in
             make.centerX.equalToSuperview()
             make.top.equalTo(filterDistanceLabel.snp.bottom).offset(10)
         }
         filterDistanceMoreThreeKMBtn.snp.makeConstraints { make in
             make.trailing.equalToSuperview().inset(10)
             make.top.equalTo(filterDistanceLabel.snp.bottom).offset(10)
         }
        
        filterTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.equalTo(filterDistanceLessKMBtn.snp.bottom).offset(10)
        }
        filterTimeLessHourBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.equalTo(filterTimeLabel.snp.bottom).offset(10)
        }
        filterTimeMoreHourLessThreeHourBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(filterTimeLabel.snp.bottom).offset(10)
        }
        filterTimeMoreThreeHourBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.top.equalTo(filterTimeLabel.snp.bottom).offset(10)
        }
        buttonCreatePost.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(70)
            make.width.equalTo(70)
        }
        
        buttonResetFilter.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(50)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenForNewPosts()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopListeningForNewPosts()
    }

    func toggleSeeNewPostsButton(hidden: Bool) {
        if hidden {
            buttonNewPost.isHidden = true
        } else {
            buttonNewPost.isHidden = true
        }

    }
    
    @objc private func toggleDropdownMenu() {
//        resetFilter()
        isTableViewVisible.toggle()
        if !isTableViewVisible {
            beginBatchFetch()
        }
        citiesTableView.isHidden = !isTableViewVisible
    }


    @objc func handleRefresh() {
        print("Refresh!")

//        toggleSeeNewPostsButton(hidden: true)
//
//        newPostsQuery.queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { snapshot in
//
//            var tempPosts = [EventsModel]()
//
//            let firstPost = self.posts.first
//            for child in snapshot.children {
//                if let childSnapshot = child as? DataSnapshot,
//                   let data = childSnapshot.value as? [String: Any],
//                   let post = EventsModel.parse(childSnapshot.key, data),
//                   childSnapshot.key != firstPost?.eventId {
//
//                    tempPosts.insert(post, at: 0)
//                }
//            }
//
//            self.posts.insert(contentsOf: tempPosts, at: 0)
//
//            let newIndexPaths = (0..<tempPosts.count).map { i in
//                return IndexPath(row: i, section: 0)
//            }
//
//            self.refreshControl.endRefreshing()
//            self.tableView.insertRows(at: newIndexPaths, with: .top)
//            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//
//            self.listenForNewPosts()
//
//        })
//        posts.removeAll()
        beginBatchFetch()
//        self.refreshControl.endRefreshing()
    }

    func fetchPosts(completion: @escaping (_ postsTest: [EventDetailsTest]) -> Void) {

        oldPostsQuery.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [EventDetailsTest]()

            let lastPost = self.event.last
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let post = EventDetailsTest.parse(childSnapshot.key, data),
                   childSnapshot.key != lastPost?.eventId {

                    tempPosts.insert(post, at: 0)
                }
            }

            return completion(tempPosts)
        })
    }
    
    func showVideo(post: EventDetailsTest) {
        guard !videoShown else { return }
        videoShown = true
        let videoVC = WebViewController()
        videoVC.event = post
        videoVC.onFinish = {
            self.openNewPage(post: post)
        }
        videoVC.modalPresentationStyle = .fullScreen
        present(videoVC, animated: true)
    }
    
    func openNewPage(post: EventDetailsTest) {
        let webVC = WebViewController()
        webVC.event = post
        navigationController?.pushViewController(webVC, animated: true)
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            switch section {
            case 0:
                let adCount = event.count / tableViewAdsMinus
                return event.count + adCount
            case 1:
                return fetchingMore ? 1 : 0
            default:
                return 0
            }
        } else {
            return cities.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if indexPath.section == 0 {
                if isAdCell(at: indexPath.row) {
                    let adCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath)
                    configureAdImgCell(adCell, indexPath: indexPath)
                    return adCell
                    
                } else {
                    let dataIndex = getDataIndex(for: indexPath.row)
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EventsTableViewCell", for: indexPath) as! EventsTableViewCell
                    cell.set(post: event[dataIndex])
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
                cell.spinner.startAnimating()
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.text = cities[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if isAdCell(at: indexPath.row) {
            } else {
                let dataIndex = getDataIndex(for: indexPath.row)
                let post = event[dataIndex]
                print("SELECTED POST: \(post.eventId ?? "")")
                if event[dataIndex].eventIsFree ?? true {
                    tapCount += 1
                    if tapCount % tapBeforeShowVideo == 0 {
                        videoShown = false
                        showVideo(post: post)
                    }
                    let vc = EventViewController()
                    vc.event = post
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                } else {
                    let dataIndex = getDataIndex(for: indexPath.row)
                    let post = event[dataIndex]
                    videoShown = false
                    showVideo(post: post)
                }
            }
        } else {
            let selectedCity = cities[indexPath.row]
            isTableViewVisible = false
            citiesTableView.isHidden = true
            print("Selected city: \(selectedCity)")
            getFilteredCityData(searchedCity: selectedCity)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            cellHeights[indexPath] = cell.frame.size.height
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "appBackground")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {

            if !fetchingMore && !endReached {
                //                beginBatchFetch()
            }
        }
    }

    func beginBatchFetch() {
        fetchingMore = true
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        event.removeAll()
        
        fetchPosts { newPosts in
            self.event.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.isEmpty
            UIView.performWithoutAnimation {
                self.tableView.reloadData()

                self.listenForNewPosts()
            }
        }
    }
    
    private func isAdCell(at row: Int) -> Bool {
        return row % tableViewAds == tableViewAdsMinus
    }
    
    private func configureAdImgCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        removeOldImageView(from: cell)
        let adImages = ["ad_3", "ad_2", "ad_1"]
        let adImageView = UIImageView()
        adImageView.translatesAutoresizingMaskIntoConstraints = false
        adImageView.contentMode = .scaleAspectFill
        adImageView.clipsToBounds = true

        let imageIndex = indexPath.row / 3 % adImages.count
        adImageView.image = UIImage(named: adImages[imageIndex])

        cell.contentView.addSubview(adImageView)
        
        adImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        let adLabel = UILabel()
        adLabel.text = " Реклама  "
        adLabel.textColor = .white
        adLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        adLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        adLabel.textAlignment = .center
        adLabel.layer.cornerRadius = 4
        adLabel.clipsToBounds = true
        
        cell.contentView.addSubview(adLabel)
            adLabel.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-32)
                make.top.equalToSuperview().offset(8)
            }
    }
    
    private func removeOldImageView(from cell: UITableViewCell) {
        for subview in cell.contentView.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
    }

    
    private func getDataIndex(for row: Int) -> Int {
        return row - row / tableViewAds
    }

    var postListenerHandle: UInt?

    func listenForNewPosts() {

        guard !fetchingMore else { return }

        stopListeningForNewPosts()

        postListenerHandle = newPostsQuery.observe(.childAdded, with: { snapshot in

            if snapshot.key != self.event.first?.eventId,
               let data = snapshot.value as? [String: Any],
               let post = EventDetailsTest.parse(snapshot.key, data) {

                self.stopListeningForNewPosts()

                if snapshot.key == self.lastUploadedPostID {
                    self.handleRefresh()
                    self.lastUploadedPostID = nil
                } else {
                    self.toggleSeeNewPostsButton(hidden: false)
                }
            }
        })
    }

    func stopListeningForNewPosts() {
        if let handle = postListenerHandle {
            newPostsQuery.removeObserver(withHandle: handle)
            postListenerHandle = nil
        }
    }
    
    @objc func buttonMapClicked() {
        let vc = MapViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.posts = event
        present(vc, animated: true)
    }
    @objc func buttonProfileClicked() {
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            print("already loged in")
//            if isMaker != 1 {
                let vc = ProfileViewController()
                vc.events = event
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
//            } else {
//                print("here will be creation of exc!")
//            }
        } else {
            let vc = AuthViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    @objc func tapTitle() {
       print("open search")
        if isSearch {
            searchBar.isHidden = true
            filterBtn.isHidden = true
            filterCityBtn.isHidden = true
            filtersView.isHidden = true
            isSearch = false
        } else {
            searchBar.isHidden = false
            filterBtn.isHidden = false
            filterCityBtn.isHidden = false
//            filtersView.isHidden = false
            isSearch = true
        }
        tableView.snp.remakeConstraints { make in
            if isSearch {
                make.top.equalTo(topView.snp.bottom).offset(50)
            } else {
                make.top.equalTo(topView.snp.bottom)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func tapFilter() {
        if filtersView.isHidden {
            filtersView.isHidden = false
        } else {
            filtersView.isHidden = true
        }
    }
    
    @objc func filterDistanceLessKMBtnClicked() {
        buttonResetFilter.isHidden = false
        event = event.filter{ $0.eventDistance ?? 0 < 1000 }
        tableView.reloadData()
//        tapTitle()
        filtersView.isHidden = true
        buttonCreatePost.isHidden = true
    }
    
    @objc func filterDistanceMoreKMLessThreeKMBtnClicked() {
        buttonResetFilter.isHidden = false
        event = event.filter{ $0.eventDistance ?? 0 >= 1000 &&  $0.eventDistance ?? 0 <= 3000 }
        tableView.reloadData()
//        tapTitle()
        filtersView.isHidden = true
        buttonCreatePost.isHidden = true
    }
    
    @objc func filterDistanceMoreThreeKMBtnClicked() {
        buttonResetFilter.isHidden = false
        event = event.filter{ $0.eventDistance ?? 0 > 3000 }
        tableView.reloadData()
//        tapTitle()
        filtersView.isHidden = true
        buttonCreatePost.isHidden = true
    }
    
    @objc func filterTimeLessHourBtnClicked() {
        buttonResetFilter.isHidden = false
        event = event.filter{ $0.eventTime ?? 0 < 60 }
        tableView.reloadData()
//        tapTitle()
        filtersView.isHidden = true
        buttonCreatePost.isHidden = true
    }
    @objc func filterTimeMoreHourLessThreeHourBtnClicked() {
        buttonResetFilter.isHidden = false
        event = event.filter{ $0.eventTime ?? 0 >= 60 &&  $0.eventTime ?? 0 <= 180 }
        tableView.reloadData()
//        tapTitle()
        buttonCreatePost.isHidden = true
        filtersView.isHidden = true
    }
    @objc func filterTimeMoreThreeHourBtnClicked() {
        buttonResetFilter.isHidden = false
        event = event.filter{ $0.eventTime ?? 0 > 180 }
        tableView.reloadData()
//        tapTitle()
        filtersView.isHidden = true
        buttonCreatePost.isHidden = true
    }
    func getFilteredData(searchedText: String = String()) {
        buttonResetFilter.isHidden = false
        let filteredListData: [EventDetailsTest] = event.filter{ $0.eventName!.lowercased().contains(searchedText.lowercased()) }
        event = filteredListData
        tableView.reloadData()
        buttonCreatePost.isHidden = true
    }
    
    func getFilteredCityData(searchedCity: String = String()) {
        buttonResetFilter.isHidden = false
        let filteredListData: [EventDetailsTest] = event.filter{ $0.eventCity!.lowercased().contains(searchedCity.lowercased()) }
        event = filteredListData
        tableView.reloadData()
        buttonCreatePost.isHidden = true
    }
    
    @objc func createPost() {
        let vc = EventCreationViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @objc func resetFilter() {
        beginBatchFetch()
        tapTitle()
        toggleDropdownMenu()
        buttonResetFilter.isHidden = true
        buttonCreatePost.isHidden = false
    }
}

extension EventsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            beginBatchFetch()
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
        beginBatchFetch()
    }
    
}
