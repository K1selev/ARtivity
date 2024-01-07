//
//  EventPointTableViewCell.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.01.2024.
//

import UIKit
import SnapKit
import CoreLocation

class EventPointTableViewCell: UITableViewCell {

    var cellView = UIView()
    var numberLabel = UILabel()
    private var pointNameLabel = UILabel()
    private var pointAddressLabel = UILabel()

    var point: PointDetail?

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
        
        contentView.addSubview(cellView)

        [numberLabel,
         pointNameLabel,
         pointAddressLabel
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
        numberLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
//            make.height.equalTo(26)
        }
        pointNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(numberLabel.snp.trailing).offset(10)
        }
        pointAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(pointNameLabel.snp.bottom).offset(5)
            make.leading.equalTo(pointNameLabel.snp.leading)
        }
    }
    func set(point: PointDetail) {
        self.point = point
        pointNameLabel.text = point.name
        pointNameLabel.font = UIFont.systemFont(ofSize: 14)
        pointAddressLabel.text = point.address
        pointAddressLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
    }
}


