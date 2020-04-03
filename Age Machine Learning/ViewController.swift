//
//  ViewController.swift
//  Age Machine Learning
//
//  Created by Luciano Amoroso on 24/03/2020.
//  Copyright © 2020 Luciano Amoroso. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var galleryBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var roundendBtn2: UIButton!
    @IBOutlet weak var roundendBtn: UIButton!
    @IBOutlet weak var labelAge: UILabel!
    @IBOutlet weak var labelGender: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        roundendBtn.layer.cornerRadius = roundendBtn.frame.height / 2
        roundendBtn.backgroundColor = UIColor.white
        roundendBtn.layer.borderWidth = 1.0
        roundendBtn.layer.borderColor = UIColor.gray.cgColor
        roundendBtn2.layer.cornerRadius = roundendBtn2.frame.height / 2
        roundendBtn2.backgroundColor = UIColor.white
        roundendBtn2.layer.borderWidth = 1.0
        roundendBtn2.layer.borderColor = UIColor.gray.cgColor

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
    @IBAction func galleryTapped(_ sender: Any) {
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                 let alert = UIAlertController(title: "No photo library", message: "Problem with photo library!", preferredStyle: .alert)
                 let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                 alert.addAction(ok)
                 self.present(alert, animated: true, completion: nil)
                 return
        }
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard var selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        imageView.image = selectedImage
        selectedImage = resizeImage(image: selectedImage, newWidth: 125)
//        I try also to set width to 120, it's a little inaccurate but always worked

        guard let ciImage = CIImage(image: selectedImage) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        detectAge(image: ciImage)
        detectGender(image: ciImage)

        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
 func detectAge(image: CIImage) {
             labelAge.text = "Detecting age..."
             // Load the ML model through its generated class
             guard let model = try? VNCoreMLModel(for: AgeNet().model) else {
                  fatalError("can't load AgeNet model")
             }
             // Create request for Vision Core ML model created
             let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                 guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                       fatalError("unexpected result type from VNCoreMLRequest")
                 }

                 // Update UI on main queue
                 DispatchQueue.main.async { [weak self] in
                    self?.labelAge.text = "I think your age is \(topResult.identifier) years!                                   (\(Int(topResult.confidence * 100))% of confidence)"
                 }
            }

            // Run the Core ML AgeNet classifier on global dispatch queue
            let handler = VNImageRequestHandler(ciImage: image)
                  DispatchQueue.global(qos: .userInteractive).async {
                  do {
                      try handler.perform([request])
                  } catch {
                      print(error)
                  }
            }
    }
    
    func detectGender(image: CIImage) {
                labelGender.text = "Detecting gender..."
                // Load the ML model through its generated class
                guard let model = try? VNCoreMLModel(for: GenderClass_1().model) else {
                     fatalError("can't load GenderNet model")
                }
                // Create request for Vision Core ML model created
                let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                    guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                          fatalError("unexpected result type from VNCoreMLRequest")
                    }

                    // Update UI on main queue
                    DispatchQueue.main.async { [weak self] in
                          self?.labelGender.text = "I think your gender is \(topResult.identifier) years!"
                    }
               }

               // Run the Core ML AgeNet classifier on global dispatch queue
               let handler = VNImageRequestHandler(ciImage: image)
                     DispatchQueue.global(qos: .userInteractive).async {
                     do {
                         try handler.perform([request])
                     } catch {
                         print(error)
                     }
               }
       }
    
     func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }


}


