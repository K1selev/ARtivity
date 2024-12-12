//
//  RecordVC.swift
//  ARtivity
//
//  Created by Сергей Киселев on 10.12.2024.
//
// 
import UIKit
import AVFoundation
import FirebaseStorage
import SnapKit
    
class RecordVC: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var audioFileURL: URL?
    var displayLink: CADisplayLink?
    var audioWaveformView = WaveformView()
    
    // UI элементы
    private let recordButton = UIButton(type: .system)
    private let playButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Запросить разрешение на использование микрофона
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            if allowed {
                self?.setupAudioRecorder()
            } else {
                print("Permission denied")
            }
        }
        
        // Настроить интерфейс
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        recordButton.setImage(UIImage(systemName: "mic"), for: .normal)
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchDown)
        recordButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(stopRecording), for: .touchUpOutside)
        recordButton.tintColor = .systemGreen
        view.addSubview(recordButton)
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.addTarget(self, action: #selector(playRecording), for: .touchUpInside)
        playButton.tintColor = .systemGreen
        playButton.isEnabled = false
        view.addSubview(playButton)
        
        sendButton.setTitle("Отправить", for: .normal)
        sendButton.addTarget(self, action: #selector(sendRecording), for: .touchUpInside)
        sendButton.isEnabled = false
        view.addSubview(sendButton)
        
        statusLabel.text = "Статус: Ожидает записи"
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        audioWaveformView.backgroundColor = .clear
        view.addSubview(audioWaveformView)
        
        recordButton.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(250)
            make.leading.equalToSuperview().offset(34)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        playButton.snp.makeConstraints { make in
            make.centerY.equalTo(recordButton.snp.centerY)
            make.trailing.equalToSuperview().offset(-34)
            make.width.height.equalTo(40)
        }
        
        audioWaveformView.snp.makeConstraints { make in
            make.centerY.equalTo(recordButton.snp.centerY)
            make.leading.equalTo(recordButton.snp.trailing).offset(15)
            make.trailing.equalTo(playButton.snp.leading).offset(-15)
            make.height.equalTo(70)
        }
        
        sendButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(playButton.snp.bottom).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(sendButton.snp.bottom).offset(10)
            make.width.equalTo(view.snp.width).offset(-40)
        }
        
    }
    
    func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session")
        }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioFileURL = documentsDirectory.appendingPathComponent("recording.m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up audio recorder")
        }
    }
    
    @objc func startRecording() {
        // Начать запись
        audioWaveformView.clear()
        guard let audioRecorder = audioRecorder else { return }
        if !audioRecorder.isRecording {
            audioRecorder.record()
            startUpdatingWaveform()
            statusLabel.text = "Статус: Запись идет..."
            recordButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        }
    }
    
    @objc func stopRecording() {
        // Остановить запись
        guard let audioRecorder = audioRecorder else { return }
        if audioRecorder.isRecording {
            audioRecorder.stop()
            stopUpdatingWaveform()
            statusLabel.text = "Статус: Запись завершена"
            recordButton.setImage(UIImage(systemName: "mic"), for: .normal)
            
            // Доступность кнопки воспроизведения и отправки
            playButton.isEnabled = true
            sendButton.isEnabled = true
        }
    }
    
    @objc func playRecording() {
        guard let audioFileURL = audioFileURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            statusLabel.text = "Статус: Воспроизведение..."
            
            // Изменим иконку на паузу
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } catch {
            print("Error playing audio")
        }
    }
    
    @objc func sendRecording() {
        guard let audioFileURL = audioFileURL else { return }
        uploadAudioToFirebase()
    }
    
//    func uploadAudioToFirebase() {
//        guard let audioFileURL = audioFileURL else { return }
//        let timeStamp = Int(NSDate.timeIntervalSinceReferenceDate*1000)
//        let audioRef = Storage.storage().reference().child("audio/\(timeStamp).m4a")
//        
//        audioRef.putFile(from: audioFileURL, metadata: nil) { (metadata, error) in
//            if let error = error {
//                print("Error uploading: \(error.localizedDescription)")
//                return
//            }
//            print("Upload successful")
//            audioRef.downloadURL { (url, error) in
//                if let error = error {
//                    print("Error getting download URL: \(error.localizedDescription)")
//                } else {
//                    print("Download URL: \(url?.absoluteString ?? "")")
//                }
//            }
//        }
//    }
    
    func uploadAudioToFirebase() {
        guard let audioFileURL = audioFileURL else {
            print("Audio file URL is nil. Cannot proceed with upload.")
            return
        }

        do {
            let fileData = try Data(contentsOf: audioFileURL)
            print("Preparing to upload file of size: \(fileData.count) bytes")

            let timeStamp = Int(Date.timeIntervalSinceReferenceDate * 1000)
            let audioRef = Storage.storage().reference().child("audio/\(timeStamp).m4a")

            audioRef.putData(fileData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error occurred during upload: \(error.localizedDescription)")
                    return
                }
                
                print("File uploaded successfully to Firebase Storage.")
                audioRef.downloadURL { url, error in
                    if let error = error {
                        print("Error retrieving download URL: \(error.localizedDescription)")
                    } else if let downloadURL = url {
                        print("Download URL: \(downloadURL.absoluteString)")
                    }
                }
            }
        } catch {
            print("Error reading file data: \(error.localizedDescription)")
        }
    }

    
    func startUpdatingWaveform() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateWaveform))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    func stopUpdatingWaveform() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func updateWaveform() {
        guard let audioRecorder = audioRecorder, audioRecorder.isRecording else { return }
        audioRecorder.updateMeters()
        let power = audioRecorder.averagePower(forChannel: 0)
        audioWaveformView.addSample(value: power)
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        statusLabel.text = "Статус: Воспроизведение завершено"
    }
}
