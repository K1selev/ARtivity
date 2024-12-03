////
////  SearchSuggestVC.swift
////  ARtivity
////
////  Created by Сергей Киселев on 18.11.2024.
////
//
//
//import UIKit
//import SnapKit
//import YandexMapsMobile
//
//enum SearchType {
//    case address
//    case city
//}
//
//class SearchSuggestVC: UIViewController {
//
//    var type: SearchType = .address
//
//    var locationPoint = YMKPoint()
//    var userLocation: String = ""
//    var currentAddress: String = ""
//    var addresses = [String]() {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
//    var cities: [String] = [] {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
//
//    var topView = AppHeaderView()
//
//    lazy var textField: CustomTextField = {
//        let tf = CustomTextField(placeholderText: "address",
//                                 color: .white,
//                                 security: false)
//        tf.layer.borderColor = UIColor.black.cgColor
//        tf.layer.borderWidth = 1.6
//
//        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: tf.frame.height))
//        tf.rightViewMode = .always
//        return tf
//    }()
//
//    lazy var crossButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = .clear
//        button.setImage(UIImage(systemName: "clear"), for: .normal)
//        button.setTitle("", for: .normal)
//        button.snp.makeConstraints { make in
//            make.height.width.equalTo(38)
//        }
//        return button
//    }()
//
//    lazy var locationButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = .clear
//        button.setImage(UIImage(named: "logo"), for: .normal)
//        button.setTitle("", for: .normal)
//        button.snp.makeConstraints { make in
//            make.height.width.equalTo(38)
//        }
//        return button
//    }()
//
//    private lazy var buttonsSV: UIStackView = {
//        let sv = UIStackView(arrangedSubviews: [crossButton,
//                                                locationButton])
//        sv.spacing = 7
//        sv.axis = .horizontal
//        sv.alignment = .leading
//        return sv
//    }()
//
//    lazy var collectionView: UICollectionView = {
//        let lay = UICollectionViewFlowLayout()
//        lay.scrollDirection = .vertical
//        let cv = UICollectionView(frame: CGRect(), collectionViewLayout: lay)
//        cv.showsHorizontalScrollIndicator = false
//        cv.showsVerticalScrollIndicator = false
//        cv.isScrollEnabled = true
//        cv.backgroundColor = .clear
//        return cv
//    }()
//
//    convenience init(currentAddress: String, currentLocation: (point: YMKPoint, address: String)) {
//        self.init()
//        self.currentAddress = currentAddress
//        self.userLocation = currentLocation.address
//        self.locationPoint = currentLocation.point
//
//        if currentLocation.address.isEmpty {
//            locationButton.isHidden = true
//        }
//    }
//
//    convenience init(selectedCity: String) {
//        self.init()
//        topView.title.text = "L10n.Settings.Profile.myCity"
//        textField.placeholder = "L10n.Settings.Profile.city"
//        currentAddress = selectedCity
//        type = .city
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupActions()
//        setupCollectionView()
//        setupTextField()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        textField.becomeFirstResponder()
////        if type == .address {
////            GeosuggestService.getSuggestResult(text: self.textField.text ?? "") { addresses in
////                self.addresses = addresses
////            }
////        } else {
////            GeosuggestService.getCitySuggestResult(text: currentAddress) { cities in
////                self.cities = cities
////            }
////        }
//    }
//
//    private func setupUI() {
//        view.backgroundColor = .white
//        if type == .city {
//            locationButton.isHidden = true
//            textField.text = currentAddress
//        }
//
//        view.addSubview(topView)
//        view.addSubview(textField)
//        textField.addSubview(buttonsSV)
//        view.addSubview(collectionView)
//
//        topView.snp.makeConstraints { make in
//            make.height.equalTo(48)
//            make.left.right.equalToSuperview().inset(4)
//            make.top.equalTo(view.safeAreaLayoutGuide)
//        }
//
//        textField.snp.makeConstraints { make in
//            make.top.equalTo(topView.snp.bottom).offset(6)
//            make.left.right.equalToSuperview().inset(16)
//        }
//
//        collectionView.snp.makeConstraints { make in
//            make.top.equalTo(textField.snp.bottom).offset(26)
//            make.left.right.equalToSuperview().inset(16)
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
//
//        buttonsSV.snp.makeConstraints { make in
//            make.right.equalToSuperview().inset(4)
//            make.centerY.equalToSuperview()
//        }
//    }
//
//    private func setupActions() {
//        topView.leftButton.addTapGestureRecognizer {
//            self.dismiss(animated: true)
//            self.navigationController?.popViewController(animated: true)
//        }
//
//        crossButton.addTapGestureRecognizer {
//            self.textField.text = ""
//        }
//
//        locationButton.addTapGestureRecognizer {
////            if !self.userLocation.isEmpty {
////                GeocoderService.getAddressFromPoint(latitude: self.locationPoint.latitude,
////                                                    longitude: self.locationPoint.longitude) { address in
////                    self.textField.text = address
////                    self.userLocation = address
////                    GeosuggestService.getSuggestResult(text: self.textField.text ?? "") { addresses in
////                        self.addresses = addresses
////                    }
////                }
////            } else {
////                self.presentBottomPopup(text: L10n.Popup.noAccesToGeo,
////                                        image: Asset.popupOrange.image,
////                                        withBotButton: false)
////            }
//        }
//    }
//
//    private func setupCollectionView() {
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(cellType: SearchSuggestCell.self)
//    }
//
//    private func setupTextField() {
//        textField.text = currentAddress
//        textField.delegate = self
//        textField.addTarget(self, action: #selector(textFieldDidChange(_:)),
//                                  for: .editingChanged)
//    }
//
//    @objc func textFieldDidChange(_ textField: UITextField) {
////        if type == .address {
//            GeosuggestService.getSuggestResult(text: textField.text ?? "") { addresses in
//                self.addresses = addresses
//            }
////        } else {
////            GeosuggestService.getCitySuggestResult(text: textField.text ?? "") { cities in
////                self.cities = cities
////            }
////        }
//    }
//
//    func dismissPopup(withData data: String) {
//        NotificationCenter.default.post(name: NotificationName.addressSelected, object: self, userInfo: ["data": data])
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    func dismissWhithCity(withData data: String) {
//        NotificationCenter.default.post(name: NotificationName.citySelected, object: self, userInfo: ["data": data])
//        self.navigationController?.popViewController(animated: true)
//    }
//}
//
//extension SearchSuggestVC: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//        if type == .address {
//            return addresses.count
//        } else {
//            return cities.count
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(for: indexPath) as SearchSuggestCell
//        if type == .address {
//            cell.setup(data: addresses[indexPath.row])
//        } else {
//            cell.setupCity(data: cities[indexPath.row])
//        }
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if type == .address {
//            self.dismissPopup(
//                withData: addresses[indexPath.row].title + ", " + addresses[indexPath.row].subtitle
//            )
//        } else {
//            self.dismissWhithCity(withData: cities[indexPath.row])
//        }
//     }
//
//}
//
//extension SearchSuggestVC: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 48)
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 4
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//}
//
//extension SearchSuggestVC: UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.changeTFState(state: .active)
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.changeTFState(state: .normal)
//    }
//}
