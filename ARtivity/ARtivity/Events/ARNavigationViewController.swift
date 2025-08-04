import UIKit
import ARKit
import SceneKit
import CoreLocation
import MapKit

class ARNavigationViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    var sceneView: ARSCNView!
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var points: [PointDetail] = []
    var reachedPoints = Set<String>()

    let miniMapView = MKMapView()
    var miniMapHeightConstraint: NSLayoutConstraint!
    var isMapFullscreen = false

    let distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.text = "Расстояние: —"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupLocationManager()
        addBackButton()
        setupMiniMap()
        setupDistanceLabel()

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    func setupScene() {
        sceneView = ARSCNView(frame: view.frame)
        sceneView.delegate = self
        view.addSubview(sceneView)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func setupMiniMap() {
        miniMapView.delegate = self
        miniMapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(miniMapView)

        miniMapHeightConstraint = miniMapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33)

        NSLayoutConstraint.activate([
            miniMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            miniMapHeightConstraint
        ])
    }

    func setupDistanceLabel() {
        view.addSubview(distanceLabel)
        NSLayoutConstraint.activate([
            distanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distanceLabel.widthAnchor.constraint(equalToConstant: 200),
            distanceLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up where !isMapFullscreen:
            isMapFullscreen = true
            UIView.animate(withDuration: 0.3) {
                self.miniMapHeightConstraint.constant = self.view.frame.height
                self.view.layoutIfNeeded()
            }
        case .down where isMapFullscreen:
            isMapFullscreen = false
            UIView.animate(withDuration: 0.3) {
                self.miniMapHeightConstraint.constant = self.view.frame.height * 0.33
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        updateMiniMapRoute()
        updateDistanceLabel()
    }

    func updateMiniMapRoute() {
        guard let userLocation = userLocation, let first = points.first,
              let lat = first.latitude, let lon = first.longitude else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)))
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, _ in
            guard let self = self, let route = response?.routes.first else { return }
            self.miniMapView.removeOverlays(self.miniMapView.overlays)
            self.miniMapView.addOverlay(route.polyline)
            self.miniMapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)

            for point in self.points {
                if let lat = point.latitude, let lon = point.longitude {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    annotation.title = point.name
                    self.miniMapView.addAnnotation(annotation)
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }

    func updateDistanceLabel() {
        guard let userLocation = userLocation, let first = points.first,
              let lat = first.latitude, let lon = first.longitude else { return }

        let pointLocation = CLLocation(latitude: lat, longitude: lon)
        let distance = userLocation.distance(from: pointLocation)
        distanceLabel.text = String(format: "Расстояние: %.0f м", distance)
    }

    func addBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Назад", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backButton.layer.cornerRadius = 8
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func backTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - AR Scene Drawing

    func drawGuidanceArrows() {
        guard let userLocation = userLocation else { return }

        for point in points {
            guard let lat = point.latitude, let lon = point.longitude else { continue }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let distance = userLocation.distance(from: CLLocation(latitude: lat, longitude: lon))

            let arrow = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.05, height: 0.1))
            arrow.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
            arrow.eulerAngles.x = -.pi / 2

            let transform = transformMatrix(origin: userLocation.coordinate, destination: coordinate, userLocation: userLocation)
            let pos = SCNVector3(transform.columns.3.x, -0.3, transform.columns.3.z)
            arrow.position = pos
            sceneView.scene.rootNode.addChildNode(arrow)
        }
    }

    func transformMatrix(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, userLocation: CLLocation) -> simd_float4x4 {
        let bearing = origin.bearing(to: destination) // возвращает Double
        let distance = Float(userLocation.distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude)))

        let bearingRadians = Float(bearing * .pi / 180)

        let x = distance * sin(bearingRadians)
        let z = distance * cos(bearingRadians)

        let translation = simd_float4x4(SCNMatrix4MakeTranslation(x, 0, -z))
        return translation
    }
}
