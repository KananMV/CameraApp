//
//  ViewController.swift
//  CameraApp
//
//  Created by Kenan Memmedov on 16.10.24.
//

import UIKit
import SnapKit
import AVFoundation
import Photos

class ViewController: UIViewController {

    private lazy var cameraButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Open camera"
        configuration.baseBackgroundColor = .red
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
        return button
    }()
    private lazy var libraryButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Open Library"
        configuration.baseBackgroundColor = .red
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        button.layer.cornerRadius = 16
        
        return button
    }()
    private let imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCons()
    }
    func setupView(){
        view.addSubview(cameraButton)
        view.addSubview(libraryButton)
        view.addSubview(imageView)
    }
    @objc func didTap(_ sender: UIButton){
        switch sender{
        case cameraButton:
            checkCameraPermission()
        case libraryButton:
            checkLibraryPermission()
        default:
            break
        }
    }
    func presentCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker,animated: true)
    }
    func presentLibrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker,animated: true)
    }
    
    func setupCons(){
        cameraButton.snp.makeConstraints{make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            make.leading.equalTo(view.snp.leading).offset(16)
        }
        libraryButton.snp.makeConstraints{make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.leading.equalTo(cameraButton.snp.trailing).offset(16)
        }
        imageView.snp.makeConstraints{make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
    }
    func checkCameraPermission(){
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
                guard let self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if isGranted{
                        presentCamera()
                    }
                    else{
                        dismiss(animated: true)
                    }
                }
            }
        case .restricted, .denied:
            if  let settingsUrl = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(settingsUrl)
            }
        case .authorized:
            presentCamera()
         default:
            break
        }
        
    }
    func checkLibraryPermission(){
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if status == .authorized{
                        presentLibrary()
                    }
                    else{
                        dismiss(animated: true)
                    }
                }
            }
        case .restricted , .denied:
            if let urlString = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(urlString)
            }
        case .authorized:
            presentLibrary()
        default:
            break
        }
    }
}
extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
            dismiss(animated: true)
        }
    }
    
}

