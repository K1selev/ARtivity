import UIKit
import SnapKit

class HistoryTableViewCell: UITableViewCell {
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.black
        return label
    }()
    
    private var iconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        iconImageView.layer.cornerRadius = 12
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(150)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
//            make.height.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, img: String) {
        titleLabel.text = title
        if img != "" {
            let imagesUrl =  URL(string: (img))
            
            self.imageView?.image = nil
            ImageService.getImage(withURL: imagesUrl!) { image, url in
                if imagesUrl?.absoluteString == url.absoluteString {
                    self.iconImageView.image = image
                    self.iconImageView.clipsToBounds = true
                } else {
                    print("Not the right image")
                }
            }
        } else {
            self.imageView?.image = UIImage(systemName: "leaf.circle.fill")
        }
    }
}
