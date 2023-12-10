//
//  EventViewController.swift
//  ARtivity
//
//  Created by Сергей Киселев on 11.12.2023.
//

import UIKit
import FirebaseAuth
import Firebase
import SnapKit
import CoreLocation

class EventViewController: UIViewController {
    
    var post: EventsModel?
    
    var topView = AppHeaderView()
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    private let imageViewPost = UIImageView()
    private let mainView = UIView()
    private let eventName = UILabel()
    private var timeLabel = UILabel()
    private var distanceLabel = UILabel()
    private var pointsLabel = UILabel()
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(topView)
        view.addSubview(imageViewPost)
        view.addSubview(mainView)
        
        mainView.addSubview(eventName)
        mainView.addSubview(timeLabel)
        mainView.addSubview(distanceLabel)
        mainView.addSubview(pointsLabel)
        setupUI()
        loadImageView()
        setupData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        imageViewPost.backgroundColor = .systemGray5
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 16
        makeConstraints()
    }
    
    func makeConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        imageViewPost.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
        mainView.snp.makeConstraints { make in
            make.top.equalTo(imageViewPost.snp.bottom).offset(-20)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        eventName.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(40)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(eventName.snp.bottom).offset(10)
            make.leading.equalTo(eventName)
            make.height.equalTo(26)
        }
        pointsLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.centerX.equalToSuperview()
            make.height.equalTo(26)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(26)
        }
    }
    
    func loadImageView() {
//        guard let img = post?.eventImage else { return }
        if let imageUrlTemp = post?.eventImage {
            if imageUrlTemp != "" {
                let imagesUrl =  URL(string: (imageUrlTemp))
                
                self.imageViewPost.image = nil
                ImageService.getImage(withURL: imagesUrl!) { image, url in
                    if imagesUrl?.absoluteString == url.absoluteString {
                        self.imageViewPost.image = image
                    } else {
                        print("Not the right image")
                    }
                }
            } else {
                self.imageViewPost.image = UIImage(systemName: "photo")
            }
        }
    }
    
    func setupData() {
        eventName.text = post?.eventName
        if let distance = post?.eventDistance {
            let distanceText: String
            if distance >= 1000 {
                let distanceDouble = Double(distance)/1000.0
                distanceText = "\(String(format: "%.1f", distanceDouble)) км"
            } else {
                distanceText = "\(distance) м"
            }
            distanceLabel.text = distanceText
        }
        if let points = post?.eventPoint {
            if points == 1 {
                pointsLabel.text = "\(points) точка"
            } else if points < 5 {
                pointsLabel.text = "\(points) точки"
            } else {
                pointsLabel.text = "\(points) точек"
            }
        }
        
        if let time = post?.eventTime {
            if time < 60 {
                timeLabel.text = "\(time) минут"
            } else {
                timeLabel.text = "\(time/60) часа"
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
      dismiss(animated: true)
    }
}
