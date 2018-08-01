//
//  JoinPartyViewController.swift
//  Mixed
//
//  Created by Jay Lees on 31/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class JoinPartyViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    private var blurView: UIVisualEffectView!
    private var codeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let infoView = UILabel(frame: CGRect(x: 60,
                                             y: 50,
                                             width: view.frame.width - 120,
                                             height: 45))
        infoView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        infoView.text = "Scan the host device"
        style(infoView)
        view.addSubview(infoView)
        
        blurView = UIVisualEffectView()
        blurView.frame = view.frame
        view.addSubview(blurView)
        
        let configuration = ARWorldTrackingConfiguration()
        
//        if #available(iOS 11.3, *) {
//            //setupAR(with: configuration)
//        } else {
            showPartyCodeEntry()
            //TODO
//        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapRecogniser)
    }
    
    // MARK: - UI Styling
    private func style(_ label: UILabel, size: CGFloat = 18){
        label.font = UIFont.mixedFont(size: size, weight: .bold)
        label.textColor = UIColor.white
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Actions
    @objc
    private func dismissKeyboard(){
        self.view.subviews.filter({$0 is UITextField}).forEach({$0.resignFirstResponder()})
    }
    
    @objc
    private func continueTapped(){
        dismissKeyboard()
        self.joinParty(with: codeTextField.text!)
    }
    
    // MARK: - Join Party
    fileprivate func joinParty(with id: String){
        Datastore.instance.joinParty(with: id) { (party) in
            guard let party = party else {
                showError(title: "No party found!", message: "No party was found with this ID!", controller: self)
                return
            }
            showError(title: "Whoooooo", message: "", controller: self)
        }
    }
    
    
    // MARK: - iOS 11.3+ AR Tracking
    @available(iOS 11.3, *)
    fileprivate func setupAR(with configuration: ARWorldTrackingConfiguration){
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionImages = referenceImages
    }

    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard #available(iOS 11.3, *) else {
//            return
//        }
//
//        guard let imageAnchor = anchor as? ARImageAnchor else { return }
//        let referenceImage = imageAnchor.referenceImage
//        DispatchQueue(label: "com.jaylees.mixed_ar").async {
//
//            // Create a plane to visualize the initial position of the detected image.
//            let geometry = SCNCapsule(capRadius: referenceImage.physicalSize.width / 14,
//                                      height: referenceImage.physicalSize.height / 2.3)
//
//            let backPlane = SCNPlane(width: referenceImage.physicalSize.width,
//                                     height: referenceImage.physicalSize.height)
//            let planeNode = SCNNode(geometry: backPlane)
//            planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "bg")
//
//
//            let leftCapsule = SCNNode(geometry: geometry)
//            let leftMidCapsule = SCNNode(geometry: geometry)
//            let rightMidCapsule = SCNNode(geometry: geometry)
//            let rightCapsule = SCNNode(geometry: geometry)
//
//            // Correct orientation
//            leftCapsule.eulerAngles.y = -degreesToRadians(25)
//            leftMidCapsule.eulerAngles.y = degreesToRadians(25)
//            rightMidCapsule.eulerAngles.y = -degreesToRadians(25)
//            rightCapsule.eulerAngles.y = degreesToRadians(25)
//
//
//            [leftCapsule, leftMidCapsule, rightMidCapsule, rightCapsule].forEach({ (node) in
//                node.geometry?.firstMaterial?.diffuse.contents = UIColor.black
//                node.eulerAngles.z = 0.01
//            })
//
//            //Spacing
//            leftCapsule.position.x -= 0.02
//            leftMidCapsule.position.x -= 0.007
//            rightMidCapsule.position.x += 0.007
//            rightCapsule.position.x += 0.02
//
//            [leftCapsule, leftMidCapsule, rightMidCapsule, rightCapsule, planeNode].forEach { capsule in
//                capsule.eulerAngles.x = -.pi/2
//                node.addChildNode(capsule)
//            }
//
//            let changeColor = SCNAction.customAction(duration: 2) { (node, elapsedTime) -> () in
//                let percentage = elapsedTime
//                let color = UIColor(red: percentage, green: percentage, blue: percentage, alpha: 1)
//                node.geometry!.firstMaterial!.diffuse.contents = color
//            }
//
//            let action: SCNAction =
//                .sequence([
//                    .wait(duration: 2),
//                    .group([.moveBy(x: 0, y: 0.2, z: 0, duration: 0.5), changeColor]),
//                    ])
//
//            [leftCapsule, leftMidCapsule, rightMidCapsule, rightCapsule].forEach({ (node) in
//                node.runAction(action, completionHandler: {
//
//                })
//            })
//        }
//    }
    
    func showPartyCodeEntry(){
        codeTextField = UITextField(frame: CGRect(x: 30, y: view.frame.height / 2 - 25, width: view.frame.width - 60, height: 50))
        let title = UILabel(frame: CGRect(x: 60, y: 60, width: view.frame.width - 120, height: 64))
        
        let lineView = LineView(frame: CGRect(x: codeTextField.frame.origin.x, y: codeTextField.frame.origin.y + codeTextField.frame.height - 5, width: codeTextField.frame.width, height: 3))
        let placeholder = NSAttributedString(string: "What's the party code?", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        let button = OnboardingButton(frame: CGRect(x: 100, y: view.frame.height - 150, width: view.frame.width - 200, height: 55))
        button.setTitle("CONTINUE", for: .normal)
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        
        style(title, size: 24)
        title.text = "Enter code to join party"
        title.numberOfLines = 2
        
        codeTextField.font = UIFont.mixedFont(size: 24)
        codeTextField.textColor = UIColor.white
        codeTextField.attributedPlaceholder = placeholder
        codeTextField.returnKeyType = .go
        codeTextField.delegate = self
        codeTextField.autocorrectionType = .no
        codeTextField.autocapitalizationType = .none
        
        [codeTextField, lineView, title, button].forEach { v in
            v!.alpha = 0
            view.addSubview(v!)
        }
        
        UIView.animate(withDuration: 2, animations: {
            self.blurView.effect = UIBlurEffect(style: .dark)
            self.codeTextField.alpha = 1
            title.alpha = 1
            
            lineView.alpha = 1
            button.alpha = 1
        })
    }
}

extension JoinPartyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        self.joinParty(with: textField.text!)
        return true
    }
}


func degreesToRadians(_ deg: Float) -> Float {
    return deg * (.pi / 180)
}

