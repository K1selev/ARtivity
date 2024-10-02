//
//  SettingsCell.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.01.2024.
//

import UIKit

final class SettingsCell: UITableViewCell {
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            imageView?.image = UIImage(systemName: sectionType.image)?
                .withTintColor(UIColor(named: "appTextMain")!, renderingMode: .alwaysOriginal)
            textLabel?.text = sectionType.description
            textLabel?.textColor = UIColor(named: "appTextMain")
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
