////
////  EventViewController.swift
////  ARtivity
////
////  Created by Сергей Киселев on 11.12.2023.
////
///
///

import UIKit
import FirebaseAuth
import Firebase
import SnapKit
import CoreLocation
import MapKit

class EventViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var event: EventDetailsTest?
    
    var pointInf = [PointDetail]()

    var topView = AppHeaderView()
    var tableView: UITableView!
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    private let imageViewPost = UIImageView()
    private let mainView = UIView()
    private let eventName = UILabel()
    private var timeLabel = UILabel()
    private var distanceLabel = UILabel()
    private var pointsLabel = UILabel()
    private let ratingImg = UIImageView()
    private let ratingText = UILabel()
    private let languageImage = UIImageView()
    private let cityLabelText = UILabel()
    private let ARImage = UIImageView()
    private let ARText = UILabel()
    private let lineView = UIView()
    private var lineView2 = UIView()
    private var lineView3 = UIView()
    private var lineView4 = UIView()
    private var lineView5 = UIView()
    private var lineView6 = UIView()
    private let pointsMainText = UILabel()
    
    private let pointNumber1 = UILabel()
    private let pointName1 = UILabel()
    private let pointDescription1 = UILabel()
    
    private let pointNumber2 = UILabel()
    private let pointName2 = UILabel()
    private let pointDescription2 = UILabel()
    private let pointNumber3 = UILabel()
    private let pointName3 = UILabel()
    private let pointDescription3 = UILabel()
    
    private let pointView1 = UIView()
    private let pointView2 = UIView()
    private let pointView3 = UIView()
    
    private let descriptionMainText = UILabel()
    private let descriptionText = UILabel()
    private let galeryMainText = UILabel()
    private let galeryphotos = UIImageView()
    private let mapImage = UIImageView()
    
    private let questButton = UIButton()
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private var goTripButton = UIButton()
    private var imageArray: [UIImage?] = []
    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        return collectionView
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        mapView.delegate = self
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.delegate = self
//        getPostDetails { posts in
//        }
        setupDataInf()
        getPoints()
    }
    
    private func setupMap(latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        currentMapLocation = location
//        currentZoom = 1 / pow(2, 1)
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(newRegion, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "appBackground")
        imageViewPost.backgroundColor = .systemGray5
        imageViewPost.layer.cornerRadius = 13
        scrollView.backgroundColor = .clear
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        
        mapImage.image = UIImage(named: "mapPreview")
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        if isLogin {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }

        tableView.backgroundColor = UIColor(named: "appBackground")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(EventPointTableViewCell.self, forCellReuseIdentifier: "EventPointTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.rowHeight = 60
//        tableView.separatorStyle = .none
        
        questButton.isHidden = true
        questButton.backgroundColor = .clear
        questButton.setImage(UIImage(named: "cameraIcon"), for: .normal)
        questButton.setTitle("", for: .normal)
        
        //MARK: it will be a simple tableViewCell

        
//        pointView2.addBlurToView()
        view.addSubview(scrollView)
                [imageViewPost,
                 eventName,
                 timeLabel,
                 distanceLabel,
                 pointsLabel,
                 ratingImg,
                 ratingText,
                 languageImage,
                 cityLabelText,
                 ARImage,
                 ARText,
                 lineView,
                lineView2,
                pointsMainText,
                lineView3,
                lineView6,
                 descriptionMainText,
                 descriptionText,
                 galeryMainText,
                 photoCollectionView,
                 mapView].forEach {
                    scrollView.addSubview($0)
                   }
        if isLogin {
            scrollView.addSubview(tableView)
        } else {
            [pointView1,
            lineView4,
            pointView2,
            lineView5,
            pointView3].forEach {
                scrollView.addSubview($0)
               }
        }
//        view.sendSubviewToBack(scrollView)
        view.addSubview(topView)
        view.addSubview(questButton)
        view.addSubview(goTripButton)
        
        distanceLabel.textAlignment = .center
        timeLabel.textAlignment = .center
        pointsLabel.textAlignment = .center
        
        loadImageView()
        setupData()
        setupNoDataInf()
    }
    
    private func setupCollectionView() {
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.showsHorizontalScrollIndicator = false
    }

    func makeConstraints(height: CGFloat, isQuest: Bool) {
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        if isQuest {
            questButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-28)
                make.bottom.equalToSuperview().offset(-40)
                make.height.equalTo(45)
                make.width.equalTo(45)
            }
            
            goTripButton.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-40)
                make.leading.equalToSuperview().offset(28)
                make.trailing.equalTo(questButton.snp.leading).offset(-20)
                make.height.equalTo(45)
            }
        } else {
            goTripButton.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-40)
                make.leading.equalToSuperview().offset(28)
                make.trailing.equalToSuperview().offset(-28)
                make.height.equalTo(45)
            }
        }
        
        imageViewPost.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(view.bounds.width)
            make.height.equalTo(300)
        }
        eventName.snp.makeConstraints { make in
            make.top.equalTo(imageViewPost.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        ratingImg.snp.makeConstraints { make in
            make.top.equalTo(eventName)
            make.leading.equalTo(eventName.snp.trailing).offset(5)
            make.width.height.equalTo(18)
        }
        ratingText.snp.makeConstraints { make in
            make.top.equalTo(eventName)
            make.leading.equalTo(ratingImg.snp.trailing).offset(5)
            make.height.equalTo(18)
        }
        
        languageImage.snp.makeConstraints { make in
            make.top.equalTo(eventName.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.width.height.equalTo(20)
        }
        cityLabelText.snp.makeConstraints { make in
            make.top.equalTo(languageImage)
            make.leading.equalTo(languageImage.snp.trailing).offset(15)
            make.height.equalTo(20)
        }
        
        ARImage.snp.makeConstraints { make in
            make.top.equalTo(languageImage.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.width.equalTo(20)
            make.height.equalTo(18)
        }
        ARText.snp.makeConstraints { make in
            make.top.equalTo(ARImage)
            make.leading.equalTo(ARImage.snp.trailing).offset(15)
            make.height.equalTo(20)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(ARImage.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.width.equalTo(view.bounds.width / 3)
            make.height.equalTo(16)
        }
        pointsLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.bounds.width / 3)
            make.height.equalTo(16)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.trailing.equalToSuperview()
            make.width.equalTo(view.bounds.width / 3)
            make.height.equalTo(16)
        }
        
        lineView2.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        pointsMainText.snp.makeConstraints { make in
            make.top.equalTo(lineView2.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        lineView3.snp.makeConstraints { make in
            make.top.equalTo(pointsMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        if isLogin {
            tableView.snp.makeConstraints { make in
                make.top.equalTo(lineView3.snp.bottom).offset(10)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(184)
            }
        } else {
            pointView1.snp.makeConstraints { make in
                make.top.equalTo(lineView3.snp.bottom)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(54)
            }
            
            lineView4.snp.makeConstraints { make in
                make.top.equalTo(pointView1.snp.bottom).offset(10)
                make.leading.equalToSuperview().offset(34)
                make.trailing.equalToSuperview().offset(-34)
                make.height.equalTo(1)
            }
            
            pointView2.snp.makeConstraints { make in
                make.top.equalTo(lineView4.snp.bottom)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(54)
            }
            
            lineView5.snp.makeConstraints { make in
                make.top.equalTo(pointView2.snp.bottom).offset(10)
                make.leading.equalToSuperview().offset(34)
                make.trailing.equalToSuperview().offset(-34)
                make.height.equalTo(1)
            }
            
            pointView3.snp.makeConstraints { make in
                make.top.equalTo(lineView5.snp.bottom)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(54)
            }
        }
        
        lineView6.snp.makeConstraints { make in
            if isLogin {
                make.top.equalTo(tableView.snp.bottom).offset(10)
                
            } else { make.top.equalTo(pointView3.snp.bottom).offset(10)
            }
//            make.bottom.equalTo(descriptionMainText.snp.top).offset(-10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }

        descriptionMainText.snp.makeConstraints { make in
            make.top.equalTo(lineView6.snp.bottom).offset(15)
//            make.bottom.equalTo(descriptionText.snp.top).offset(-10)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }

        descriptionText.snp.makeConstraints { make in
            make.top.equalTo(descriptionMainText.snp.bottom).offset(10)
//            make.bottom.equalTo(galeryMainText.snp.top).offset(-15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(height)
//            make.trailing.equalToSuperview().offset(-34)
        }

        galeryMainText.snp.makeConstraints { make in
            make.top.equalTo(descriptionText.snp.bottom).offset(15)
//            make.bottom.equalTo(photoCollectionView.snp.top).offset(-15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }

        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(galeryMainText.snp.bottom).offset(15)
//            make.bottom.equalTo(mapView.snp.top).offset(-15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(100)
        }

        mapView.snp.makeConstraints { make in
            make.top.equalTo(photoCollectionView.snp.bottom).offset(15)
//            make.bottom.equalTo(scrollView.snp.bottom).offset(-20)
//            make.bottom.equalToSuperview().offset(1150)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(243)
        }

    }

    func setupNoDataInf() {
        ratingImg.image = UIImage(named: "starIcon")
        languageImage.image = UIImage(named: "globeIcone")
        ARImage.image = UIImage(named: "cameraIcon")
        
        lineView.layer.borderWidth = 0.5
        lineView.layer.borderColor = UIColor.black.cgColor
        
        lineView2.layer.borderWidth = 0.5
        lineView2.layer.borderColor = UIColor.black.cgColor
        
        lineView3.layer.borderWidth = 0.5
        lineView3.layer.borderColor = UIColor.black.cgColor
        
        lineView4.layer.borderWidth = 0.5
        lineView4.layer.borderColor = UIColor.black.cgColor
        
        lineView5.layer.borderWidth = 0.5
        lineView5.layer.borderColor = UIColor.black.cgColor
        
        lineView6.layer.borderWidth = 0.5
        lineView6.layer.borderColor = UIColor.black.cgColor
        
        
        
        pointsMainText.text = "Точки экскурсии"
        descriptionMainText.text = "Описание"
        galeryMainText.text = "Фотографии с мест экскурсии"
        
        eventName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        cityLabelText.font = UIFont.systemFont(ofSize: 12.0)
        ARText.font = UIFont.systemFont(ofSize: 12.0)
        pointsMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        galeryMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        descriptionText.numberOfLines = 0
        
        goTripButton.setTitle("Отправиться на экскурсию", for: .normal)// = CustomButton(title: "Записаться")
        goTripButton.setTitleColor(.black, for: .normal)
        goTripButton.isUserInteractionEnabled = true
        goTripButton.backgroundColor = UIColor(named: "mainGreen")
        goTripButton.layer.cornerRadius = 14
        goTripButton.addTarget(self, action: #selector(self.goTripButtonPressed), for: .touchUpInside)
        
        
        questButton.setTitleColor(.black, for: .normal)
        questButton.isUserInteractionEnabled = true
        questButton.backgroundColor = UIColor(named: "mainGreen")
        questButton.layer.cornerRadius = 14
        questButton.addTarget(self, action: #selector(self.goQuestButtonPressed), for: .touchUpInside)
        
    }
    
    func setupDataInf() {
//        if event?.eventCity == "rus" {
            cityLabelText.text = event?.eventCity//"Русский язык экскурсии"
//        }
        let isQuest = event?.eventQuest
        
        if isQuest == true {
            ARText.text = "Проходите квесты по экскурсии"
        } else {
            ARText.text = "Квесты пока не доступны"
        }
        descriptionText.text = event?.description
        
        let width = 300.0
        let height = descriptionText.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        
        if isQuest == true {
            questButton.isHidden = false
        } else {
            questButton.isHidden = true
        }
        
        if isLogin {
            
        } else {
            setupPointView1()
            setupPointView2()
            setupPointView3()
        }
        
        for images in event?.eventPhotos ?? [] {
            if images != "" {
                let imagesUrl =  URL(string: (images))
                ImageService.getImage(withURL: imagesUrl!) { image, url in
                    if imagesUrl?.absoluteString == url.absoluteString {
                        self.imageArray.append(image)
//                        self.setupCollectionView()
                    }
                }
            }
        }
        if imageArray.count == event?.eventPhotos?.count {
            self.setupCollectionView()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.setupCollectionView()
            }
        }
        
        self.makeConstraints(height: height, isQuest: isQuest ?? false)
    }
    
    func setupPointView1() {
        
        let ref = Database.database().reference().child("points").child(event?.eventPoints?.first ?? "0")
        
        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPost = PointDetail()

            let lastPost = self.event
                if let childSnapshot = snapshot as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let point = PointDetail.parse(childSnapshot.key, data)
                {
                    self.pointName1.text = point.name
                    self.pointDescription1.text = point.address
                }
        })

        pointNumber1.text = "1"
        
        pointView1.addSubview(pointName1)
        pointView1.addSubview(pointNumber1)
        pointView1.addSubview(pointDescription1)
        
        pointNumber1.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.width.height.equalTo(20)
        }
        pointName1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(pointNumber1.snp.trailing).offset(20)
            make.height.equalTo(20)
        }
        pointDescription1.snp.makeConstraints { make in
            make.top.equalTo(pointName1.snp.bottom)
            make.leading.equalTo(pointName1)
            make.height.equalTo(20)
        }
        
        pointName1.font = UIFont.systemFont(ofSize: 14)
        pointDescription1.font = UIFont.systemFont(ofSize: 12, weight: .light)
    }
    
    func setupPointView2() {
        pointNumber2.text = ""
        pointName2.text = "___________________"
        
        pointNumber2.textColor = .black.withAlphaComponent(0.1)
        pointName2.textColor = .black.withAlphaComponent(0.1)
        pointDescription2.textColor = .black.withAlphaComponent(0.1)
        
        pointView2.addSubview(pointName2)
        pointView2.addSubview(pointNumber2)
        pointView2.addSubview(pointDescription2)
        
        pointNumber2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.width.height.equalTo(20)
        }
        pointName2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(pointNumber2.snp.trailing).offset(20)
            make.height.equalTo(20)
        }
        pointDescription2.snp.makeConstraints { make in
            make.top.equalTo(pointName2.snp.bottom)
            make.leading.equalTo(pointName2)
            make.height.equalTo(20)
        }
        
        pointName2.font = UIFont.systemFont(ofSize: 14)
        pointDescription2.font = UIFont.systemFont(ofSize: 12, weight: .light)
    }
    
    func setupPointView3() {
        
        let ref = Database.database().reference().child("points").child(event?.eventPoints?.last ?? "0")
        
        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPost = PointDetail()

            let lastPost = self.event
                if let childSnapshot = snapshot as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let point = PointDetail.parse(childSnapshot.key, data)
                {
                    
                    self.pointNumber3.text = "\(self.event?.eventPoints?.count ?? 3)"
                    self.pointName3.text = point.name
                    self.pointDescription3.text = point.address
                }
        })

        
        pointView3.addSubview(pointName3)
        pointView3.addSubview(pointNumber3)
        pointView3.addSubview(pointDescription3)
        
        pointNumber3.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.width.height.equalTo(20)
        }
        pointName3.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(pointNumber3.snp.trailing).offset(20)
            make.height.equalTo(20)
        }
        pointDescription3.snp.makeConstraints { make in
            make.top.equalTo(pointName3.snp.bottom)
            make.leading.equalTo(pointName3)
            make.height.equalTo(20)
        }
        
        pointName3.font = UIFont.systemFont(ofSize: 14)
        pointDescription3.font = UIFont.systemFont(ofSize: 12, weight: .light)
    }
    //MARK: кринжанул
    
    func loadImageView() {
        guard let img = event?.eventImage else { return }
        if let imageUrlTemp = event?.eventImage {
            if imageUrlTemp != "" {
                let imagesUrl =  URL(string: (imageUrlTemp))
//
//                self.imageViewPost.image = nil
                ImageService.getImage(withURL: imagesUrl!) { image, url in
                    if imagesUrl?.absoluteString == url.absoluteString {
                        self.imageViewPost.image = image
                        self.imageViewPost.clipsToBounds = true
//                    } else {
//                        print("Not the right image")
                    }
                }
            } else {
                self.imageViewPost.image = UIImage(systemName: "photo")
            }
        }
//        setupCollectionView()
    }

    func setupData() {
        ratingText.text = String(format: "%.2f",(event?.eventRating ?? 0.0)) //"\(event?.eventRating ?? 0.0)"
        eventName.text = event?.eventName
        if let distance = event?.eventDistance {
            let distanceText: String
            if distance >= 1000 {
                let distanceDouble = Double(distance)/1000.0
                distanceText = "\(String(format: "%.1f", distanceDouble)) км"
            } else {
                distanceText = "\(distance) м"
            }
            distanceLabel.text = distanceText
        }
        if let points = event?.eventPoints?.count {
            if points == 1 {
                pointsLabel.text = "\(points) точка"
            } else if points < 5 {
                pointsLabel.text = "\(points) точки"
            } else {
                pointsLabel.text = "\(points) точек"
            }
        }

        if let time = event?.eventTime {
            if time / 60 < 60 {
                timeLabel.text = "\(time / 60) минут"
            } else {
                timeLabel.text = "\(time/3600) часа"
            }
        }

    }
    
    func getPoints() {

        let ref = Database.database().reference().child("points")
        
        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPoint = [PointDetail]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let post = PointDetail.parse(childSnapshot.key, data) {
                    let pointId = childSnapshot.key
                    guard let pointDetail = self.event?.eventPoints else { return }
                    for item in pointDetail {
                        if item == pointId {
                            tempPoint.insert(post, at: 0)
                            self.pointInf.append(post)
                            if self.isLogin {
                                self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                                if post.isFirstPoint ?? false {
                                    self.setupMap(latitude:post.latitude ?? 0.0, longitude: post.longitude ?? 0.0)
                                }
                            } else {
                                if post.isFirstPoint ?? false {
                                    self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                                }
                            }
                        }
                    }
                    
                    let startLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.pointInf.first?.latitude ?? 0.0,
                                                                                       longitude: self.pointInf.first?.longitude ?? 0.0)
                    
                    let endLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.pointInf.last?.latitude ?? 0.0,
                                                                                     longitude: self.pointInf.last?.longitude ?? 0.0)
                    self.createRoute(from: startLocation, to: endLocation)
                }
            }
            self.tableView.reloadData()
        })
        if pointInf.isEmpty {
        }
    }
    
    func createRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let response = response, let route = response.routes.first else {
                if let error = error {
                    print("Error calculating route: \(error)")
                }
                return
            }
            
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let routeRect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(routeRect), animated: true)
            
            let distanceInMeters = route.distance
            print("Route distance: \(distanceInMeters) meters")
            
            let travelTimeInSeconds = route.expectedTravelTime
            print("Route expected travel time: \(travelTimeInSeconds) seconds")
        }
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
        let vc = EventsViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1300)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return event?.eventPoints?.count ?? 1
        case 1:
            return 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventPointTableViewCell", for: indexPath) as! EventPointTableViewCell
            if pointInf.isEmpty == false {
                cell.set(point: pointInf[indexPath.row])
                cell.numberLabel.text = "\(indexPath.row + 1)"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let point = pointInf[indexPath.row]
        print("SELECTED POINT: \(point.id ?? "")")
        let vc = PointViewController()
        vc.pointInf = point
        vc.pointInfo = pointInf
        vc.post = event
        vc.postItem = indexPath.row
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cellHeights[indexPath] = cell.frame.size.height
        cell.selectionStyle = .none
//        cell.backgroundColor =  .systemGray5
        //        cell.selectedBackgroundView?.backgroundColor = .blue// Asset.backgroungGray.color
    }
    
    @objc func goTripButtonPressed() {
        if isLogin {
            if !pointInf.isEmpty {
                let point = pointInf[0]
                let vc = PointViewController()
                vc.pointInf = point
                vc.pointInfo = pointInf
                vc.post = event
                vc.postItem = 0
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        } else {
            let vc = AuthViewController()
            present(vc, animated: true)
        }
    }
    
    @objc func goQuestButtonPressed() {
        let vc = QuestListViewController()
        vc.event = event
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func addPlacemarkOnMap(latitude: Double, longitude: Double, name: String) {
//        let point = YMKPoint(latitude: latitude, longitude: longitude)
//        let viewPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)
//        
//      // Настройка и добавление иконки
//        viewPlacemark.setIconWith(
//            UIImage(named: "map_search_result_primary")!,
//            style: YMKIconStyle(
//                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
//                rotationType: YMKRotationType.rotate.rawValue as NSNumber,
//                zIndex: 0,
//                flat: true,
//                visible: true,
//                scale: 1.5,
//                tappableArea: nil
//            )
//        )
//        viewPlacemark.userData = name
        let annotation = MKPointAnnotation()
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude,
                                                                      longitude: longitude)
        annotation.coordinate = location
        annotation.title = name
        self.mapView.addAnnotation(annotation)
//}
    }
}


extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell",
                                                          for: indexPath) as? PhotoCell,
            imageArray.count > indexPath.row - 1
        else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: imageArray[indexPath.row])
        
        return cell
        
    }
}

extension EventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}

extension EventViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {return nil }

        let annotationIdentifier = "CustomPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.image = UIImage(named: "map_search_result_primary")!
            imageView.contentMode = .scaleAspectFit
        }

        annotationView?.annotation = annotation
        annotationView?.image = UIImage(named: "map_search_result_primary")
        annotationView?.frame.size = CGSize(width: 30, height: 40)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor(named: "mainGreen")
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
