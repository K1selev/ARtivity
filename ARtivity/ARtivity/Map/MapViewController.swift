//
//  MapViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 03.12.2024.
//


import UIKit
import MapKit
import CoreLocation
import Firebase


class MapViewController: UIViewController {
    
    var topView = AppHeaderView()
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    let zoomInButton = MapButton(icon: UIImage(named: "plusIcon")!)
    let zoomOutButton = MapButton(icon: UIImage(named: "minusIcon")!)
    var posts = [EventsModel]()
    var currentZoom: Double = 0.05
    var currentMapLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.7602196, longitude: 37.6186409)
    
    private lazy var zoomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            zoomInButton,
            zoomOutButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 4.0
        return stackView
    }()
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    var annotationsArray = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setConstraints()
        setupActions()
        getPoints()
        view.backgroundColor = UIColor(named: "appBackground")
        // Do any additional setup after loading the view.
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
                            let currentMapLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: post.latitude ?? 0.0, longitude: post.longitude ?? 0.0)
                            self.addAnnotation(location: currentMapLocation)
                        }
                    }
                }
            })
        }

    private func setupActions() {
        moveToLocation(latitude: 55.7602196, longitude: 37.6186409, zoom: 1)
        
        zoomInButton.addTapGestureRecognizer {
            
            self.currentZoom = max(self.currentZoom / 1.5, 0.001)
            let newRegion = MKCoordinateRegion(center: self.currentMapLocation, span: MKCoordinateSpan(latitudeDelta: self.currentZoom, longitudeDelta: self.currentZoom))
            self.mapView.setRegion(newRegion, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.zoomInButton.isUserInteractionEnabled = true
            }
        }
        zoomOutButton.addTapGestureRecognizer {
            self.currentZoom = max(self.currentZoom * 1.5, 0.001)
            let newRegion = MKCoordinateRegion(center: self.currentMapLocation, span: MKCoordinateSpan(latitudeDelta: self.currentZoom, longitudeDelta: self.currentZoom))
            self.mapView.setRegion(newRegion, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.zoomInButton.isUserInteractionEnabled = true
            }
        }
    }
    
//    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D,  destinationCoordinate: CLLocationCoordinate2D) {
//        
//        let startLocation = MKPlacemark(coordinate: startCoordinate)
//        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
//        
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: startLocation)
//        request.destination = MKMapItem(placemark: destinationLocation)
//        request.transportType = .walking
//        request.requestsAlternateRoutes = true
//        
//        let diraction = MKDirections(request: request)
//        diraction.calculate { (response, error) in
//            
//            if let error = error {
//                print(error)
//                return
//            }
//            
//            guard let response = response else {
////                self.alerError(title: "Error", message: "маршурт не доступен")
//                return
//            }
//            
//            var minRoute = response.routes[0]
//            for route in response.routes {
//                print (route.distance)
//                minRoute = (route.distance < minRoute.distance) ? route : minRoute
//            }
//            
//            self.mapView.addOverlay(minRoute.polyline)
//        }
//    }
    
    @objc func buttonBackClicked() {
        dismiss(animated: true)
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
    
    func addAnnotation(location: CLLocationCoordinate2D){
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = ""
            self.mapView.addAnnotation(annotation)
    }
    
    func moveToLocation(latitude: Double, longitude: Double, zoom: Double) {
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            currentMapLocation = location
            currentZoom = 1 / pow(2, zoom) // Convert zoom level to span approximation

            let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: currentZoom, longitudeDelta: currentZoom))
            mapView.setRegion(newRegion, animated: true)
        }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
        
    }
    
}

extension MapViewController {
    
    func setConstraints() {
        
        view.addSubview(topView)
//        view.addSubview(userLocationButton)
        view.addSubview(mapView)
        view.addSubview(zoomStackView)
        
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        
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
        
        zoomStackView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(18)
            $0.left.equalToSuperview().inset(16)
            $0.width.equalTo(48)
        }

        
//        mapView.addSubview(addAdressButton)
//        NSLayoutConstraint.activate([
//            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
//            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
//            addAdressButton.heightAnchor.constraint(equalToConstant: 50),
//            addAdressButton.widthAnchor.constraint(equalToConstant: 50)
//        ])
//        
//        mapView.addSubview(routeButton)
//        NSLayoutConstraint.activate([
//            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
//            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
//            routeButton.heightAnchor.constraint(equalToConstant: 100),
//            routeButton.widthAnchor.constraint(equalToConstant: 100)
//        ])
//        
//        mapView.addSubview(resetButton)
//        NSLayoutConstraint.activate([
//            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
//            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
//            resetButton.heightAnchor.constraint(equalToConstant: 50),
//            resetButton.widthAnchor.constraint(equalToConstant: 50)
//        ])
    }
}

extension MKMapView {
  func zoomToUserLocation() {
     self.zoomToUserLocation(latitudinalMeters: 1000, longitudinalMeters: 1000)
  }

  func zoomToUserLocation(latitudinalMeters:CLLocationDistance,longitudinalMeters:CLLocationDistance)
  {
    guard let coordinate = userLocation.location?.coordinate else { return }
    self.zoomToLocation(location: coordinate, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
  }

  func zoomToLocation(location : CLLocationCoordinate2D,latitudinalMeters:CLLocationDistance = 100,longitudinalMeters:CLLocationDistance = 100)
  {
      let region = MKCoordinateRegion(center: location, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
    setRegion(region, animated: true)
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
