//
//  ViewController.swift
//  ch08-1692148-cameraCoreML
//
//  Created by mac028 on 2021/04/22.
//

import UIKit
import Vision
import CoreML

class StillImageViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var request: VNCoreMLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(takePicture))
        imageView.addGestureRecognizer(tapGesture)
        
        messageLabel.layer.borderWidth = 2
        messageLabel.layer.borderColor = UIColor.red.cgColor
        
        request = createCoreMLRequest(modelName: "SqueezeNet", modelExt: "mlmodelc", completionHandler: handleInageClassfier)
        
        //반드시 설정하여야 한다
        imageView.isUserInteractionEnabled = true
    }
}

extension StillImageViewController {
    @objc func takePicture(sender: UITapGestureRecognizer) {
                let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
        } else {
            imagePickerController.sourceType = .photoLibrary
        }
        
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension StillImageViewController {
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        imageView.image = image
        
        let handler = VNImageRequestHandler(ciImage: CIImage(image: image)!)
        
        try! handler.perform([request])
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension StillImageViewController {
    func createCoreMLRequest(modelName: String, modelExt: String, completionHandler: @escaping (VNRequest, Error?) -> Void) -> VNCoreMLRequest? {
        guard  let modelURL = Bundle.main.url(forResource: modelName, withExtension: modelExt) else {
            return nil
        }
        
        guard let vnCoreMLModel = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL)) else {
            return nil
        }
        
        return VNCoreMLRequest(model: vnCoreMLModel, completionHandler: completionHandler)
    }
    
    func handleInageClassfier(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        if let topResult = results.first {
            DispatchQueue.main.async {
                self.messageLabel.text = "\(topResult.identifier)입니다. 아무곳이나 클릭하세요."
            }
        }
    }
}
