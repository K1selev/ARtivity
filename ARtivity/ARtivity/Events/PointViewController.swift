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
import MapKit
import AVFoundation

class PointViewController: UIViewController, UIScrollViewDelegate{
    
    var pointInf: PointDetail?
    var post: EventDetailsTest? //EventsModel?
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
    
    
    private let playerMainText = UILabel()
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerObserver: Any?
    private var isPlaying = false

    // UI элементы
    private let playPauseButton = UIButton(type: .system)
    private let progressSlider = UISlider()
    private let rewindButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
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
    
//    private let urlText = UILabel()
//    private let urlMainText = UILabel()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.setupUI()
        self.setupAudioPlayer()
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
        
        let playImage = UIImage(systemName: "play.fill") // Иконка "Play"
        playPauseButton.setImage(playImage, for: .normal)
        playPauseButton.tintColor = .black
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        let rewindImage = UIImage(systemName: "gobackward.10")
        rewindButton.setImage(rewindImage, for: .normal)
        rewindButton.tintColor = .black
        rewindButton.addTarget(self, action: #selector(rewindTapped), for: .touchUpInside)
        let forwardImage = UIImage(systemName: "goforward.10")
        forwardButton.setImage(forwardImage, for: .normal)
        forwardButton.tintColor = .black
        forwardButton.addTarget(self, action: #selector(forwardTapped), for: .touchUpInside)
        
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.thumbTintColor = .white // Цвет "ползунка"
        progressSlider.minimumTrackTintColor = UIColor(named: "mainGreen") // Цвет для области до ползунка
        progressSlider.maximumTrackTintColor = .lightGray
        
        //        pointView2.addBlurToView()
        view.addSubview(scrollView)
        [imageViewPost,
         pointName,
         descriptionMainText,
         descriptionText,
         playerMainText,
         playPauseButton,
         rewindButton,
         forwardButton,
         progressSlider,
         
         galeryMainText,
         photoCollectionView,
         mapView
//         urlMainText,
//         urlText
        ].forEach {
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
        
//        mapView.mapWindow.map.move(
//            with: YMKCameraPosition(
//                target: YMKPoint(latitude: latitude,
//                                 longitude: longitude),
//                zoom: 13,
//                azimuth: 0,
//                tilt: 0
//            ),
//            animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0),
//            cameraCallback: nil)
//        mapView.mapWindow.map.logo.setAlignmentWith(YMKLogoAlignment(
//            horizontalAlignment: .left,
//            verticalAlignment: YMKLogoVerticalAlignment.bottom)
//        )
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(newRegion, animated: true)
        
        
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
        
        playerMainText.snp.makeConstraints { make in
            make.top.equalTo(descriptionText.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        rewindButton.snp.makeConstraints { make in
            make.top.equalTo(playerMainText.snp.bottom).offset(15)
            make.centerX.equalTo(view.snp.centerX).offset(-100)
            make.width.height.equalTo(50)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.top.equalTo(playerMainText.snp.bottom).offset(15)
            make.centerX.equalTo(view.snp.centerX)
            make.width.height.equalTo(50)
        }
        
        forwardButton.snp.makeConstraints { make in
            make.top.equalTo(playerMainText.snp.bottom).offset(15)
            make.centerX.equalTo(view.snp.centerX).offset(100)
            make.width.height.equalTo(50)
        }
        
        progressSlider.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(34)
            make.trailing.equalTo(view.snp.trailing).offset(-34)
            make.top.equalTo(playPauseButton.snp.bottom).offset(5)
        }
        
        galeryMainText.snp.makeConstraints { make in
            make.top.equalTo(progressSlider.snp.bottom).offset(15)
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
        
//        urlMainText.snp.makeConstraints { make in
//            make.top.equalTo(mapView.snp.bottom).offset(15)
//            make.leading.equalToSuperview().offset(34)
//            make.height.equalTo(20)
//        }
//        urlText.snp.makeConstraints { make in
//            make.top.equalTo(urlMainText.snp.bottom).offset(5)
//            make.leading.equalToSuperview().offset(34)
//            make.trailing.equalToSuperview().offset(-34)
//            make.height.equalTo(20)
//        }
        
    }
    
    func setupNoDataInf() {
        
        descriptionMainText.text = "Описание"
        galeryMainText.text = "Фотографии с мест экскурсии"
//        urlMainText.text = "Официальный сайт"
        playerMainText.text = "Аудиогид"
        
        pointName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        descriptionMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        galeryMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
//        urlMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        playerMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
//        urlText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        
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
//        urlText.text = pointInf?.urlNet
        
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
        if imageArray.count == pointInf?.photos?.count {
            self.setupCollectionView()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.setupCollectionView()
            }
        }
//        self.setupCollectionView()
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
            player?.pause()
            let vc = EventViewController()
            vc.event = post
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
        let heightView = 950 + descriptionText.bounds.size.height
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: heightView)
    }
    
    @objc func didTapGoNextButton() {
        player?.pause()
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
        player?.pause()
        // update user inf
        updateUserInfo()
        let vc = EventViewController()
        vc.event = post
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    func updateUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/\(uid)")
        databaseRef.observeSingleEvent(of: .value, with: { snapshot in
            let userProfile = snapshot.value as? [String: Any]
            print(userProfile)
            
            var events = [""]
            if let completedEvents = userProfile?["completedEvent"] as? [String] {
                events.remove(at: 0)
                for item in completedEvents {
                    events.append(item)
                }
            }
            if !events.contains(self.post?.eventId ?? "") {
                guard let event = self.post?.eventId else {
                    return
                }
                events.append(event)
            }
            
            let userObject = [
                "name": userProfile?["username"],
                "email": userProfile?["email"],
                "accountCompleted": true,
                "phone": "no number yet",
                "userEvents": "",
                "completedEvent": events,
                "isMaker": userProfile?["isMaker"],
            ] as [String: Any]

                databaseRef.setValue(userObject) { error, _ in
                    //                completion(error == nil)
                }
           //}
        // post?.eventId
    })
    }
    
    func addPlacemarkOnMap(latitude: Double, longitude: Double, name: String) {
        let annotation = MKPointAnnotation()
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude,
                                                                      longitude: longitude)
        annotation.coordinate = location
        annotation.title = name
        self.mapView.addAnnotation(annotation)
    }
    
    func setupAudioPlayer() {
        // URL аудиофайла (замените ссылкой на ваш файл)
        guard let url = URL(string: pointInf?.urlNet ?? "") else {
            print("Неверный URL")
            return
        }
        
        // Инициализация AVPlayerItem и AVPlayer
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Добавление наблюдателя для обновления интерфейса
        playerObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 100), queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(self?.playerItem?.duration ?? CMTime.zero)
            self?.updateSlider(currentTime: currentTime, duration: duration)
        }
    }

    @objc func playPauseTapped() {
        isPlaying.toggle() // Переключение состояния
        
        if isPlaying {
//            let text = "Привет! Это пример синтеза речи на Swift."
//            // Создание объекта для синтеза речи
//            let utterance = AVSpeechUtterance(string: text)
//            // Устанавливаем язык (например, русский)
//            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
//            // Устанавливаем скорость речи (0.0 - 1.0)
//            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
//            // Устанавливаем громкость (0.0 - 1.0)
//            utterance.volume = 1.0
//            // Запуск синтеза речи
            player?.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal) // Установить иконку Pause
        } else {
            player?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal) // Установить иконку Play
        }
    }
    
    @objc func rewindTapped() {
            guard let player = player else { return }
            let currentTime = CMTimeGetSeconds(player.currentTime())
            let newTime = max(currentTime - 10, 0) // Перемотка назад, минимальное время — 0
            player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
        }

        @objc func forwardTapped() {
            guard let player = player, let duration = player.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(player.currentTime())
            let totalTime = CMTimeGetSeconds(duration)
            let newTime = min(currentTime + 10, totalTime) // Перемотка вперед, максимальное время — длина трека
            player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
        }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let duration = CMTimeGetSeconds(playerItem?.duration ?? CMTime.zero)
        let newTime = Double(sender.value) * duration
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }

    func updateSlider(currentTime: Double, duration: Double) {
        guard duration > 0 else { return }
        progressSlider.value = Float(currentTime / duration)
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

extension PointViewController: MKMapViewDelegate {
    
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
}
