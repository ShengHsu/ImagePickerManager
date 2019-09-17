//
//  ViewController.swift
//  ImagePickerManager
//
//  Created by APPLE on 2019/9/17.
//  Copyright © 2019 APPLE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var mImageView_Main: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func Click_PickPhoto(_ sender: UIButton) {
        ImagePickerManager().pickImage(self){ (image, url) in
            print(url)
            self.mImageView_Main.image = image
        }
    }
}

