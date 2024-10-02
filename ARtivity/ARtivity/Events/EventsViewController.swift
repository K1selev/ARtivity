//
//  EventsViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import UIKit
import SnapKit
import Firebase

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var searchBar: UISearchBar!
//    let searchBarController = UISearchController(searchResultsController: nil)
    private var filterBtn = UIButton()
    private var filtersView = UIView()
    
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
    var posts = [EventsModel]()
    let nothingLabel = UILabel()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching: CGFloat = 3.0
    var refreshControl: UIRefreshControl!
    private let buttonNewPost = UIButton()
    var lastUploadedPostID: String?
    var postsRef: DatabaseReference {
        return Database.database().reference().child("events")
    }

    var oldPostsQuery: DatabaseQuery {
        var queryRef: DatabaseQuery
        let lastPost = posts.last
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
        let firstPost = posts.first
        if firstPost != nil {
            let firstTimestamp = (firstPost!.eventTimestamp?.timeIntervalSince1970 ?? 0) * 1000
            queryRef = postsRef.queryOrdered(byChild: "eventTimestamp").queryStarting(atValue: firstTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "eventTimestamp")
        }
        return queryRef
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "appBackground")
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(EventsTableViewCell.self, forCellReuseIdentifier: "EventsTableViewCell")
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
        
        view.addSubview(topView)
        view.addSubview(tableView)
        view.addSubview(buttonNewPost)
        view.addSubview(searchBar)
//        view.addSubview(searchBarController.searchBar)
        view.addSubview(filterBtn)
        view.addSubview(filtersView)
        
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

        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

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
        
        beginBatchFetch()

        self.hideKeyboardWhenTappedAround()
        self.tableView.keyboardDismissMode = .onDrag
        
//        searchBarController.searchBar.delegate = self
////        searchBarController.obscuresBackgroundDuringPresentation = false
////        searchBarController.searchBar.sizeToFit()
//        searchBarController.searchBar.isHidden = true
//        searchBarController.searchBar.tintColor = UIColor(named: "mainGreen")
//        searchBarController.searchBar.backgroundImage = UIImage()
//        if filterName == "" {
//            searchBarController.searchBar.placeholder = "Найти"
//        } else {
//            searchBarController.searchBar.placeholder = filterName
//        }
        
        
        searchBar.isHidden = true
        filterBtn.isHidden = true
        filtersView.isHidden = true
        filtersView.backgroundColor = UIColor(named: "appBackground")
        filterBtn.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        filterBtn.tintColor = UIColor(named: "mainGreen")
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

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.equalToSuperview().inset(10)
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
        self.refreshControl.endRefreshing()
    }

    func fetchPosts(completion: @escaping (_ posts: [EventsModel]) -> Void) {

        oldPostsQuery.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [EventsModel]()

            let lastPost = self.posts.last
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let post = EventsModel.parse(childSnapshot.key, data),
                   childSnapshot.key != lastPost?.eventId {

                    tempPosts.insert(post, at: 0)
                }
            }

            return completion(tempPosts)
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return posts.count
        case 1:
            return fetchingMore ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventsTableViewCell", for: indexPath) as! EventsTableViewCell
            cell.set(post: posts[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        print("SELECTED POST: \(post.eventId ?? "")")
        let vc = EventViewController()
        vc.post = post
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "appBackground")
        //        cell.selectedBackgroundView?.backgroundColor = .blue// Asset.backgroungGray.color
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
        posts.removeAll()
        
        fetchPosts { newPosts in
            self.posts.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.isEmpty
            UIView.performWithoutAnimation {
                self.tableView.reloadData()

                self.listenForNewPosts()
            }
        }
    }

    var postListenerHandle: UInt?

    func listenForNewPosts() {

        guard !fetchingMore else { return }

        stopListeningForNewPosts()

        postListenerHandle = newPostsQuery.observe(.childAdded, with: { snapshot in

            if snapshot.key != self.posts.first?.eventId,
               let data = snapshot.value as? [String: Any],
               let post = EventsModel.parse(snapshot.key, data) {

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
        vc.posts = posts
        present(vc, animated: true)
    }
    @objc func buttonProfileClicked() {
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            print("already loged in")
            let vc = ProfileViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
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
            filtersView.isHidden = true
            isSearch = false
        } else {
            searchBar.isHidden = false
            filterBtn.isHidden = false
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
        posts = posts.filter{ $0.eventDistance ?? 0 < 1000 }
        tableView.reloadData()
        tapTitle()
        filtersView.isHidden = true
    }
    
    @objc func filterDistanceMoreKMLessThreeKMBtnClicked() {
        posts = posts.filter{ $0.eventDistance ?? 0 >= 1000 &&  $0.eventDistance ?? 0 <= 3000 }
        tableView.reloadData()
        tapTitle()
        filtersView.isHidden = true
    }
    
    @objc func filterDistanceMoreThreeKMBtnClicked() {
        posts = posts.filter{ $0.eventDistance ?? 0 > 3000 }
        tableView.reloadData()
        tapTitle()
        filtersView.isHidden = true
    }
    
    @objc func filterTimeLessHourBtnClicked() {
        posts = posts.filter{ $0.eventTime ?? 0 < 60 }
        tableView.reloadData()
        tapTitle()
        filtersView.isHidden = true
    }
    @objc func filterTimeMoreHourLessThreeHourBtnClicked() {
        posts = posts.filter{ $0.eventTime ?? 0 >= 60 &&  $0.eventTime ?? 0 <= 180 }
        tableView.reloadData()
        tapTitle()
        filtersView.isHidden = true
    }
    @objc func filterTimeMoreThreeHourBtnClicked() {
        posts = posts.filter{ $0.eventTime ?? 0 > 180 }
        tableView.reloadData()
        tapTitle()
        filtersView.isHidden = true
    }
    func getFilteredData(searchedText: String = String()) {
        let filteredListData: [EventsModel] = posts.filter{ $0.eventName!.lowercased().contains(searchedText.lowercased()) }
        posts = filteredListData
        tableView.reloadData()
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
