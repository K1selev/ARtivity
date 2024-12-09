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
import AVFoundation
import PhotosUI
import MapKit

class PointCreationViewController: UIViewController, UIScrollViewDelegate {
    
    var pointInf = [PointDetail]()
    var pointsArrayEvent = [String]()

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
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
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
    
    private var createPoint = UIButton()
    private var imageArray: [UIImage?] = []
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let ref = Database.database().reference()
    
    var imagesEvent: [UIImage] = []
    var nameEvent: String?
    var descrEvent: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        self.customAlert.addSubview(customAlertLabel)
        customAlertLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        pointNameTextView = CustomTextFieldCreate(placeholderText: "Название точки",
                                                  color: .white, nameText: "")
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
//        getPoints()
//        setupDataInf()
    }
    
    private func randomAlphanumericString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString = (0..<length).map { _ in String(letters.randomElement()!) }.reduce("", +)
        return randomString
    }
    
    private func setupMap(latitude: Double, longitude: Double) {
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(newRegion, animated: true)
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
         descriptionMainText,
         addressMainText,
         addressText,
         commentStackView,
         galeryMainText,
         imagesStackView,
         collectionViewPhotos,
         mapView].forEach {
            scrollView.addSubview($0)
        }
        
        
        customAlert.isHidden = true
        customAlert.layer.zPosition = 1000
        view.addSubview(customAlert)
        view.addSubview(topView)
        view.addSubview(createPoint)
        self.setupCollectionView()
        setupNoDataInf()
        let width = 300.0
        let height = descriptionText.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        self.makeConstraints(height: height)
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
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        
        addressMainText.snp.makeConstraints { make in
            make.top.equalTo(commentStackView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        addressText.snp.makeConstraints { make in
            make.top.equalTo(addressMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
        }
        

        galeryMainText.snp.makeConstraints { make in
            make.top.equalTo(addressText.snp.bottom).offset(15)
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
        
        customAlert.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(80)
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
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
//            print(mapView.mapWindow.map.mapObjects)
            addressText.text = adressPlace
//            mapView.mapWindow.map.mapObjects.clear()
            mapView.removeAnnotations(mapView.annotations)
            addPlacemarkOnMap(latitude: placemarkLocation.coordinate.latitude ?? 0.0, longitude: placemarkLocation.coordinate.longitude ?? 0.0, name: adressPlace)
            addressText.font = UIFont.systemFont(ofSize: 14)
            addressText.textColor = UIColor.black
            addressTextLatitude = placemarkLocation.coordinate.latitude
            addressTextLongitude = placemarkLocation.coordinate.longitude
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
        let vc = EventCreationViewController()
        vc.images = imagesEvent
        vc.eventNameT = nameEvent
        vc.commentTextView.text = descrEvent
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    @objc func createPointButtonPressed() {
        
        if
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
                self.pointsArrayEvent.append(success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.customAlert.isHidden = true
                    let vc = EventCreationViewController()
                    vc.images = self.imagesEvent
                    vc.eventNameT = self.nameEvent
                    vc.commentTextView.text = self.descrEvent
                    vc.pointsArrayEvent = self.pointsArrayEvent
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
            print(id)
            self.customAlert.isHidden = false
            self.images.removeAll()
            self.pointNameTextView.text = ""
            self.addressText.text = "Добавьте адрес"
            self.commentTextView.text = "Описание точки"
            self.addressTextLatitude = nil
            self.addressTextLongitude = nil
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.activityIndicator.startAnimating()
            self.activityIndicator.removeFromSuperview()
            self.createPoint.setTitle("Добавить точку", for: .normal)
        }
    }
    
    func addPlacemarkOnMap(latitude: Double, longitude: Double, name: String) {
        
        let annotation = MKPointAnnotation()
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude,
                                                                      longitude: longitude)
        annotation.coordinate = location
        annotation.title = name
        self.mapView.addAnnotation(annotation)
        self.setupMap(latitude: latitude, longitude: longitude)
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

extension PointCreationViewController: MKMapViewDelegate {
    
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
