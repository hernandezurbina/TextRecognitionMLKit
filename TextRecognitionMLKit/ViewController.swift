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
    @IBOutlet weak var pubTitleLabel: UILabel!
    @IBOutlet weak var authorsTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        findTextButton.isEnabled = false
        
        pubTitleLabel.text = ""
        authorsTitleLabel.text = ""
        
        imagePicker.delegate = self
//        imagePicker.allowsEditing = false
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        
        //imagePicker.modalPresentationStyle = .overCurrentContext
        //imagePicker.sourceType = .photoLibrary
        
        let vision = Vision.vision()
        textRecognizer = vision.onDeviceTextRecognizer()
                
    }

    // MARK: Camera button functionality
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Image picking
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        imageView.image = userPickedImage
        
        if Float((userPickedImage?.size.height)!) > Float((userPickedImage?.size.width)!) {
            print("portrait")
            // do nothing
        }
        else {
            print("landscape")
            // rotate image!
            //imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        
        
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

        guard let features = text else {return}
        
        var textBlock = [String]()
        
        for block in features.blocks{
            print(block.text)
            print()
            
            textBlock.append(block.text)
            
//            for line in block.lines{
//                print(line.text)
//                print()
//                for element in line.elements{
//                    let elementText = element.text
//                    let elementFrame = element.frame
//                    let scaledElementFrame = createScaledFrame(featureFrame: elementFrame, imageSize: image.size, viewFrame: imageView.frame)
//
//                    let layer = CAShapeLayer()
//                    layer.path = UIBezierPath(rect: scaledElementFrame).cgPath
//                    layer.strokeColor = Constants.lineColor
//                    layer.fillColor = Constants.fillColor
//                    layer.lineWidth = Constants.lineWidth
//                    view.layer.addSublayer(layer)
//
//                    print(elementText)
//                    print()
//
//                }
//            }
        }
        pubTitleLabel.text = textBlock[0]
        authorsTitleLabel.text = textBlock[1]

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
            let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale
            
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

//extension UIImagePickerController
//{
//    override open var shouldAutorotate: Bool {
//        return true
//    }
//    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
//        return .all
//    }
//}

extension ViewController {
    func imageOrientation(_ src:UIImage)->UIImage {
        if src.imageOrientation == UIImage.Orientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Float.pi))
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Float.pi / 2))
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-(Float.pi / 2)))
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        
        return img
    }
}
