//
//  CameraViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
import AVKit
import Mantis
protocol CameraViewControllerDelegate {
    func didFinishImagePicker(origin: UIImage?, crop: UIImage?)
}
class CameraViewController: UIViewController {
    
    var sourceType: UIImagePickerController.SourceType? = nil
    var imagePicker: UIImagePickerController? = nil
    var overlayView: CameraOverlayView? = nil
    var delegate: CameraViewControllerDelegate?
    
    var originImg: UIImage?
    var isFirst:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if isFirst == false {
            isFirst = true
            self.checkPermissionAfterShowImagePicker()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func checkPermissionAfterShowImagePicker() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == AVAuthorizationStatus.denied {
            let alert = UIAlertController.init(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "취소", style: .cancel, handler: { (action) in
                alert.dismiss(animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction.init(title: "설정", style: .default, handler: { (action) in
                
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                } else {
                    alert.dismiss(animated: false, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if authStatus == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [self] granted in
                if granted {
                    DispatchQueue.main.async(execute: { [self] in
                        displayImagePicker()
                    })
                }
            })
        }
        else {
            displayImagePicker()
        }
    }
    
    func displayImagePicker() {
        self.imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.modalPresentationStyle = .fullScreen
        imagePicker?.modalTransitionStyle = .crossDissolve
        
        if sourceType == UIImagePickerController.SourceType.camera {
            imagePicker?.sourceType = UIImagePickerController.SourceType.camera
            imagePicker?.navigationController?.navigationBar.isHidden = true
            imagePicker?.toolbar.isHidden = true
            imagePicker?.allowsEditing = false
            imagePicker?.showsCameraControls = false
         
            let scrrenRect = UIScreen.main.bounds
            overlayView = Bundle.main.loadNibNamed("CameraOverlayView", owner: nil, options: nil)?.first as? CameraOverlayView
            
            overlayView?.frame = scrrenRect
            overlayView?.delegate = self
            imagePicker?.cameraOverlayView = overlayView
            
            let ratio: Float = 4.0/3.0
            let imageHeight : Float = floorf(Float(scrrenRect.width)*ratio)
            let scale: Float = Float(scrrenRect.height)/imageHeight
            let trans: Float = (Float(scrrenRect.height) - imageHeight) / 2
            let translate = CGAffineTransform(translationX: 0.0, y: CGFloat(trans))
            let final = translate.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
            
            imagePicker?.cameraViewTransform = final
        }
        else {
            imagePicker?.allowsEditing = false
            imagePicker?.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        self.present(imagePicker!, animated: true, completion: nil)
    }
}
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false) {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let orgImg = info[UIImagePickerController.InfoKey.originalImage]
        if let orgImg = orgImg {
            self.originImg = (orgImg as! UIImage)
            picker.dismiss(animated: false) {
                let vc = Mantis.cropViewController(image: orgImg as! UIImage)
                vc.delegate = self
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
}

extension CameraViewController: CameraOverlayViewDelegate {
    func cameraOverlayViewCancelAction() {
        imagePicker?.dismiss(animated: false) {
            self.navigationController?.popViewController(animated: false)
        }
    }
    func cameraOverlayViewShotAction() {
        self.imagePicker?.takePicture()
    }
}

extension CameraViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: false) {
            self.delegate?.didFinishImagePicker(origin: self.originImg, crop: cropped)
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: false) {
            self.navigationController?.popViewController(animated: false)
        }
    }
}
