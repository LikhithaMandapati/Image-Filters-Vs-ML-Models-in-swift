//
//  ViewController.swift
//  Exam3_Mandapati_Likhitha
//
//  Created by student on 11/17/22.
//

import UIKit
import Foundation
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var twentyFivePercent: UIButton!
    @IBOutlet weak var seventyFivePercnt: UIButton!
    @IBOutlet weak var classificationLabel: UILabel!
    
    
    var originalImage = UIImage(named: "nature_1.png")
    var context = CIContext()
        
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        twentyFivePercent.isEnabled = false
        seventyFivePercnt.isEnabled = false
        
        imageView.image = originalImage
        
        classifyImage()
        selectButton.tintColor = UIColor(red: 45/255, green: 70/255, blue: 185/255, alpha: 1)
        
        selectButton.contentVerticalAlignment = .fill
        selectButton.contentHorizontalAlignment = .fill
      
        
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            guard let selectedImage = info[.originalImage] as? UIImage else {
                fatalError("Expected an image, but was provided the following: \(info)")
            }
            
            imageView.image = selectedImage
            originalImage = selectedImage
            classifyImage()
            dismiss(animated: true, completion: nil)
        }
    
    func loadImageFromGallery() {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                picker.allowsEditing = false
                picker.sourceType = .photoLibrary
                picker.delegate = self
                present(picker, animated: true, completion: nil)
            }
        }
    
    func getFilterFromSegmentIdx(segmentIdx: Int, inputCIImage: CIImage, intensity: Double) -> CIFilter {
        
       
        //let intensity: Double = 0.2
        
        if segmentIdx == 1 || segmentIdx == 2 || segmentIdx == 3 {
            twentyFivePercent.isEnabled = true
            seventyFivePercnt.isEnabled = true
        }
            if segmentIdx == 1 {
                return CIFilter(name: "CIGaussianBlur", parameters: ["inputImage": inputCIImage, "inputRadius": 10*intensity])!
                
            } else if segmentIdx == 2 {
                return CIFilter(name: "CIColorThreshold", parameters: ["inputImage": inputCIImage, "inputThreshold": 0.5*intensity])!
            } else {
                return CIFilter(name: "CISepiaTone", parameters: ["inputImage": inputCIImage, "inputIntensity": 1*intensity])!
            }
        
        }
    
    func filterImage(inputImg : UIImage, segmentIdx: Int, intensity: Double) -> UIImage? {
            guard let inputCIImage = CIImage(image: inputImg) else {
                return nil
            }
        
        let filter = getFilterFromSegmentIdx(segmentIdx: segmentIdx, inputCIImage: inputCIImage, intensity: 0.2)
            classifyImage()
            guard let ciImageResult = filter.outputImage else {
                return nil
            }
            
            if let _cgImage = context.createCGImage(ciImageResult, from: ciImageResult.extent) {
                let originalOrientation = inputImg.imageOrientation
                let originalScale = inputImg.scale
                return UIImage(cgImage: _cgImage, scale: originalScale, orientation: originalOrientation)
            }
            
            return nil
        }
    
    @IBAction func selectImage(_ sender: Any) {
        loadImageFromGallery()
        
    }
    
    @IBAction func twentyFivePercentFunc(_ sender: Any) {
        //let intensity: Double = 0.25
        
        guard let img = self.originalImage else {
                    return
                }
        if (sender as AnyObject).selectedSegmentIndex == 0 {
                    self.imageView.image = img

        } else if  let image = self.filterImage(inputImg: img, segmentIdx: 1, intensity: 0.25) {
                    self.imageView.image = image
                } else if  let image = self.filterImage(inputImg: img, segmentIdx: 2, intensity: 0.25) {
                    self.imageView.image = image
                }else if  let image = self.filterImage(inputImg: img, segmentIdx: 3, intensity: 0.25) {
                    self.imageView.image = image
                }
        
        
        
    }
    @IBAction func seventyFivePercentFunc(_ sender: Any) {
        guard let img = self.originalImage else {
                    return
                }
        if (sender as AnyObject).selectedSegmentIndex == 0 {
                    self.imageView.image = img

        } else if  let image = self.filterImage(inputImg: img, segmentIdx: 1, intensity: 0.75) {
                    self.imageView.image = image
                } else if  let image = self.filterImage(inputImg: img, segmentIdx: 2, intensity: 0.75) {
                    self.imageView.image = image
                }else if  let image = self.filterImage(inputImg: img, segmentIdx: 3, intensity: 0.75) {
                    self.imageView.image = image
                }
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        guard let img = self.originalImage else {
                    return
                }

        if (sender as AnyObject).selectedSegmentIndex == 0 {
                    self.imageView.image = img

        } else if let image = self.filterImage(inputImg: img, segmentIdx: (sender as AnyObject).selectedSegmentIndex, intensity: 0.2) {
                    self.imageView.image = image
                }
    }
    
    func classifyImage() {
        guard let ciImage = CIImage(image: imageView.image!) else {
            fatalError("failed to convert UIImage to CIImage!")
        }
        let config = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: Resnet50(configuration: config).model) else {
            fatalError("failed to load ML model!")
        }
        //classificationLabel.text = "Classifying image..."
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            let results = request.results as? [VNClassificationObservation]
            var classificationResulltText = ""
            for result in results! {
                classificationResulltText += "\(Int(result.confidence * 100))% \(result.identifier) \n"
            }
            
            DispatchQueue.main.async {
                self?.classificationLabel.text! = classificationResulltText
            }
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    
}

