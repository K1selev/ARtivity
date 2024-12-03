//
//  PointCreationViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 16.11.2024.
//


import UIKit
import FirebaseAuth
import Firebase
import SnapKit
import CoreLocation
import YandexMapsMobile
import AVFoundation
import PhotosUI
import MapKit
//import MapKit

class PointCreationViewController: UIViewController, UIScrollViewDelegate {
    

    var post: EventsModel? = nil
    var postDetail: EventDetails?
    var pointInf = [PointDetail]()

    var topView = AppHeaderView()
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    private let mainView = UIView()
    private let pointName = UILabel()
    private let createMainText = UILabel()
    private let descriptionMainText = UILabel()
    private let descriptionText = UILabel()
    private let addressMainText = UILabel()
    private let galeryMainText = UILabel()
    private let galeryphotos = UIImageView()
    private let mapImage = UIImageView()
    private var map = YBaseMapView()
    lazy var mapView: YMKMapView! = {
        return map.mapView
    }()
    
    let activityIndicator = UIActivityIndicatorView()
    
    lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.white
        textView.text = "Описание точки"
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
    
    private var images: [UIImage] = [] {
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
    private var addressTextLatitude: Double? = nil
    private var addressTextLongitude: Double? = nil

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

    lazy var pointNameTextView = CustomTextFieldCreate()
    
    lazy var addressText: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.white
        textView.text = "Добавьте адрес"
        textView.textColor = UIColor.gray
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 12)
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.isScrollEnabled = false

        textView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(UIScreen.main.bounds.width - 68)
        }
        return textView
    }()
    
    private var createPoint = UIButton()
