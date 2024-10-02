//
//  MapViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 22.12.2023.
//

import UIKit
import SnapKit
import YandexMapsMobile
import Firebase

enum MapType {
    case standard
    case creation
}

class MapViewController: UIViewController, YMKMapCameraListener, YMKMapInputListener {
    func onMapTap(with map: YMKMap, point: YMKPoint) {
        
    }
    
    func onMapLongTap(with map: YMKMap, point: YMKPoint) {
        
    }
    
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
        
        currentZoom = cameraPosition.zoom
        currentMapLocation = cameraPosition.target
        
    }
    
    
    var type: MapType = .standard
    private var isFirstRequest = true
    private var currentZoom: Float = 0
    private var currentMapLocation: YMKPoint = YMKPoint(latitude: 0, longitude: 0)
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    var topView = AppHeaderView()
    private var map = YBaseMapView()
    lazy var mapView: YMKMapView! = {
        return map.mapView
    }()
    var posts = [EventsModel]()
    var postDetail: EventDetails?
    var pointInf = [PointDetail]()

    let userLocationButton = MapButton(icon: UIImage(named: "logo")!)
    let zoomInButton = MapButton(icon: UIImage(named: "plusIcon")!)
    let zoomOutButton = MapButton(icon: UIImage(named: "minusIcon")!)
    
    private lazy var zoomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            zoomInButton,
            zoomOutButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 4.0
        return stackView
    }()

    var userLocation = YMKPoint() {
        didSet {
            guard userLocation.latitude != 0 && userLocation.longitude != 0 else { return }
            guard type != .creation else { return }
            if isFirstRequest {
                isFirstRequest = false
                var duration = 0
                switch type {
                case .standard:
                    duration = 1
                case .creation:
                    duration = 0
                }
                mapView.mapWindow.map.move(
                    with: YMKCameraPosition.init(target: userLocation, zoom: 14, azimuth: 0, tilt: 0),
                    animation: YMKAnimation(type: YMKAnimationType.linear, duration: Float(duration)),
                    cameraCallback: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topView)
        view.addSubview(mapView)
        view.addSubview(userLocationButton)
        view.addSubview(zoomStackView)
        setupMap()
        getPoints()
        setupUI()
        setupActions()
    }
    
    private func setupMap() {
        
        let latitude = 55.7602196
        let longitude = 37.6186409
        
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: latitude,
                                 longitude: longitude),
                zoom: 10,
                azimuth: 0,
                tilt: 0
            ),
            animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0),
            cameraCallback: nil)
        mapView.mapWindow.map.logo.setAlignmentWith(YMKLogoAlignment(
            horizontalAlignment: .left,
            verticalAlignment: YMKLogoVerticalAlignment.bottom)
        )
        mapView.mapWindow.map.addCameraListener(with: self)
        mapView.mapWindow.map.addInputListener(with: self)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "appBackground")
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        makeConstraints()
    }
    
    func makeConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        mapView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()//equalTo(view.safeAreaLayoutGuide)
        }
        
        userLocationButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(34)
        }

        zoomStackView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(18)
            $0.left.equalToSuperview().inset(16)
            $0.width.equalTo(48)
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
      dismiss(animated: true)
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
        viewPlacemark.addTapListener(with: self)
        viewPlacemark.userData = name
    }
    
    func getPoints() {
        let ref = Database.database().reference().child("points")
        ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPoint = [PointDetail]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let post = PointDetail.parse(childSnapshot.key, data) {
                    if post.isFirstPoint ?? false {
                        self.addPlacemarkOnMap(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0, name: post.name ?? "smth")
                    }
                }
            }
        })
    }
    
    private func setupActions() {
        userLocationButton.addTapGestureRecognizer {
//            if self.userLocation.latitude != 0 && self.userLocation.longitude != 0 {
//                self.mapView.mapWindow.map.move(
//                    with: YMKCameraPosition.init(target: self.userLocation, zoom: self.currentZoom, azimuth: 0, tilt: 0),
//                    animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0.5),
//                    cameraCallback: nil)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    if self.currentZoom < 15 {
//                        self.mapView.mapWindow.map.move(
//                            with: YMKCameraPosition.init(target: self.userLocation, zoom: 16, azimuth: 0, tilt: 0),
//                            animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0.8),
//                            cameraCallback: nil)
//                    }
//                }
//            } else {
////                self.presentBottomPopup(text: L10n.Popup.noAccesToGeo,
////                                        image: Asset.popupOrange.image,
////                                        withBotButton: false)
//            }
        }
        zoomInButton.addTapGestureRecognizer {
            self.mapView.mapWindow.map.move(
                with: YMKCameraPosition.init(
                    target: self.currentMapLocation,
                    zoom: self.currentZoom + 1,
                    azimuth: 0, tilt: 0),
                animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0.5),
                cameraCallback: nil)
            self.zoomInButton.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.zoomInButton.isUserInteractionEnabled = true
            }
        }
        zoomOutButton.addTapGestureRecognizer {
            self.mapView.mapWindow.map.move(
                with: YMKCameraPosition.init(
                    target: self.currentMapLocation,
                    zoom: self.currentZoom - 1,
                    azimuth: 0, tilt: 0),
                animation: YMKAnimation(type: YMKAnimationType.linear, duration: 0.5),
                cameraCallback: nil)
            self.zoomOutButton.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.zoomOutButton.isUserInteractionEnabled = true
            }
        }
    }
}

extension MapViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let placemark = mapObject as? YMKPlacemarkMapObject else {
            // Сценарий на случай ошибки
            return false
        }
        // Сценарий на случай успеха. Бизнес-логику добавляют сюда.
                // Пример
        self.focusOnPlacemark(placemark: placemark)
        return true
    }

    func focusOnPlacemark(placemark: YMKPlacemarkMapObject) {
        // Поменять расположение камеры, чтобы сфокусироваться на точке
        mapView.mapWindow.map.move(
              with: YMKCameraPosition(target: placemark.geometry, zoom: 18, azimuth: 0, tilt: 0),
              animation: YMKAnimation(type: YMKAnimationType.smooth, duration: 1.5),
              cameraCallback: nil // Опциональный callback по завершению работы камеры
        )

        if let placemarkName: String = placemark.userData as? String {
            // Пример
            self.displaySelectedPlacemarkName(placemarkName)
        } else {
            // do nothing
        }
    }

    func displaySelectedPlacemarkName(_ placemarkName: String) {
        // your code here
        if isLogin {
            
        } else {
            let vc = AuthViewController()
            present(vc, animated: true)
        }
    }
}

class MapButton: UIButton {
    convenience init(icon: UIImage) {
        self.init()
        self.setImage(icon, for: .normal)
        self.layer.cornerRadius = 12
        self.backgroundColor = .white
        self.setTitle("", for: .normal)
    }
}
