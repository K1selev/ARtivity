//
//  PointViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.01.2024.
//

import UIKit
import FirebaseAuth
import Firebase
import SnapKit
import CoreLocation
import YandexMapsMobile

class PointViewController: UIViewController, UIScrollViewDelegate{
    
    var pointInf: PointDetail?
    var post: EventsModel?
    var postItem: Int?
    var pointInfo: [PointDetail]?
    
    var topView = AppHeaderView()
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    private let imageViewPost = UIImageView()
    private let mainView = UIView()
    private let pointName = UILabel()
    
    private let descriptionMainText = UILabel()
    private let descriptionText = UILabel()
    private let galeryMainText = UILabel()
    private let galeryphotos = UIImageView()
    private let mapImage = UIImageView()
    private var map = YBaseMapView()
    lazy var mapView: YMKMapView! = {
        return map.mapView
    }()
    
    private var goNextButton = UIButton()
    private var imageArray: [UIImage?] = []
    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        return collectionView
    }()
    
    private let urlText = UILabel()
    private let urlMainText = UILabel()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupDataInf()
        self.setupMap(latitude: pointInf?.latitude ?? 0.0, 
                      longitude: pointInf?.longitude ?? 0.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.delegate = self
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
        
        //        pointView2.addBlurToView()
        view.addSubview(scrollView)
        [imageViewPost,
         pointName,
         descriptionMainText,
         descriptionText,
         galeryMainText,
         photoCollectionView,
         mapView,
         urlMainText,
         urlText].forEach {
            scrollView.addSubview($0)
        }
        //        view.sendSubviewToBack(scrollView)
        view.addSubview(topView)
        view.addSubview(goNextButton)
        
        loadImageView()
        makeConstraints()
        setupNoDataInf()
    }
    
    private func setupMap(latitude: Double, longitude: Double) {
        
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: latitude,
                                 longitude: longitude),
                zoom: 13,
                azimuth: 0,
                tilt: 0
            ),
            animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0),
            cameraCallback: nil)
        mapView.mapWindow.map.logo.setAlignmentWith(YMKLogoAlignment(
            horizontalAlignment: .left,
            verticalAlignment: YMKLogoVerticalAlignment.bottom)
        )
        addPlacemarkOnMap(latitude: pointInf?.latitude ?? 0.0,
                          longitude:  pointInf?.longitude ?? 0.0,
                          name:  pointInf?.name ?? "smth")
//        mapView.mapWindow.map.addCameraListener(with: self)
//        mapView.mapWindow.map.addInputListener(with: self)
    }
    
    private func setupCollectionView() {
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func makeConstraints() {
        
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
        
        
        goNextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
            make.height.equalTo(45)
        }
        
        imageViewPost.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(view.bounds.width)
            make.height.equalTo(300)
        }
        pointName.snp.makeConstraints { make in
            make.top.equalTo(imageViewPost.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        descriptionMainText.snp.makeConstraints { make in
            make.top.equalTo(pointName.snp.bottom).offset(15)
            //            make.bottom.equalTo(descriptionText.snp.top).offset(-10)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        descriptionText.snp.makeConstraints { make in
            make.top.equalTo(descriptionMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        galeryMainText.snp.makeConstraints { make in
            make.top.equalTo(descriptionText.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(galeryMainText.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(100)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(photoCollectionView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(243)
        }
        
        urlMainText.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        urlText.snp.makeConstraints { make in
            make.top.equalTo(urlMainText.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(20)
        }
        
    }
    
    func setupNoDataInf() {
        
        descriptionMainText.text = "Описание"
        galeryMainText.text = "Фотографии с мест экскурсии"
        urlMainText.text = "Официальный сайт"
        
        pointName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        descriptionMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        galeryMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        urlMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        urlText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        
        descriptionText.numberOfLines = 0
        
        let pointsCount = pointInfo?.count ?? 0
//        goNextButton.setTitle("К следующей точке", for: .normal)// = CustomButton(title: "Записаться")
        goNextButton.setTitleColor(.black, for: .normal)
        goNextButton.isUserInteractionEnabled = true
        goNextButton.backgroundColor = UIColor(named: "mainGreen")
        goNextButton.layer.cornerRadius = 14
        if postItem ?? 0 < pointsCount - 1 {
            self.goNextButton.setTitle("К следующей точке", for: .normal)
            self.goNextButton.addTarget(self, action:  #selector(didTapGoNextButton), for: .touchUpInside)
        } else {
            self.goNextButton.setTitle("Закончить прогулку", for: .normal)
            
            self.goNextButton.addTarget(self, action:  #selector(didTapFinishButton), for: .touchUpInside)
        }
        
    }
    
    func setupDataInf() {
        
        pointName.text = pointInf?.name
        descriptionText.text = pointInf?.description
        urlText.text = pointInf?.urlNet
        
        for images in pointInf?.photos ?? [] {
            if images != "" {
                let imagesUrl =  URL(string: (images))
                ImageService.getImage(withURL: imagesUrl!) { image, url in
                    if imagesUrl?.absoluteString == url.absoluteString {
                        self.imageArray.append(image)
                    }
                }
            }
        }
        self.setupCollectionView()
    }
    
    
    func loadImageView() {
        guard let img = pointInf?.photos?.first else { return }
        if let imageUrlTemp = pointInf?.photos?.first {
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
        if postItem ?? 0 == 0 {
            let vc = EventViewController()
            vc.post = post
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        } else {
            postItem! -= 1
            let point = pointInfo?[postItem ?? 0]
            let vc = PointViewController()
            vc.pointInf = point
            vc.pointInfo = pointInfo
            vc.post = post
            vc.postItem = postItem
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let heightView = 910 + descriptionText.bounds.size.height
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: heightView)
    }
    
    @objc func didTapGoNextButton() {
        postItem! += 1
        let point = pointInfo?[postItem ?? 0]
        print("SELECTED POINT: \(point?.id ?? "")")
        let vc = PointViewController()
        vc.pointInf = point
        vc.pointInfo = pointInfo
        vc.post = post
        vc.postItem = postItem
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func didTapFinishButton() {
        let vc = EventViewController()
        vc.post = post
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    func addPlacemarkOnMap(latitude: Double, longitude: Double, name: String) {
        let point = YMKPoint(latitude: latitude, longitude: longitude)
        let viewPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)
        
      // Настройка и добавление иконки
        viewPlacemark.setIconWith(
            UIImage(named: "map_search_result_primary")!,
            style: YMKIconStyle(
                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 0,
                flat: true,
                visible: true,
                scale: 1.5,
                tappableArea: nil
            )
        )
        viewPlacemark.userData = name
    }
}


extension PointViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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

extension PointViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}

