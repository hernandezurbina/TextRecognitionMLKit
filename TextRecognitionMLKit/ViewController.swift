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
    
    @IBAction func trashButtonPressed(_ sender: UIBarButtonItem) {
        removeFrames()
    }
    
    // MARK: Image Drawing:
    func processResult(from text: VisionText?, error: Error?){
        //removeFrames()
        guard let features = text, let image = imageView.image else {return}
        
        for block in features.blocks{
            for line in block.lines{
                for element in line.elements{
                    let elementText = element.text
                    let elementFrame = element.frame
                    let scaledElementFrame = createScaledFrame(featureFrame: elementFrame, imageSize: image.size, viewFrame: imageView.frame)

                    let layer = CAShapeLayer()
                    layer.path = UIBezierPath(rect: scaledElementFrame).cgPath
                    layer.strokeColor = Constants.lineColor
                    layer.fillColor = Constants.fillColor
                    layer.lineWidth = Constants.lineWidth
                    view.layer.addSublayer(layer)
//                    self.frameSublayer.addSublayer(layer)
                    
                    print(elementText)
                    print()
                    
                }
            }
        }
        

    }
    
    // MARK: Highlighting Text Frames:
    private enum Constants{
        static let lineWidth: CGFloat = 3.0
        static let lineColor = UIColor.yellow.cgColor
        static let fillColor = UIColor.clear.cgColor
    }

    // 1
    private func createScaledFrame(
        featureFrame: CGRect,
        imageSize: CGSize, viewFrame: CGRect)
        -> CGRect {
            let viewSize = viewFrame.size
            
            // 2
            let resolutionView = viewSize.width / viewSize.height
            let resolutionImage = imageSize.width / imageSize.height
            
            // 3
            var scale: CGFloat
            if resolutionView > resolutionImage {
                scale = viewSize.height / imageSize.height
            } else {
                scale = viewSize.width / imageSize.width
            }
            
            // 4
            let featureWidthScaled = featureFrame.size.width * scale
            let featureHeightScaled = featureFrame.size.height * scale
            
            // 5
            let imageWidthScaled = imageSize.width * scale
            let imageHeightScaled = imageSize.height * scale
            let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
            let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2
            
            // 6
            let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale
            let featurePointYScaled = 60 - imagePointYScaled + featureFrame.origin.y * scale
            
            // 7
            return CGRect(x: featurePointXScaled,
                          y: featurePointYScaled,
                          width: featureWidthScaled,
                          height: featureHeightScaled)
    }

    private func removeFrames() {
        guard let sublayers = view.layer.sublayers else { return }
        
        for sublayer in sublayers {
            if type(of: sublayer) != CALayer.self {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
}

