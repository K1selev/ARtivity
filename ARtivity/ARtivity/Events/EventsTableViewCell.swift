//
//  EventsTableViewCell.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import UIKit
import SnapKit
import CoreLocation
import CoreImage

class EventsTableViewCell: UITableViewCell {

    var cellView = UIView()
    var authorLabel = UILabel()
    private var timeLabel = UILabel()
    private var distanceLabel = UILabel()
    private var pointsLabel = UILabel()
    private var eventNameLabel = UILabel()
    private var eventPayedLabel = UILabel()
    private var eventImageView = UIImageView()
    private var eventRaiting = UILabel()

    var post: EventDetailsTest?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        
        cellView.backgroundColor = UIColor(named: "appCellsBackground")
        cellView.layer.cornerRadius = 8
        
        eventPayedLabel.isHidden = true
        eventPayedLabel.text = "  Платная  "
        eventPayedLabel.textColor = .white
        eventPayedLabel.backgroundColor = .red
        eventPayedLabel.layer.cornerRadius = 10
        eventPayedLabel.layer.masksToBounds = true

        eventImageView.backgroundColor = .systemGray5
        eventImageView.layer.cornerRadius = 16
        
        contentView.addSubview(cellView)

        [authorLabel,
         timeLabel,
         distanceLabel,
         pointsLabel,
         eventNameLabel,
         eventPayedLabel,
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
            make.trailing.equalTo(eventPayedLabel).offset(5)
            make.height.equalTo(24)
        }
        
        eventPayedLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-20)
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
//            make.centerX.equalTo(eventImageView.snp.centerX)
            make.leading.equalTo(distanceLabel.snp.trailing).offset(8)
            make.height.equalTo(26)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
//            make.trailing.equalTo(eventImageView.snp.trailing)
            make.leading.equalTo(pointsLabel.snp.trailing).offset(8)
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
    func set(post: EventDetailsTest) {
        self.post = post
        if !(post.eventIsFree ?? true) {
            eventPayedLabel.isHidden = false
        }
        if let imageUrlTemp = post.eventImage {
            if imageUrlTemp != "" {
                let imagesUrl =  URL(string: (imageUrlTemp))
                
                self.eventImageView.image = nil
                ImageService.getImage(withURL: imagesUrl!) { image, url in
                    if imagesUrl?.absoluteString == url.absoluteString {
                        if !(post.eventIsFree ?? true) {
                            self.eventImageView.image = self.createBlurredImageWithLock(from: image ?? UIImage(systemName: "photo")!)
                        } else {
                            self.eventImageView.image = image
                        }
                        self.eventImageView.clipsToBounds = true
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
                distanceText = "  \(String(format: "%.1f", distanceDouble)) км  "
            } else {
                distanceText = "  \(distance) м  "
            }
            distanceLabel.text = distanceText
        }
        distanceLabel.backgroundColor = .systemGray3
        distanceLabel.layer.cornerRadius = 10
        distanceLabel.layer.masksToBounds = true
        distanceLabel.textColor = .white
        
        if let points = post.eventPoints?.count {
            if points == 1 {
                pointsLabel.text = "  \(points) точка  "
            } else if points < 5 {
                pointsLabel.text = "  \(points) точки  "
            } else {
                pointsLabel.text = "  \(points) точек  "
            }
        }
        pointsLabel.backgroundColor = .systemGray3
        pointsLabel.layer.cornerRadius = 10
        pointsLabel.layer.masksToBounds = true
        pointsLabel.textColor = .white
        
        if let time = post.eventTime {
            if time / 60 < 60 {
                timeLabel.text = "  \(time / 60) минут  "
            } else {
                timeLabel.text = "  \(time/3600) часа  "
            }
        }
        timeLabel.backgroundColor = .systemGray3
        timeLabel.layer.cornerRadius = 10
        timeLabel.layer.masksToBounds = true
        timeLabel.textColor = .white
        
        eventRaiting.text = "  \(post.eventRating ?? 0)  "
        eventRaiting.backgroundColor = .systemGray3
        eventRaiting.layer.cornerRadius = 10
        eventRaiting.layer.masksToBounds = true
        eventRaiting.textColor = .white
        
        authorLabel.text = "  \(post.eventAuthor?.authorName ?? "")  "
        authorLabel.backgroundColor = .systemGray3
        authorLabel.layer.cornerRadius = 10
        authorLabel.layer.masksToBounds = true
        authorLabel.textColor = .white
    }
    
    func createBlurredImageWithLock(from originalImage: UIImage) -> UIImage? {
        let lockIcon = UIImage(systemName: "lock.fill")?.withTintColor(UIColor(named: "mainGreen")!, renderingMode: .alwaysOriginal) // Иконка замка
        
        // 1. Размытие с помощью CIFilter
        guard let ciImage = CIImage(image: originalImage) else { return nil }
        let blurFilter = CIFilter(name: "CIGaussianBlur") // Используем явное имя фильтра
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(15, forKey: kCIInputRadiusKey) // Радиус размытия

        guard let outputImage = blurFilter?.outputImage else { return nil }
        
        // Получение окончательного размытого изображения
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        let blurredImage = UIImage(cgImage: cgImage)

        // 2. Наложение замка
        let finalSize = originalImage.size
        UIGraphicsBeginImageContextWithOptions(finalSize, false, 0)
        
        // Рисуем размытие
        blurredImage.draw(in: CGRect(origin: .zero, size: finalSize))
        
        // Добавляем замок
        if let lock = lockIcon {
            let lockSize = CGSize(width: finalSize.width / 4, height: finalSize.width / 4) // Размер замка
            let lockOrigin = CGPoint(
                x: (finalSize.width - lockSize.width) / 2,
                y: (finalSize.height - lockSize.height) / 2
            )
            lock.draw(in: CGRect(origin: lockOrigin, size: lockSize))
        }
        
        // Получаем итоговое изображение
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }

}

