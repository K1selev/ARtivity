//
//  EventsTableViewCell.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import UIKit
import SnapKit
import CoreLocation

class EventsTableViewCell: UITableViewCell {

    var cellView = UIView()
    var authorLabel = UILabel()
    private var timeLabel = UILabel()
    private var distanceLabel = UILabel()
    private var pointsLabel = UILabel()
    private var eventNameLabel = UILabel()
    private var eventImageView = UIImageView()
    private var eventRaiting = UILabel()

    var post: EventsModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        
        cellView.backgroundColor = .white
        cellView.layer.cornerRadius = 8

        eventImageView.backgroundColor = .systemGray5
        eventImageView.layer.cornerRadius = 16
        
        contentView.addSubview(cellView)

        [authorLabel,
         timeLabel,
         distanceLabel,
         pointsLabel,
         eventNameLabel,
         eventImageView,
         eventRaiting
        ].forEach {
            cellView.addSubview($0)
        }
        makeConstraints()
    }

    func makeConstraints() {

        cellView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }

        eventNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        eventImageView.snp.makeConstraints { make in            make.top.equalTo(eventNameLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(220)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(eventImageView.snp.bottom).offset(10)
            make.leading.equalTo(eventNameLabel)
            make.height.equalTo(26)
        }
        pointsLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.centerX.equalTo(eventImageView.snp.centerX)
            make.height.equalTo(26)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.trailing.equalTo(eventImageView.snp.trailing)
            make.height.equalTo(26)
        }
        eventRaiting.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(10)
            make.leading.equalTo(eventNameLabel)
            make.height.equalTo(26)
        }
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(eventRaiting)
            make.trailing.equalTo(eventImageView.snp.trailing)
            make.height.equalTo(26)
        }
    }
    func set(post: EventsModel) {
        self.post = post
        if let imageUrlTemp = post.eventImage {
            if imageUrlTemp != "" {
                let imagesUrl =  URL(string: (imageUrlTemp))
                
                self.eventImageView.image = nil
                ImageService.getImage(withURL: imagesUrl!) { image, url in
                    guard let _post = self.post else { return }
                    if imagesUrl?.absoluteString == url.absoluteString {
                        self.eventImageView.image = image
                    } else {
                        print("Not the right image")
                    }
                }
            } else {
                self.eventImageView.image = UIImage(systemName: "photo")
            }
        }
        eventNameLabel.text = post.eventName
        if let distance = post.eventDistance {
            let distanceText: String
            if distance >= 1000 {
                let distanceDouble = Double(distance)/1000.0
                distanceText = "\(String(format: "%.1f", distanceDouble)) km"
            } else {
                distanceText = "\(distance) m"
            }
            distanceLabel.text = distanceText
        }
        if let points = post.eventPoint {
            if points == 1 {
                pointsLabel.text = "\(points) точка"
            } else if points < 5 {
                pointsLabel.text = "\(points) точки"
            } else {
                pointsLabel.text = "\(points) точек"
            }
        }
        
        if let time = post.eventTime {
            if time < 60 {
                timeLabel.text = "\(time) минут"
            } else {
                timeLabel.text = "\(time/60) часа"
            }
        }
        
        eventRaiting.text = "\(post.eventRating ?? 0)"
        authorLabel.text = post.eventAuthor?.authorName
    }
}

