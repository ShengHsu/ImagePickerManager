//
//  UIImageExt.swift
//  ImagePickerManager
//
//  Created by APPLE on 2019/9/17.
//  Copyright © 2019 APPLE. All rights reserved.
//

import UIKit

extension UIImage {
    func reSizeImage (reSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width,height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    func scaleImage (scaleSize:CGFloat) -> UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
