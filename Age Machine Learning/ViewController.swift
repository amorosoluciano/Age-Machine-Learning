//
//  ViewController.swift
//  Age Machine Learning
//
//  Created by Luciano Amoroso on 24/03/2020.
//  Copyright © 2020 Luciano Amoroso. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

    }

      @IBAction func cameraTapped(_ sender: Any) {
          guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
               let alert = UIAlertController(title: "No camera", message: "Problem with camera!", preferredStyle: .alert)
               let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
               alert.addAction(ok)
               self.present(alert, animated: true, completion: nil)
               return
      }
          
          let picker = UIImagePickerController()
          picker.delegate = self
          picker.sourceType = .camera
          picker.cameraCaptureMode = .photo
          present(picker, animated: true, completion: nil)
  }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        // Set photoImageView to display the selected image.
        imageView.image = selectedImage

        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}


