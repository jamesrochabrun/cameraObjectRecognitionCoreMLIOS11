//
//  ViewController.swift
//  ObjectCameraRecognitionCoreMLIOS11
//
//  Created by James Rochabrun on 8/27/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.

import UIKit
import AVKit
import Vision

class ViewController: UIViewController {
    
    //MARK: UI
    let opaqueLayer: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0.4
        return v
    }()
    
    let objectLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        l.textColor = UIColor.white
        l.font = UIFont.boldSystemFont(ofSize: 25)
        return l
    }()
    
    let holderLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        l.textColor = UIColor.white
        l.text = "I think this is a..."
        return l
    }()
    
    let accuracyLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor.white
        l.textAlignment = .center
        l.font = UIFont.boldSystemFont(ofSize: 30)
        return l
    }()
    
    let lineview: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white
        return v
    }()
    
    let descriptionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor.white
        l.textAlignment = .center
        l.sizeToFit()
        l.numberOfLines = 0
        return l
    }()
    
    let segmentedControl: UISegmentedControl = {
        let s = UISegmentedControl(items: ["SqueezeNet", "Resnet50", "GoogleNetPlaces"])
        s.tintColor = .white
        s.translatesAutoresizingMaskIntoConstraints = false
        s.selectedSegmentIndex = 0
        s.addTarget(self, action: #selector(valueChangedOnSegemented), for: .valueChanged)
        return s
    }()
    
    private var coreMLModel: MLModel = SqueezeNet().model
    private var modelDescription: String = "Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more. With an overall footprint of only 4.7 MB, SqueezeNet has a similar level of accuracy as AlexNet but with 50 times fewer parameters. \n\n File size: 5 MB"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configurateSession()
        self.setUpUI()
    }
    
    private func setUpUI() {
        
        view.addSubview(opaqueLayer)
        view.addSubview(objectLabel)
        view.addSubview(accuracyLabel)
        view.addSubview(segmentedControl)
        view.addSubview(lineview)
        view.addSubview(descriptionLabel)
        view.addSubview(holderLabel)
        
        NSLayoutConstraint.activate([
            
            opaqueLayer.topAnchor.constraint(equalTo: view.topAnchor),
            opaqueLayer.leftAnchor.constraint(equalTo: view.leftAnchor),
            opaqueLayer.rightAnchor.constraint(equalTo: view.rightAnchor),
            opaqueLayer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            lineview.leftAnchor.constraint(equalTo: view.leftAnchor),
            lineview.rightAnchor.constraint(equalTo: view.rightAnchor),
            lineview.heightAnchor.constraint(equalToConstant: 2),
            lineview.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),
            
            descriptionLabel.topAnchor.constraint(equalTo: lineview.bottomAnchor, constant: 10),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            
            segmentedControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            
            objectLabel.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: -15),
            objectLabel.heightAnchor.constraint(equalToConstant: 50),
            objectLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            objectLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            holderLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            holderLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            holderLabel.heightAnchor.constraint(equalToConstant: 30),
            holderLabel.bottomAnchor.constraint(equalTo: objectLabel.topAnchor),
            
            accuracyLabel.bottomAnchor.constraint(equalTo: holderLabel.topAnchor),
            accuracyLabel.heightAnchor.constraint(equalToConstant: 50),
            accuracyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            accuracyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            ])
    }
    
    private func configurateSession() {
        
        let captureSession = AVCaptureSession()
       // captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
         let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            captureSession.startRunning()
            self.configurePreviewLayerWith(session: captureSession)
            self.configureOutputIn(session: captureSession)
        } catch {
            print("\(error)")
        }
    }
    
    private func configurePreviewLayerWith(session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }
    
    private func configureOutputIn(session: AVCaptureSession) {
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(output)
    }
    
    @objc private func valueChangedOnSegemented() {
        
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            self.coreMLModel = SqueezeNet().model
            self.modelDescription = "Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more. With an overall footprint of only 4.7 MB, SqueezeNet has a similar level of accuracy as AlexNet but with 50 times fewer parameters. \n\n File size: 5 MB"
        case 1:
            self.coreMLModel = Resnet50().model
            self.modelDescription = "Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, people, and more. \n\n File size: 102.6 MB"
        case 2:
            self.coreMLModel = GoogLeNetPlaces().model
            self.modelDescription = "Detects the scene of an image from 205 categories such as an airport terminal, bedroom, forest, coast, and more. \n\n File size: 24.8 MB"
        default:
            break
        }
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //"output image provided by the camera"
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        //CORE ML REQUEST
        //https://developer.apple.com/machine-learning/
      //  let mlModel =
        guard let request = configureRequestWith(mLModel: self.coreMLModel) else { return }
        self.perform(request: request, with: pixelBuffer)
    }
}

//MARK: Core ML Methods
extension ViewController {

    //MARK: VNCoreMLRequest
    /*!
     @brief   The VNCoreMLRequest uses a VNCoreMLModel, that is based on a CoreML MLModel object, to run predictions with that model. Depending on the model the returned
     observation is either a VNClassificationObservation for classifier models, VNPixelBufferObservations for image-to-image models or VNMLFeatureValueObservation for everything else.
     */
    func configureRequestWith(mLModel: MLModel) -> VNCoreMLRequest? {
        
        //MARK: VNCoreMLModel
        guard let model = try? VNCoreMLModel(for: mLModel) else { return nil }
        
         return VNCoreMLRequest(model: model) { (req, err) in
            /*!
             @class VNClassificationObservation
             @superclass VNObservation
             @brief VNClassificationObservation returns the classifcation in form of a string.
             @discussion VNClassificationObservation is the observation returned by VNCoreMLRequests that using a model that is a classifier. A classifier produces an arrary (this can be a single entry) of classifications which are labels (identifiers) and confidence scores.
             
             */
            guard let results = req.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            self.updateUI(with: firstObservation)
        }
    }
    
    //MARK: VNImageRequestHandler
    /*!
     @brief Performs requests on a single image.
     @discussion The VNImageRequestHandler is created with an image that is used to be used for the requests a client might want to schedule. The VNImageRequestHandler retains, but never modifies, the image source for its entire lifetime. The client also must not modify the content of the image source once the VNImageRequestHandler is created otherwise the results are undefined.
     The VNImageRequestHandler can choose to also cache intermediate representation of the image or other request-specific information for the purposes of runtime performance.
     */
    func perform(request: VNCoreMLRequest, with pixelBuffer: CVPixelBuffer) {
        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        } catch {
            print("\(error)")
        }
    }
    
    func updateUI(with observation: VNClassificationObservation) {
        /*!
         * @brief The level of confidence normalized to [0, 1] where 1 is most confident
         * @discussion Confidence can always be returned as 1.0 if confidence is not supported or has no meaning
         */
        
        print("\(observation.identifier, observation.confidence)")
        DispatchQueue.main.async {
            self.objectLabel.text = observation.identifier.components(separatedBy: ",").first
            let percentage = observation.confidence * 100
            self.accuracyLabel.text = String(format: "%.2f", percentage) + "% Accuracy"
            self.descriptionLabel.text = self.modelDescription
        }
    }
}

enum CoreMLModels {
    case squeezeNet
    case resNet50
    case googleNetPlaces
}

/*
 Documentation:
 
 class in COREML and Vision
 VNCoreMLModel: the model added on the bundel provided by apple
 VNCoreMLRequest: the request for a CoreML model (the closure that contains the request)
 VNImageRequestHandler: the completion handler for the request
 VNClassificationObservation: the data of the object detected
 
 */










