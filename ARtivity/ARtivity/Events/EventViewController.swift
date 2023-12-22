////
////  EventViewController.swift
////  ARtivity
////
////  Created by Сергей Киселев on 11.12.2023.
////
///
///

import UIKit
import FirebaseAuth
import Firebase
import SnapKit
import CoreLocation

class EventViewController: UIViewController, UIScrollViewDelegate {

    var post: EventsModel?

    var topView = AppHeaderView()
    let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
    private let imageViewPost = UIImageView()
    private let mainView = UIView()
    private let eventName = UILabel()
    private var timeLabel = UILabel()
    private var distanceLabel = UILabel()
    private var pointsLabel = UILabel()
    private let ratingImg = UIImageView()
    private let ratingText = UILabel()
    private let languageImage = UIImageView()
    private let languageText = UILabel()
    private let ARImage = UIImageView()
    private let ARText = UILabel()
    private let lineView = UIView()
    private var lineView2 = UIView()
    private var lineView3 = UIView()
    private var lineView4 = UIView()
    private var lineView5 = UIView()
    private var lineView6 = UIView()
    private let pointsMainText = UILabel()
    
    private let pointNumber1 = UILabel()
    private let pointName1 = UILabel()
    private let pointDescription1 = UILabel()
    
    private let pointNumber2 = UILabel()
    private let pointName2 = UILabel()
    private let pointDescription2 = UILabel()
    private let pointNumber3 = UILabel()
    private let pointName3 = UILabel()
    private let pointDescription3 = UILabel()
    
    private let pointView1 = UIView()
    private let pointView2 = UIView()
    private let pointView3 = UIView()
    
