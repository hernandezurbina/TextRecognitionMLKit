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
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        //imagePicker.sourceType = .camera
        imagePicker.sourceType = .photoLibrary
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let userPickedImage = info[UIImagePickerController.InfoKey.originalImage]
        
        imageView.image = userPickedImage as? UIImage
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

