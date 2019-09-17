//
//  ImagePickerManager.swift
//  ImagePickerManager
//
//  Created by APPLE on 2019/9/17.
//  Copyright © 2019 APPLE. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController()
    var alert = UIAlertController(title: "选择", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage, URL) -> ())?
    
    override init(){
        super.init()
    }
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage, URL) -> ())) {
        pickImageCallback = callback
        self.viewController = viewController
        
        let cameraAction = UIAlertAction(title: "开启相机", style: .default){
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "选择照片", style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel){
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        if let popoverPresentationController = self.alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.viewController!.view
            popoverPresentationController.sourceRect = CGRect(x: self.viewController!.view.bounds.midX, y: self.viewController!.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        viewController.present(self.alert, animated: true, completion: { () in
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.isFull = false
        })
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = false
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    if(UIImagePickerController .isSourceTypeAvailable(.camera)){
                        self.viewController!.present(self.picker, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "通知讯息", message: "您无法使用相机", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: { action in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self.viewController?.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    //access denied
                    let alert = UIAlertController(title: "通知讯息", message: "请开启相机使用权限", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: { action in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.viewController?.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String, kUTTypeImage as String]
        picker.allowsEditing = false
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker.sourceType == .camera {
            var selectedImage: UIImage!
            if let image = info[.editedImage] as? UIImage {
                selectedImage = image
            } else if let image = info[.originalImage] as? UIImage {
                selectedImage = image
            }
            selectedImage = selectedImage.scaleImage(scaleSize: 0.1)
            
            let imgName = "pick_filename.png"
            let documentDirectory = NSTemporaryDirectory()
            let localPath = documentDirectory.appending(imgName)
            let data = selectedImage.pngData()! as NSData
            data.write(toFile: localPath, atomically: true)
            let photoURL = URL.init(fileURLWithPath: localPath)
            selectedImage.accessibilityIdentifier = "picture"
            pickImageCallback? (selectedImage, photoURL)
        } else if picker.sourceType == .photoLibrary {
            if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
                /*
                 let imgName = imgUrl.lastPathComponent
                 let documentDirectory = NSTemporaryDirectory()
                 let localPath = documentDirectory + "edit_" + imgName
                 */
                var image : UIImage!
                if let img = info[.editedImage] as? UIImage {
                    image = img
                    /*
                     let data = image.pngData()! as NSData
                     data.write(toFile: localPath, atomically: true)
                     let photoURL = URL.init(fileURLWithPath: localPath)
                     print(photoURL)
                     */
                } else if let img = info[.originalImage] as? UIImage {
                    image = img
                }
                image.accessibilityIdentifier = "picture"
                pickImageCallback? (image, imgUrl)
            } else if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                guard let videoSnapShot = thumbnailImageFor(fileUrl: videoUrl) else {
                    fatalError("\(info)")
                }
                videoSnapShot.accessibilityIdentifier = "video"
                pickImageCallback? (videoSnapShot, videoUrl)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func thumbnailImageFor(fileUrl:URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print(error)
            return nil
        }
    }
}

