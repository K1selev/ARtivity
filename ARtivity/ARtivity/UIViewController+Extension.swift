//
//  UIViewController+Extension.swift
//  ARtivity
//
//  Created by Сергей Киселев on 02.12.2023.
//

import UIKit

private var aView: UIView?

extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func presentAccessErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "inSettings", style: .default) { (_) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }

        }
        let okAction = UIAlertAction(title: "disallow", style: .default)
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func presentInfoAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "ok", style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func showSpinner() {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

        let ai = UIActivityIndicatorView(style: .large)
        ai.center = aView?.center ?? CGPoint(x: 0, y: 0)
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView ?? UIView())
    }

    func removeSpinner() {
        aView?.removeFromSuperview()
        aView = nil
    }
}

extension UIView {
    func addBlurToView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.alpha = 0.8
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}
