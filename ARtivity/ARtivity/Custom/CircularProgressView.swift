//
//  CircularProgressView.swift
//  ARtivity
//
//  Created by Сергей Киселев on 18.01.2025.
//

import UIKit
import SnapKit

class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let percentageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
        
        percentageLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        percentageLabel.textColor = .label
        percentageLabel.textAlignment = .center
        
        addSubview(percentageLabel)
        percentageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        configureLayers()
    }

    private func configureLayers() {
        let circlePath = UIBezierPath(arcCenter: .zero, radius: 70, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
        
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray4.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = UIColor(named: "mainGreen")?.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        progressLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        progressLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func setProgress(_ progress: Double, animated: Bool) {
        let clampedProgress = max(0, min(1, progress))
        progressLayer.strokeEnd = CGFloat(clampedProgress)
        percentageLabel.text = String(format: "%.0f%%", clampedProgress * 100)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.5
            animation.toValue = clampedProgress
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            progressLayer.add(animation, forKey: "progress")
        }
    }
}
