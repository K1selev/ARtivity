//
//  EventCreationViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 03.10.2024.
//


import UIKit
import FirebaseAuth
import Firebase
import SnapKit
import CoreLocation
import AVFoundation
import PhotosUI
import MapKit

class EventCreationViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    

//    var post: EventsModel? = nil
//    var postDetail: EventDetails?
    var pointsArrayEvent = [String]()
    var pointInf = [PointDetail]()
    var tableViewHeight = 0
    var eventTime = 0
    var eventDist = 0

    var topView = AppHeaderView()
    var tableView: UITableView!
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    private let mainView = UIView()
    private let eventName = UILabel()
    
    private let createMainText = UILabel()
    private let pointsMainText = UILabel()
    
    private let descriptionMainText = UILabel()
    private let descriptionText = UILabel()
    private let galeryMainText = UILabel()
    private let galeryphotos = UIImageView()
    private let mapImage = UIImageView()
    
    var eventNameT: String?
    
    let activityIndicator = UIActivityIndicatorView()
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.white
        textView.text = "Описание экскурсии"
//        textView.font = AppFont.bodyRegular
        textView.textColor = UIColor.gray
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 12)
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.isScrollEnabled = false

        textView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(86)
            make.width.equalTo(UIScreen.main.bounds.width - 68)
        }
        return textView
    }()
    
    var images: [UIImage] = [] {
        didSet {
            if images.isEmpty {
                addImagesLabel.isHidden = false
            } else {
                addImagesLabel.isHidden = true
                imagesErrorView.isHidden = true
            }
            self.setupImagesMenu()
            self.collectionViewPhotos.reloadData()
        }
    }
    let imagesErrorView = ErrorView(errorText: "")
    
    lazy var selectImagesButton = IconButton(
        icon: UIImage(systemName: "camera")!
    )
    
    lazy var imgTextStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [addImagesLabel,
                                                imagesErrorView])
        sv.spacing = 4
        sv.axis = .vertical
        sv.alignment = .leading
        return sv
    }()

    lazy var imagesStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [selectImagesButton,
                                                imgTextStackView])
        sv.spacing = 12
        sv.axis = .horizontal
        sv.alignment = .center
        return sv
    }()
    
    lazy var addImagesLabel: UILabel = {
        let label = UILabel()
//        label.font = AppFont.bodyRegular
        label.text = "Добавить фото"
        label.numberOfLines = 2
        return label
    }()
    
    lazy var collectionViewPhotos: UICollectionView = {
        let lay = UICollectionViewFlowLayout()
        lay.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect(), collectionViewLayout: lay)
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    let commentErroView = ErrorView(errorText: "")
    
    lazy var commentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [commentTextView,
                                                commentErroView])
        sv.spacing = 4
        sv.axis = .vertical
        sv.alignment = .leading
        return sv
    }()
    
    lazy var eventNameTextView = CustomTextFieldCreate()
    
    
    private let customAlertLabel: UILabel = {
        let label = UILabel()
        label.text = "Успешно добавлено"
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    private let customAlert: UIView = {
        let customAlertView = UIView()
        customAlertView.backgroundColor = UIColor(named: "mainGreen")
        customAlertView.layer.cornerRadius = 30
        return customAlertView
    }()
    
    private let customAlertLabelError: UILabel = {
        let label = UILabel()
        label.text = "Не добавлено"
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    private let customAlertSubLabelError: UILabel = {
        let label = UILabel()
        label.text = "Все поля должны быть заполнены"
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let customAlertError: UIView = {
        let customAlertView = UIView()
        customAlertView.backgroundColor = .red
        customAlertView.layer.cornerRadius = 30
        return customAlertView
    }()
    
    private var createEvent = UIButton()
    private var addPoint = UIButton()
    private var imageArray: [UIImage?] = []
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        createEvent.isUserInteractionEnabled = true
        topView.isUserInteractionEnabled = true
        
        self.customAlert.addSubview(customAlertLabel)
        customAlertLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.customAlertError.addSubview(customAlertLabelError)
        self.customAlertError.addSubview(customAlertSubLabelError)
        customAlertLabelError.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
        }
        customAlertSubLabelError.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(15)
        }
        
        
        
        if eventNameT != nil {
            eventNameTextView = CustomTextFieldCreate(placeholderText: "Название экскурсии",
                                                      color: .white, nameText: eventNameT ?? "")
        } else {
            eventNameTextView = CustomTextFieldCreate(placeholderText: "Название экскурсии",
                                                      color: .white, nameText: "")
        }
        
        self.setupUI()
        setupImagesMenu()
        setupAddPoints()
        mapView.delegate = self
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.delegate = self
        getPoints()
        setupDataInf()
    }
    
    private func setupMap(latitude: Double, longitude: Double, delta: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
        mapView.setRegion(newRegion, animated: true)
    }
    