    private let descriptionMainText = UILabel()
    private let descriptionText = UILabel()
    private let galeryMainText = UILabel()
    private let galeryphotos = UIImageView()
    private let mapImage = UIImageView()
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.delegate = self
        setupUI()
    }
    

    private func setupUI() {
        view.backgroundColor = .white
        imageViewPost.backgroundColor = .systemGray5
        imageViewPost.layer.cornerRadius = 13
        scrollView.backgroundColor = .clear
        topView.isUserInteractionEnabled = true
        topView.leftButton.addTarget(self,action:#selector(buttonBackClicked),
                                     for:.touchUpInside)
        topView.rightButton.addTarget(self,action:#selector(buttonProfileClicked),
                                      for:.touchUpInside)
        
        //MARK: it will be a simple tableViewCell
        setupPointView1()
        setupPointView2()
        setupPointView3()
        
//        pointView2.addBlurToView()
        
        view.addSubview(scrollView)
                [imageViewPost,
                 eventName,
                 timeLabel,
                 distanceLabel,
                 pointsLabel,
                 ratingImg,
                 ratingText,
                 languageImage,
                 languageText,
                 ARImage,
                 ARText,
                 lineView,
                lineView2,
                pointsMainText,
                lineView3,
                 pointView1,
                lineView4,
                pointView2,
                 lineView5,
                 pointView3,
                lineView6,
                 descriptionMainText,
                 descriptionText,
                 galeryMainText].forEach {
                    scrollView.addSubview($0)
                   }
        view.addSubview(topView)
        
        distanceLabel.textAlignment = .center
        timeLabel.textAlignment = .center
        pointsLabel.textAlignment = .center
        
        loadImageView()
        setupData()
        makeConstraints()
        setupNoDataInf()
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
        imageViewPost.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(view.bounds.width)
            make.height.equalTo(300)
        }
        eventName.snp.makeConstraints { make in
            make.top.equalTo(imageViewPost.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        ratingImg.snp.makeConstraints { make in
            make.top.equalTo(eventName)
            make.leading.equalTo(eventName.snp.trailing).offset(5)
            make.width.height.equalTo(18)
        }
        ratingText.snp.makeConstraints { make in
            make.top.equalTo(eventName)
            make.leading.equalTo(ratingImg.snp.trailing).offset(5)
            make.height.equalTo(18)
        }
        
        languageImage.snp.makeConstraints { make in
            make.top.equalTo(eventName.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.width.height.equalTo(20)
        }
        languageText.snp.makeConstraints { make in
            make.top.equalTo(languageImage)
            make.leading.equalTo(languageImage.snp.trailing).offset(15)
            make.height.equalTo(20)
        }
        
        ARImage.snp.makeConstraints { make in
            make.top.equalTo(languageImage.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.width.equalTo(20)
            make.height.equalTo(18)
        }
        ARText.snp.makeConstraints { make in
            make.top.equalTo(ARImage)
            make.leading.equalTo(ARImage.snp.trailing).offset(15)
            make.height.equalTo(20)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(ARImage.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.width.equalTo(view.bounds.width / 3)
            make.height.equalTo(16)
        }
        pointsLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.bounds.width / 3)
            make.height.equalTo(16)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.trailing.equalToSuperview()
            make.width.equalTo(view.bounds.width / 3)
            make.height.equalTo(16)
        }
        
        lineView2.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        pointsMainText.snp.makeConstraints { make in
            make.top.equalTo(lineView2.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        lineView3.snp.makeConstraints { make in
            make.top.equalTo(pointsMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        pointView1.snp.makeConstraints { make in
            make.top.equalTo(lineView3.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(54)
        }
        
        lineView4.snp.makeConstraints { make in
            make.top.equalTo(pointView1.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        pointView2.snp.makeConstraints { make in
            make.top.equalTo(lineView4.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(54)
        }
        
        lineView5.snp.makeConstraints { make in
            make.top.equalTo(pointView2.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        pointView3.snp.makeConstraints { make in
            make.top.equalTo(lineView5.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(54)
        }
        
        lineView6.snp.makeConstraints { make in
            make.top.equalTo(pointView3.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        descriptionMainText.snp.makeConstraints { make in
            make.top.equalTo(lineView6.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
        
        descriptionText.snp.makeConstraints { make in
            make.top.equalTo(descriptionMainText.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(34)
            make.trailing.equalToSuperview().offset(-34)
        }
        
        galeryMainText.snp.makeConstraints { make in
            make.top.equalTo(descriptionText.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(34)
            make.height.equalTo(20)
        }
    }

    func setupNoDataInf() {
//        ratingText.text = ""
        ratingImg.image = UIImage(named: "starIcon")
        languageImage.image = UIImage(named: "globeIcone")
        ARImage.image = UIImage(named: "cameraIcon")
        
        lineView.layer.borderWidth = 0.5
        lineView.layer.borderColor = UIColor.black.cgColor
        
        lineView2.layer.borderWidth = 0.5
        lineView2.layer.borderColor = UIColor.black.cgColor
        
        lineView3.layer.borderWidth = 0.5
        lineView3.layer.borderColor = UIColor.black.cgColor
        
        lineView4.layer.borderWidth = 0.5
        lineView4.layer.borderColor = UIColor.black.cgColor
        
        lineView5.layer.borderWidth = 0.5
        lineView5.layer.borderColor = UIColor.black.cgColor
        
        lineView6.layer.borderWidth = 0.5
        lineView6.layer.borderColor = UIColor.black.cgColor
        
        languageText.text = "Русский язык экскурсии"
        ARText.text = "Ориентируйся с помощью дополненной реальности"
        pointsMainText.text = "Точки экскурсии"
        descriptionMainText.text = "Описание"
        descriptionText.text = "Приглашаем познакомиться с одной из древнейших и красивейших столиц мира. Вы оцените эклектичную архитектуру города, увидите знаменитые улицы и проспекты, побываете на центральных площадях."
        galeryMainText.text = "Фотографии с мест экскурсии"
        
        eventName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        languageText.font = UIFont.systemFont(ofSize: 12.0)
        ARText.font = UIFont.systemFont(ofSize: 12.0)
        pointsMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        descriptionText.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        galeryMainText.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        descriptionText.numberOfLines = 0
    }
    
    //MARK: кринжанул
    func setupPointView1() {
        
        pointNumber1.text = "1"
        pointName1.text = "Большой театр"
        pointDescription1.text = "Театральная площадь, 1"
        
        pointView1.addSubview(pointName1)
        pointView1.addSubview(pointNumber1)
        pointView1.addSubview(pointDescription1)
        
        pointNumber1.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.width.height.equalTo(20)
        }
        pointName1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(pointNumber1.snp.trailing).offset(20)
            make.height.equalTo(20)
        }
        pointDescription1.snp.makeConstraints { make in
            make.top.equalTo(pointName1.snp.bottom)
            make.leading.equalTo(pointName1)
            make.height.equalTo(20)
        }
        
        pointName1.font = UIFont.systemFont(ofSize: 14)
        pointDescription1.font = UIFont.systemFont(ofSize: 12, weight: .light)
    }
    
    func setupPointView2() {
        pointNumber2.text = "2"
        pointName2.text = "Московский Кремль"
        pointDescription2.text = "Ивановская площадь"
        
        pointNumber2.textColor = .black.withAlphaComponent(0.1)
        pointName2.textColor = .black.withAlphaComponent(0.1)
        pointDescription2.textColor = .black.withAlphaComponent(0.1)
        
        pointView2.addSubview(pointName2)
        pointView2.addSubview(pointNumber2)
        pointView2.addSubview(pointDescription2)
        
        pointNumber2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.width.height.equalTo(20)
        }
        pointName2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(pointNumber2.snp.trailing).offset(20)
            make.height.equalTo(20)
        }
        pointDescription2.snp.makeConstraints { make in
            make.top.equalTo(pointName2.snp.bottom)
            make.leading.equalTo(pointName2)
            make.height.equalTo(20)
        }
        
        pointName2.font = UIFont.systemFont(ofSize: 14)
        pointDescription2.font = UIFont.systemFont(ofSize: 12, weight: .light)
    }
    
    func setupPointView3() {
        pointNumber3.text = "3"
        pointName3.text = "Парк “Зарядье”"
        pointDescription3.text = "ул. Варварка, 6, стр. 1"
        
        pointView3.addSubview(pointName3)
        pointView3.addSubview(pointNumber3)
        pointView3.addSubview(pointDescription3)
        
        pointNumber3.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(34)
            make.width.height.equalTo(20)
        }
        pointName3.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(pointNumber3.snp.trailing).offset(20)
            make.height.equalTo(20)
        }
        pointDescription3.snp.makeConstraints { make in
            make.top.equalTo(pointName3.snp.bottom)
            make.leading.equalTo(pointName3)
            make.height.equalTo(20)
        }
        
        pointName3.font = UIFont.systemFont(ofSize: 14)
        pointDescription3.font = UIFont.systemFont(ofSize: 12, weight: .light)
    }
    //MARK: кринжанул
    
    func loadImageView() {
        guard let img = post?.eventImage else { return }
        if let imageUrlTemp = post?.eventImage {
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

    func setupData() {
        ratingText.text = "\(post?.eventRating ?? 0.0)"
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
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1400)
    }
}
