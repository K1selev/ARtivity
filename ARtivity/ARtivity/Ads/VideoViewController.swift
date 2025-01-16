import UIKit
import SafariServices
import AVFoundation
import AVKit

class WebViewController: UIViewController {
    
    var onFinish: (() -> Void)?
    var playerViewController: AVPlayerViewController!
    var closeButton = UIButton()
    var skipButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        guard let videoURL = URL(string: "https://www.w3schools.com/html/mov_bbb.mp4") else {
            return
        }
        
        let player = AVPlayer(url: videoURL)
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = view.bounds
        playerViewController.view.backgroundColor = UIColor.clear
        view.addSubview(playerViewController.view)
        skipButton = UIButton(type: .system)
        skipButton.frame = CGRect(x: view.frame.width - 140, y: 40, width: 120, height: 40)
        skipButton.setTitle("Пропустить", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        skipButton.isHidden = true
        view.addSubview(skipButton)
        
        closeButton = UIButton(type: .system)
        closeButton.frame = CGRect(x: view.frame.width - 60, y: 40, width: 50, height: 50)
        closeButton.backgroundColor = .clear
        closeButton.setImage(UIImage(named: "navSkipButton"), for: .normal)
        closeButton.tintColor = .lightGray
        closeButton.setTitle("", for: .normal)
        
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.isHidden = true
        view.addSubview(closeButton)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.skipButton.isHidden = false
        }
        player.play()
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    @objc func videoDidFinish() {
        skipButton.isHidden = true
        closeButton.isHidden = false
    }

    @objc func skipButtonTapped() {
        onFinish?()
        dismiss(animated: true)
    }
    
    @objc func closeButtonTapped() {
        onFinish?()
        dismiss(animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let url = URL(string: "https://ya.ru") {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
}
