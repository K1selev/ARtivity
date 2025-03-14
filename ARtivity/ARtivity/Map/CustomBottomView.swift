//
//  CustomBottomView.swift
//  ARtivity
//
//  Created by Сергей Киселев on 20.01.2025.
//

import UIKit
import Firebase

class CustomBottomView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var event = EventDetailsTest()
    let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let collectionView: UICollectionView
    private let exploreButton = UIButton()
    var parentVC: UIViewController?
    
    private var id: String = ""
    private var images: [UIImage] = []
    private var imagesStr: [String] = [""]

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 20
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 14
        layer.masksToBounds = true
        
        // Close Button
        addSubview(closeButton)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        
        // Title Label
        addSubview(titleLabel)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(closeButton.snp.left).offset(-16)
        }
        
        // Description Label
        addSubview(descriptionLabel)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .darkGray
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
                
        // Collection View
        addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(100)
        }
        
        exploreButton.setTitle("Открыть экскурсию", for: .normal)
        exploreButton.titleLabel?.font = .systemFont(ofSize: 16)
        exploreButton.setTitleColor(.black, for: .normal)
        exploreButton.backgroundColor = UIColor(named: "mainGreen")
        exploreButton.layer.cornerRadius = 10
        exploreButton.clipsToBounds = true
        exploreButton.addTarget(self, action: #selector(exploreButtonTapped), for: .touchUpInside)
        addSubview(exploreButton)
        exploreButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        

    }

    func configure(with title: String, description: String, images: [String], id: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        self.id = id
        self.images.removeAll()
        self.imagesStr.removeAll()
        self.imagesStr = images
        for img in imagesStr {
                if img != "" {
                    let imagesUrl =  URL(string: (img))
                    ImageService.getImage(withURL: imagesUrl!) { image, url in
                        if imagesUrl?.absoluteString == url.absoluteString {
                            self.images.append(image!)
                            self.collectionView.reloadData()
                        } else {
                            print("Not the right image")
                        }
                    }
                } else {
                    self.images.append(UIImage(systemName: "photo")!)
                    self.images.append(UIImage(systemName: "photo")!)
                    self.images.append(UIImage(systemName: "photo")!)
                }
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        let imageView = UIImageView(image: images[indexPath.item])
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return cell
    }
    
    @objc func exploreButtonTapped() {
        print("open event with first point \(id) id")
        getPoints()
        
    }
    
    func getPoints() {
            let ref = Database.database().reference().child("event")
            ref.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
                var tempPoint = [EventDetailsTest]()
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let data = childSnapshot.value as? [String: Any],
                       let post = EventDetailsTest.parse(childSnapshot.key, data) {
                        if post.eventPoints?.first == self.id {
                            print("open event with first point id")
                            if let parentVC = self.parentVC {
                                let vc = EventViewController()
                                vc.event = post
                                vc.modalPresentationStyle = .fullScreen
                                parentVC.present(vc, animated: true, completion: nil)
                            }
//                            if let parentVC = self.parentViewController {
//                                        parentVC.presentPromoView()
//                                    }
//
                            return
                        }
//                        let refPoint = Database.database().reference().child("points").child(post.eventPoints?.first ?? "0")
//                        refPoint.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
//                            var tempPoint = PointDetail()
//                            if let childSnapshot = snapshot as? DataSnapshot,
//                               let data = childSnapshot.value as? [String: Any],
//                               let point = PointDetail.parse(childSnapshot.key, data)
//                            {
//                                let currentMapLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: point.latitude ?? 0.0, longitude: point.longitude ?? 0.0)
//                                self.addAnnotation(location: currentMapLocation, title: point.name ?? "", subtitle: point.description ?? "", imgs: point.photos ?? [""], id: point.id ?? "")
//                            }
//                        })
                    }
                }
            })
        }

}
