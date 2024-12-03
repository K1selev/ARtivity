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
import YandexMapsMobile
import AVFoundation
import PhotosUI

class EventCreationViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    

    var post: EventsModel? = nil
    var postDetail: EventDetails?
    var pointsArrayEvent = [String]()
    var pointInf = [PointDetail]()
    var tableViewHeight = 0

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
    private var map = YBaseMapView()
    lazy var mapView: YMKMapView! = {
        return map.mapView
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
    
    
    lazy var eventNameTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.white
        textView.text = "Название экскурсии"
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
        self.setupUI()
        setupImagesMenu()
        setupAddPoints()
       
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
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        
        mapImage.image = UIImage(named: "mapPreview")
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        if postDetail == nil {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
        
        tableView.backgroundColor = UIColor(named: "appBackground")
        tableView.register(EventPointTableViewCell.self, forCellReuseIdentifier: "EventPointTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.rowHeight = 60
        tableView.isEditing = true
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
        scrollView.addSubview(tableView)
        view.addSubview(topView)
        view.addSubview(createEvent)
        
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
        
        tableViewHeight = (pointsArrayEvent.count ?? 0) * 60
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(pointsMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(tableViewHeight)
        }
        
        addPoint.snp.makeConstraints { make in
//            if self.pointsArray?.isEmpty ?? true {
//                make.top.equalTo(pointsMainText.snp.bottom).offset(10)
//            } else {
            make.top.equalTo(tableView.snp.bottom).offset(10)
//            }
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
        eventName.text = post?.eventName
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
                                        self.setupMap(latitude:post.latitude ?? 0.0, longitude: post.longitude ?? 0.0)
                                        self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
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
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }

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
//        cellHeights[indexPath] = cell.frame.size.height
        cell.selectionStyle = .none
//        cell.backgroundColor =  .systemGray5
        //        cell.selectedBackgroundView?.backgroundColor = .blue// Asset.backgroungGray.color
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
//        if pointInf.isEmpty {
//            print("empty points")
//        }
//        if eventNameTextView.text == "Название экскурсии" {
//            eventNameTextView.layer.borderColor = UIColor.red.cgColor
//            print("another name")
//        }
//        if eventNameTextView.text != "Название экскурсии" {
//            eventNameTextView.layer.borderColor = UIColor.lightGray.cgColor
//        }
//        if commentTextView.text == "Описание экскурсии" {
//            commentTextView.layer.borderColor = UIColor.red.cgColor
//            print("another comment")
//        }
//        if commentTextView.text != "Описание экскурсии" {
//            commentTextView.layer.borderColor = UIColor.lightGray.cgColor
//        }
//        if !pointInf.isEmpty &&
//            eventNameTextView.text != "Название экскурсии" &&
//            commentTextView.text != "Описание экскурсии" {
//            print(pointInf)
//            //            if canCreate {
//            
//            print("create")
//            //            }
//        }
        
        print("create")
        
    }
    
    @objc func addButtonPressed() {
        let vc = PointCreationViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func addExistingButtonPressed() {
        let vc = PointExitingViewController()
        vc.pointsArrayEvent = pointsArrayEvent
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
