//
//  ViewController.swift
//  TextRecognitionMLKit
//
//  Created by Victor Hernandez-Urbina on 27/03/2019.
//  Copyright © 2019 Victor Hernandez-Urbina. All rights reserved.
//

import UIKit
import FirebaseMLVision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    var textRecognizer: VisionTextRecognizer!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var findTextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        findTextButton.isEnabled = false
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        //imagePicker.sourceType = .camera
        imagePicker.sourceType = .photoLibrary
        
        let vision = Vision.vision()
        textRecognizer = vision.onDeviceTextRecognizer()
        
    }

    // MARK: Camera button functionality
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Image picking
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let userPickedImage = info[UIImagePickerController.InfoKey.originalImage]
        
        imageView.image = userPickedImage as? UIImage
        
        imagePicker.dismiss(animated: true, completion: {
            self.findTextButton.isEnabled = true
        })
    }
    
    // MARK: Find Text button functionality
    @IBAction func findTextDidTouch(_ sender: UIBarButtonItem) {
        runTextRecognition(with: imageView.image!)
    }
    
    // MARK: Text Recognition
    func runTextRecognition(with image: UIImage){
        let visionImage = VisionImage(image: image)
        textRecognizer.process(visionImage) { (features, error) in
            self.processResult(from: features, error: error)
        }
    }
    
    // MARK: Image Drawing:
    func processResult(from text: VisionText?, error: Error?){
        //removeFrames()
        guard let features = text, let image = imageView.image else {return}
        
        for block in features.blocks{
            
//            let blockText = block.text
//            print(blockText)
//            print()
            
            for line in block.lines{

//                let lineText = line.text
//                print(lineText)
//                print()
                
                for element in line.elements{
                    //self.addFrameView(featureFrame: element.frame, imageSize: image.size, viewFrame: self.imageView.frame, text: element.text)
                    
                    let elementText = element.text
                    print(elementText)
                    print()
                    
                }
            }
        }
        
    }
    
    func addFrameView(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect, text: String? = nil){
        print("Frame: \(featureFrame)")
    }
    
}