//    func getPostDetails(completion: @escaping (_ posts: EventDetails) -> Void) {
//
//        let ref = Database.database().reference().child("eventDetails").child(post?.id ?? "0")
//        
//        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
//            var tempPost = EventDetails()
//
//            let lastPost = self.postDetail
//                if let childSnapshot = snapshot as? DataSnapshot,
//                   let data = childSnapshot.value as? [String: Any],
//                   let post = EventDetails.parse(childSnapshot.key, data)
////                   childSnapshot.key != lastPost?.eventId
//                {
//                    self.postDetail = post
//                    self.setupDataInf()
//                }
//        })
//    }


    private func setupUI() {
        view.backgroundColor = UIColor(named: "appBackground")
        scrollView.backgroundColor = .clear
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        
        mapImage.image = UIImage(named: "mapPreview")
        
        tableView = UITableView(frame: view.bounds, style: .plain)
//        if postDetail == nil {
//            tableView.isHidden = true
//        } else {
//            tableView.isHidden = false
//        }
        
        tableView.backgroundColor = UIColor(named: "appBackground")
        tableView.register(EventPointTableViewCell.self, forCellReuseIdentifier: "EventPointTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.rowHeight = 60
        tableView.isEditing = false
        tableView.isScrollEnabled = false
        
        view.addSubview(scrollView)
        [createMainText,
         eventNameTextView,
         pointsMainText,
         descriptionMainText,
         commentStackView,
         galeryMainText,
         imagesStackView,
         collectionViewPhotos,
         addPoint,
         mapView].forEach {
            scrollView.addSubview($0)
        }
        
        customAlert.isHidden = true
        customAlert.layer.zPosition = 1000
        view.addSubview(customAlert)
        
        
        customAlertError.isHidden = true
        customAlertError.layer.zPosition = 1000
        view.addSubview(customAlertError)
        
        scrollView.addSubview(tableView)
        view.addSubview(topView)
        view.addSubview(createEvent)
        
        setupNoDataInf()
    }
    
    private func setupCollectionView() {
        collectionViewPhotos.backgroundColor = .clear
        collectionViewPhotos.delegate = self
        collectionViewPhotos.dataSource = self
        collectionViewPhotos.register(cellType: SelectedImagesCell.self)
        collectionViewPhotos.showsHorizontalScrollIndicator = false
    }

    func makeConstraints(height: CGFloat) {
        
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
        
        createEvent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
            make.height.equalTo(45)
        }
        
        createMainText.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        eventNameTextView.snp.makeConstraints { make in
            make.top.equalTo(createMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        pointsMainText.snp.makeConstraints { make in
            make.top.equalTo(eventNameTextView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        customAlert.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(80)
        }
        
        customAlertError.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(80)
        }
        
        tableViewHeight = (pointsArrayEvent.count ?? 0) * 60
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(pointsMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(tableViewHeight)
        }
        
        addPoint.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        descriptionMainText.snp.makeConstraints { make in
            make.top.equalTo(addPoint.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }

        commentStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionMainText.snp.bottom).offset(10)
//            make.bottom.equalTo(galeryMainText.snp.top).offset(-15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
//            make.height.equalTo(height)
//            make.trailing.equalToSuperview().offset(-34)
        }

        galeryMainText.snp.makeConstraints { make in
            make.top.equalTo(commentStackView.snp.bottom).offset(15)
//            make.bottom.equalTo(photoCollectionView.snp.top).offset(-15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }

        imagesStackView.snp.makeConstraints { make in
            make.top.equalTo(galeryMainText.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(100)
        }
        
        
        collectionViewPhotos.snp.makeConstraints { make in
            make.top.equalTo(galeryMainText.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(74)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(100)
        }


        mapView.snp.makeConstraints { make in
            make.top.equalTo(imagesStackView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(243)
        }

    }

    func setupNoDataInf() {
        
        
        pointsMainText.text = "Точки экскурсии"
        createMainText.text = "Создание экскурсии"
        descriptionMainText.text = "Описание"
        galeryMainText.text = "Фотографии с мест экскурсии"
        
        eventName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        createMainText.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        pointsMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        galeryMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        descriptionText.numberOfLines = 0
        
        createEvent.setTitle("Сохранить экскурсию", for: .normal)// = CustomButton(title: "Записаться")
        createEvent.setTitleColor(.black, for: .normal)
        createEvent.isUserInteractionEnabled = true
        createEvent.backgroundColor = UIColor(named: "mainGreen")
        createEvent.layer.cornerRadius = 14
        createEvent.addTarget(self, action: #selector(self.createEventButtonPressed), for: .touchUpInside)
        
        addPoint.setTitle("", for: .normal)
        addPoint.setImage(UIImage(systemName: "plus"), for: .normal)
        addPoint.tintColor = UIColor.black
        addPoint.isUserInteractionEnabled = true
        
    }
    
    func setupDataInf() {
//        descriptionText.text = postDetail?.description
        
        let width = 300.0
        let height = descriptionText.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        self.makeConstraints(height: height)
        self.setupCollectionView()
    }

    private func setupImagesMenu() {
        print(images)
        if images.count < 5 {
            let cameraAction = UIAction(
                title: "Сделать фото",
                image: UIImage(systemName: "camera.on.rectangle"),
                handler: { _ in
                    self.presentCamera()
                })
            let galleryAction = UIAction(
                title: "Выбрать из галереи",
                image: UIImage(systemName: "photo.on.rectangle"),
                handler: { _ in
                    self.presentImagePicker()
                })
            self.selectImagesButton.showsMenuAsPrimaryAction = true
            self.selectImagesButton.menu = UIMenu(
                title: "",
                children: [cameraAction, galleryAction])
        } else {
            self.selectImagesButton.showsMenuAsPrimaryAction = false
            self.selectImagesButton.menu = nil
        }
    }
    
    private func setupAddPoints() {
        let cameraAction = UIAction(
            title: "Создать новую",
//            image: UIImage(systemName: "camera.on.rectangle"),
            handler: { _ in
                self.addButtonPressed()
            })
        let galleryAction = UIAction(
            title: "Выбрать существующую",
//            image: UIImage(systemName: "photo.on.rectangle"),
            handler: { _ in
                self.addExistingButtonPressed()
            })
        self.addPoint.showsMenuAsPrimaryAction = true
        self.addPoint.menu = UIMenu(
            title: "",
            children: [cameraAction, galleryAction])
    }

    private func presentCamera() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                DispatchQueue.main.async {
                    let vc = UIImagePickerController()
                    vc.sourceType = .camera
                    vc.allowsEditing = false
                    vc.delegate = self
                    self.present(vc, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.presentBottomPopup(text: "noAccesToCamera",
                                            image: UIImage(systemName: "camera")!,
                                            withBotButton: true)
                }
            }
        }
    }

    private func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        switch images.count {
        case 1:
            configuration.selectionLimit = 2
        case 2:
            configuration.selectionLimit = 1
        default:
            configuration.selectionLimit = 5
        }

        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true, completion: nil)
    }
    
    func getPoints() {
        let ref = Database.database().reference().child("points")
        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPoint = [PointDetail]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let post = PointDetail.parse(childSnapshot.key, data) {
                    if !self.pointsArrayEvent.isEmpty {
                        for itemPoint in self.pointsArrayEvent {
                            if itemPoint == post.id {
                                tempPoint.insert(post, at: 0)
                                self.pointInf.append(post)
                                if self.isLogin {
                                    self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                                    if post.isFirstPoint ?? false {
                                        self.setupMap(latitude:post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, delta: 1)
                                        self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                                    }
                                } else {
                                    if post.isFirstPoint ?? false {
                                        self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                                    }
                                }
                            }
                        }
                        if self.pointsArrayEvent.count >= 2 {
                            let startLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.pointInf.first?.latitude ?? 0.0,
                                                                                               longitude: self.pointInf.first?.longitude ?? 0.0)
                            
                            let endLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.pointInf.last?.latitude ?? 0.0,
                                                                                             longitude: self.pointInf.last?.longitude ?? 0.0)
                            self.createRoute(from: startLocation, to: endLocation)
                            
                        }
                    }
                }
            }
            if self.pointInf.isEmpty {
                self.tableView.isHidden = true
            } else {
                self.tableView.isHidden = false
            }
            self.tableView.reloadData()
            self.setupDataInf()
        })
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
            eventDist = Int(route.distance)
            print("Route distance: \(distanceInMeters) meters")
            
            let travelTimeInSeconds = route.expectedTravelTime
            eventTime = Int(route.expectedTravelTime)
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
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(tableViewHeight + 750))
    }

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
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = pointInf[sourceIndexPath.row]
        pointInf.remove(at: sourceIndexPath.row)
        pointInf.insert(item, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           print("Deleted")
           pointInf.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    @objc func createEventButtonPressed() {
        if eventNameTextView.text != "" &&
            commentTextView.text != "Описание экскурсии" &&
            pointInf.count >= 2 &&
            images.count != 0 {
            self.uploadData()
            print("create")
            createEvent.isUserInteractionEnabled = false
            topView.isUserInteractionEnabled = false
            activityIndicator.color = .black
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            createEvent.addSubview(activityIndicator)
            activityIndicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            createEvent.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        } else {
            print("not create")
            customAlertError.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.customAlertError.isHidden = true
            }
        }
    }
    
    private func uploadData() {
        StorageService.shared.uploadPostImages(self.images, imageCategory: "events") { urls in
            print(urls)
            var pointsArray = [""]
            for point in self.pointInf {
                pointsArray.append(point.id ?? "")
            }
            pointsArray.removeFirst()
            let id = self.randomAlphanumericString(15)
            let user = Auth.auth().currentUser
            let author = EventAuthorModel (authorId: user?.uid ?? "smbd", authorName: user?.displayName ?? "smbd")
            let data = EventDetailsTest(
                id: id,
                eventId: id,
                description: self.commentTextView.text,
                eventPoints: pointsArray,
                eventPhotos: urls,
                eventLanguage: "rus",
                eventAR: true,
                eventDistance: self.eventDist,
                eventImage: urls.first,
                eventName: self.eventNameTextView.text,
                eventPointCount: pointsArray.count,
                eventRating: 0.0,
                eventTime: self.eventTime,
                eventTimestamp: Date.now,
                eventAuthor: author
            )
            StorageService.shared.createNewEvent(data: data) { success in
                print(success)
                self.pointsArrayEvent.append(success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.customAlert.isHidden = true
                    let vc = EventsViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                self.createEvent.setTitle("Сохранить экскурсию", for: .normal)
            }
            print(id)
            self.customAlert.isHidden = false
//            self.images.removeAll()
//            self.pointNameTextView.text = ""
//            self.addressText.text = "Добавьте адрес"
//            self.commentTextView.text = "Описание точки"
//            self.addressTextLatitude = nil
//            self.addressTextLongitude = nil
//            self.mapView.removeAnnotations(self.mapView.annotations)
//            self.activityIndicator.startAnimating()
//            self.activityIndicator.removeFromSuperview()
//            self.createPoint.setTitle("Добавить точку", for: .normal)
        }
    }
    
    private func randomAlphanumericString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString = (0..<length).map { _ in String(letters.randomElement()!) }.reduce("", +)
        return randomString
    }
    
    @objc func addButtonPressed() {
        let vc = PointCreationViewController()
        vc.imagesEvent = images
        vc.nameEvent = eventNameTextView.text
        vc.descrEvent = commentTextView.text
        vc.pointsArrayEvent = pointsArrayEvent
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
        
//        let vc = RecordVC()
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }
    
    @objc func addExistingButtonPressed() {
        let vc = PointExitingViewController()
        vc.imagesEvent = images
        vc.nameEvent = eventNameTextView.text
        vc.descrEvent = commentTextView.text
        vc.pointsArrayEvent = pointsArrayEvent
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func addPlacemarkOnMap(latitude: Double, longitude: Double, name: String) {
        let annotation = MKPointAnnotation()
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude,
                                                                      longitude: longitude)
        annotation.coordinate = location
        annotation.title = name
        self.mapView.addAnnotation(annotation)
        self.setupMap(latitude: latitude, longitude: longitude, delta: 0.01)
    }
}


extension EventCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionViewPhotos.dequeueReusableCell(for: indexPath) as SelectedImagesCell
        cell.closeButton.addTapGestureRecognizer {
            self.images.remove(at: indexPath.item)
            self.collectionViewPhotos.reloadData()
        }
        cell.setup(image: images[indexPath.item])
        return cell
    }
}
extension EventCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 63, height: 63)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension EventCreationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, _) in
                DispatchQueue.main.async {
                    if let image = object as? UIImage {
                        self.images.append(image)
                    }
                }
            })
        }
    }
}

extension EventCreationViewController: UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        self.images.append(image)
    }
}

extension EventCreationViewController: MKMapViewDelegate {
    
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
