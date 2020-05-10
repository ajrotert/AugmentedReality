//
//  ViewController.swift
//  ARDemo
//
//  Created by Andrew Rotert on 5/7/20.
//  Copyright © 2020 Andrew Rotert. All rights reserved.
//

import ARKit
import UIKit

let kStartingPosition = SCNVector3(0, 0, 0)
let kAnimationDurationMoving: TimeInterval = 0.2
var kMovingLengthPerLoop: CGFloat = 5
let kRotationRadianPerLoop: CGFloat = 0.05



extension ViewController : UIDocumentPickerDelegate,UINavigationControllerDelegate {

    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("filename: " + url.path.split(separator: "/").last!)
        print("Rel Path: " + url.relativePath)
        print("Rel String: " + url.relativeString)
        print("URL Path: " + url.path)
        print("Path: " + url.standardizedFileURL.absoluteString)
                
        addObject(urlpath: url)

    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}

class ViewController: UIViewController {
        
    let documentInteractionController = UIDocumentInteractionController()
    
    
    
    
    enum Options: String{
        case cyberTruck = "Tesla CyberTruck"
        case animal = "Dog"
        case custom = "Use Your Own"
    }
    
    @IBOutlet var MenuOptions: [UIButton]!
    
    @IBAction func SelectObjectButton(_ sender: UIButton) {
        MenuOptions.forEach{(button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    @IBAction func ObjectClicked(_ sender: UIButton) {
        guard let title = sender.currentTitle, let option = Options(rawValue: title) else { return }
    
        var path = ""
        switch option{
        case .cyberTruck:
            path = Objects.CyberTruckPath
        case .animal:
            path = Objects.Animal
        case .custom:
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            present(importMenu, animated: true, completion: nil)
        }
        addObject(path: path)
        SelectObjectButton(sender)
    }
    
    @IBOutlet weak var sceneAR: ARSCNView!
        
    @IBOutlet weak var UpButton: UIButton!
    @IBOutlet weak var LeftButton: UIButton!
    @IBOutlet weak var RightButton: UIButton!
    @IBOutlet weak var DownButton: UIButton!
    @IBOutlet weak var AwayButton: UIButton!
    @IBOutlet weak var RLeftButton: UIButton!
    @IBOutlet weak var RRightButton: UIButton!
    @IBOutlet weak var CloserButton: UIButton!
    @IBOutlet weak var FreeButton: UIButton!
    @IBOutlet weak var Slider: UISlider!
    
    @IBAction func Up(_ sender: Any) {
        let x = deltas().sin
        let z = deltas().cos
        moveObject(x: x, z: z, sender: sender)
    }
    @IBAction func Left(_ sender: Any) {
        let x = -deltas().cos
        let z = deltas().sin
        moveObject(x: x, z: z, sender: sender)
    }
    @IBAction func Right(_ sender: Any) {
        let x = deltas().cos
        let z = -deltas().sin
        moveObject(x: x, z: z, sender: sender)
    }
    @IBAction func Down(_ sender: Any) {
        let x = -deltas().sin
        let z = -deltas().cos
        moveObject(x: x, z: z, sender: sender)
    }
    
    @IBAction func Away(_ sender: Any) {
        let action = SCNAction.moveBy(x: 0, y: kMovingLengthPerLoop, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    @IBAction func RLeft(_ sender: Any) {
        rotateObject(yRadian: kRotationRadianPerLoop, sender: sender)
    }
    @IBAction func RRight(_ sender: Any) {
        rotateObject(yRadian: -kRotationRadianPerLoop, sender: sender)
    }
    @IBAction func Closer(_ sender: Any) {
        let action = SCNAction.moveBy(x: 0, y: -kMovingLengthPerLoop, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    @IBAction func ResizeClicked(_ sender: UIButton) {
        if(sceneAR.allowsCameraControl)
        {
            sceneAR.scene = sceneAR.scene
            sender.setTitle("Allow Frre Float", for: UIControl.State.normal)
        }
        else{
            sender.setTitle("Reset to Fixed", for: UIControl.State.normal)
        }
        sceneAR.allowsCameraControl = !sceneAR.allowsCameraControl
    }
    @IBAction func SliderChanged(_ sender: UISlider) {
        let unit = sender.value
        kMovingLengthPerLoop = CGFloat(unit)
    }
    
    var object = Objects()
    
    var geometryNode: SCNNode = SCNNode()
    var currentAngle: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupConfiguration()
    }
    
    func setupScene() {
        let scene = SCNScene()
        sceneAR.autoenablesDefaultLighting = true
        sceneAR.allowsCameraControl = false
        sceneAR.scene = scene
    }
    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        sceneAR.session.run(configuration)
    }
    func addObject(path: String) {
        print("addObject")
        object.removeFromParentNode()
        object = Objects()
        object.loadModel(filename: path)
        object.position = kStartingPosition
        object.rotation = SCNVector4Zero
        sceneAR.scene.rootNode.addChildNode(object)

    }
    func addObject(urlpath: URL) {
        print("addObject 2")
        object.removeFromParentNode()
        object = Objects()
        object.loadModel(urlname: urlpath)
        object.position = kStartingPosition
        object.rotation = SCNVector4Zero
        sceneAR.scene.rootNode.addChildNode(object)

    }
    

    private func moveObject(x: CGFloat, z: CGFloat, sender: Any) {
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    private func deltas() -> (sin: CGFloat, cos: CGFloat) {
        return (sin: kMovingLengthPerLoop * CGFloat(sin(object.eulerAngles.y)), cos: kMovingLengthPerLoop * CGFloat(cos(object.eulerAngles.y)))
    }
    
    private func rotateObject(yRadian: CGFloat, sender: Any) {
        let action = SCNAction.rotateBy(x: 0, y: yRadian, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    private func execute(action: SCNAction, sender: Any) {
        let loopAction = SCNAction.repeat(action, count: 6)
        object.runAction(loopAction)
    }
}