//    private var addPoint = UIButton()
    private var imageArray: [UIImage?] = []
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pointNameTextView = CustomTextFieldCreate(placeholderText: "Название точки",
                                     color: .white)
        self.setupUI()
        setupImagesMenu()
       
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
    
    private func randomAlphanumericString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString = (0..<length).map { _ in String(letters.randomElement()!) }.reduce("", +)
        return randomString
    }
    
    private func setupMap(latitude: Double, longitude: Double) {

        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: latitude,
                                 longitude: longitude),
                zoom: 12,
                azimuth: 0,
                tilt: 0
            ),
            animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0),
            cameraCallback: nil)
        mapView.mapWindow.map.logo.setAlignmentWith(YMKLogoAlignment(
            horizontalAlignment: .left,
            verticalAlignment: YMKLogoVerticalAlignment.bottom)
        )
    }
    
    func getPostDetails(completion: @escaping (_ posts: EventDetails) -> Void) {

        let ref = Database.database().reference().child("eventDetails").child(post?.id ?? "0")
        
        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPost = EventDetails()

            let lastPost = self.postDetail
                if let childSnapshot = snapshot as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let post = EventDetails.parse(childSnapshot.key, data)
//                   childSnapshot.key != lastPost?.eventId
                {
                    self.postDetail = post
                    self.setupDataInf()
                }
        })
    }


    private func setupUI() {
        view.backgroundColor = UIColor(named: "appBackground")
        scrollView.backgroundColor = .clear
        
        
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        
        topView.rightButton.isHidden = true
        topView.title.isHidden = true
        
        mapImage.image = UIImage(named: "mapPreview")
        
        view.addSubview(scrollView)
        [createMainText,
         pointNameTextView,
//         pointsMainText,
         descriptionMainText,
         addressMainText,
         addressText,
         commentStackView,
         galeryMainText,
         imagesStackView,
         collectionViewPhotos,
//         addPoint,
         mapView].forEach {
            scrollView.addSubview($0)
        }
//        scrollView.addSubview(tableView)
        view.addSubview(topView)
        view.addSubview(createPoint)
        
        setupData()
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
//        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        scrollView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        createPoint.snp.makeConstraints { make in
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
        
        pointNameTextView.snp.makeConstraints { make in
            make.top.equalTo(createMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        descriptionMainText.snp.makeConstraints { make in
            make.top.equalTo(pointNameTextView.snp.bottom).offset(10)
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
        
        
        addressMainText.snp.makeConstraints { make in
            make.top.equalTo(commentStackView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        addressText.snp.makeConstraints { make in
            make.top.equalTo(addressMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
//            make.height.equalTo(20)
        }
        

        galeryMainText.snp.makeConstraints { make in
            make.top.equalTo(addressText.snp.bottom).offset(15)
//            make.bottom.equalTo(photoCollectionView.snp.top).offset(-15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }

        imagesStackView.snp.makeConstraints { make in
            make.top.equalTo(galeryMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(80)
        }
        
        
        collectionViewPhotos.snp.makeConstraints { make in
            make.top.equalTo(galeryMainText.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(74)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(80)
        }


        mapView.snp.makeConstraints { make in
            make.top.equalTo(imagesStackView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(243)
        }

    }

    func setupNoDataInf() {
        
        createMainText.text = "Создание точки"
        descriptionMainText.text = "Описание"
        galeryMainText.text = "Фотографии точки экскурсии"
        addressMainText.text = "Адрес точки на карте"
        
        pointName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        createMainText.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        descriptionMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        addressMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        addressText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        galeryMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        addressText.addTapGestureRecognizer {
            self.alertAddAdress(title: "Добавить", placeholder: "Введите адрес") { [self] (text) in
                print(text)
                setupPlacemark(adressPlace: text)
            }
        }
        
        descriptionText.numberOfLines = 0
        
        createPoint.setTitle("Добавить точку", for: .normal)
        createPoint.setTitleColor(.black, for: .normal)
        createPoint.isUserInteractionEnabled = true
        createPoint.backgroundColor = UIColor(named: "mainGreen")
        createPoint.layer.cornerRadius = 14
        createPoint.addTarget(self, action: #selector(self.createPointButtonPressed), for: .touchUpInside)
    }
    
    func setupDataInf() {
        descriptionText.text = postDetail?.description
        
        let width = 300.0
        let height = descriptionText.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        
        for images in postDetail?.eventPhotos ?? [] {
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
        
        self.makeConstraints(height: height)
    }

    func setupData() {
        pointName.text = post?.eventName
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
    
    private func setupPlacemark(adressPlace: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in
            
            
            if let error = error {
                print(error)
//                alerError(title: "Ошибка", message: "Сервер недоступен. Попробуйте добавить адрес еще раз")
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            print(mapView.mapWindow.map.mapObjects)
            addressText.text = adressPlace
            mapView.mapWindow.map.mapObjects.clear()
            addPlacemarkOnMap(latitude: placemarkLocation.coordinate.latitude ?? 0.0, longitude: placemarkLocation.coordinate.longitude ?? 0.0, name: adressPlace)
            addressText.font = UIFont.systemFont(ofSize: 14)
            addressText.textColor = UIColor.black
            addressTextLatitude = placemarkLocation.coordinate.latitude
            addressTextLongitude = placemarkLocation.coordinate.longitude
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
                    guard let pointDetail = self.postDetail?.eventPoints else { return }
                    for item in pointDetail {
                        if item == pointId {
                            tempPoint.insert(post, at: 0)
                            self.pointInf.append(post)
                            if self.isLogin {
                                self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                                if post.isFirstPoint ?? false {
                                    self.setupMap(latitude:post.latitude ?? 0.0, longitude: post.longitude ?? 0.0)
//                                    self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                                }
                            } else {
                                if post.isFirstPoint ?? false {
                                    self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                                }
                            }
                        }
                    }
                }
            }
//            self.tableView.reloadData()
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
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return post?.eventPoint ?? 1
        case 1:
            return 0
        default:
            return 0
        }
    }
    
    @objc func createPointButtonPressed() {
        
        if
//            !pointInf.isEmpty &&
            pointNameTextView.text != "" &&
            commentTextView.text != "Описание точки" &&
            addressText.text != "Добавьте адрес" {
            print(pointInf)
            self.uploadData()
            print("create")
            activityIndicator.color = .black
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            createPoint.addSubview(activityIndicator)
            activityIndicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            activityIndicator.startAnimating()
            createPoint.setTitle("", for: .normal)
        }
    }
    
    private func uploadData() {
        StorageService.shared.uploadPostImages(self.images, imageCategory: "points") { urls in
            print(urls)
            let id = self.randomAlphanumericString(15)
//            { success in
            let data = PointDetail(id: id,
                                   address: self.addressText.text,
                                   description: self.commentTextView.text,
                                   isFirstPoint: false,
                                   latitude: self.addressTextLatitude,
                                   longitude: self.addressTextLongitude,
                                   name: self.pointNameTextView.text,
                                   photos: urls,
                                   urlNet: "")
            StorageService.shared.createNewPoint(data: data) { success in
                print(success)
            }
            self.images.removeAll()
            self.pointNameTextView.text = ""
            self.addressText.text = "Добавьте адрес"
            self.commentTextView.text = "Описание точки"
            self.addressTextLatitude = nil
            self.addressTextLongitude = nil
            self.mapView.mapWindow.map.mapObjects.clear()
            self.activityIndicator.startAnimating()
            self.activityIndicator.removeFromSuperview()
            self.createPoint.setTitle("Добавить точку", for: .normal)
        }
    }
    
    func addPlacemarkOnMap(latitude: Double, longitude: Double, name: String) {
        let point = YMKPoint(latitude: latitude, longitude: longitude)
        let viewPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)
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
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: latitude,
                                 longitude: longitude),
                zoom: 12,
                azimuth: 0,
                tilt: 0
            ),
            animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0),
            cameraCallback: nil)
        viewPlacemark.userData = name
    }
    
    func alertAddAdress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        
        let alertController = UIAlertController(title:  title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in
            print("action")
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else {return}
            completionHandler(text)
        }
        
        alertController.addTextField { (tf) in
            tf.placeholder = placeholder
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { (_) in
        }
        
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
}


extension PointCreationViewController: UICollectionViewDataSource {
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
extension PointCreationViewController: UICollectionViewDelegateFlowLayout {
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

extension PointCreationViewController: PHPickerViewControllerDelegate {
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

extension PointCreationViewController: UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        self.images.append(image)
    }
}
