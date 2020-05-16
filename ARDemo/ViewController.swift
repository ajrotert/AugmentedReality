//
//  ViewController.swift
//  ARDemo
//
//  Created by Andrew Rotert on 5/7/20.
//  Copyright © 2020 Andrew Rotert. All rights reserved.
//

import ARKit
import UIKit
import MobileCoreServices

let kAnimationDurationMoving: TimeInterval = 0.2
var kMovingLengthPerLoop: CGFloat = 0.05
let kRotationRadianPerLoop: CGFloat = 0.05
var planeColorHidden: Bool = false

extension ViewController : UIDocumentPickerDelegate,UINavigationControllerDelegate {

    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        self.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("filename: " + url.path.split(separator: "/").last!)
        print("Rel Path: " + url.relativePath)
        print("Rel String: " + url.relativeString)
        print("URL Path: " + url.path)
        print("Path: " + url.standardizedFileURL.absoluteString)
               
        if(!url.path.lowercased().contains(".obj") && !url.path.lowercased().contains(".dae") && !url.path.lowercased().contains(".usdz") && !url.path.lowercased().contains(".usda") && !url.path.lowercased().contains(".usd") && !url.path.lowercased().contains(".usdc") && !url.path.lowercased().contains(".abc") && !url.path.lowercased().contains(".ply") && !url.path.lowercased().contains(".stl") && !url.path.lowercased().contains(".scn") ){
            print("Multiple files selected")
            
            var urlpath = url.deletingLastPathComponent()
            let fileManager = FileManager.default
            
            do{
            let files = try fileManager.contentsOfDirectory(atPath: urlpath.path)
                for file in files{
                    if(file.lowercased().contains(".dae") || file.lowercased().contains(".usdz") || file.lowercased().contains(".usda") || file.lowercased().contains(".usd") || file.lowercased().contains(".usdc") || file.lowercased().contains(".abc") || file.lowercased().contains(".ply") || file.lowercased().contains(".stl") || file.lowercased().contains(".scn") || file.lowercased().contains(".obj"))
                    {
                        urlpath.appendPathComponent(file)
                        print("New URL: ", urlpath.path)
                    }
                    addObject(urlpath: urlpath)
                }
            }
            catch{
                print("file error")
            }
            
        }
        else{
            addObject(urlpath: url)
        }

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
        case formula = "Formula One"
        case custom = "Use Your Own"
    }
    
    @IBOutlet var MenuOptions: [UIButton]!
    @IBOutlet weak var SelectOptions: UIButton!
    
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
        case .formula:
            path = Objects.Formula
        case .custom:
            
            let types: [String] = [kUTTypeItem as String]
            let importMenu = UIDocumentPickerViewController(documentTypes: types, in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            importMenu.allowsMultipleSelection = true
            present(importMenu, animated: false, completion: nil)
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
    @IBOutlet weak var DebugLabel: UIButton!
    
    @IBAction func Debug(_ sender: Any) {
        let fileManager = FileManager.default
        
        do{
        let files = try fileManager.contentsOfDirectory(atPath: NSTemporaryDirectory())
            for file in files{
                print(file, "\n")
            }
        }
        catch{
            print("file error")
        }
        let label = DebugLabel.currentTitle
        if(label == "Show Physics")
        {
            sceneAR.debugOptions = [.renderAsWireframe, .showBoundingBoxes, .showFeaturePoints, .showPhysicsFields, .showPhysicsShapes]
            DebugLabel.setTitle("Hide Physics", for: UIControl.State.normal)
        }
        else{
            sceneAR.debugOptions = []
            DebugLabel.setTitle("Show Physics", for: UIControl.State.normal)
        }
    }
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
        object.scale = SCNVector3(unit, unit, unit)
    }

    @objc func updateStartingVector(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneAR)
        let hitTestResults = sceneAR.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        addPosition = SCNVector3(x,y,z)
        planeColorHidden = true
        
        for child in sceneAR.scene.rootNode.childNodes{
            if(child.name == "plane"){
                child.isHidden = planeColorHidden
            }
        }
        
        print("Plane Selected")
    }
    
    var object = Objects()
    
    var geometryNode: SCNNode = SCNNode()
    var currentAngle: Float = 0.0
    var addPosition: SCNVector3 = SCNVector3(0,0,0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
        setupScene()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupConfiguration()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("App Closed")
        print(NSTemporaryDirectory())
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(atPath: NSTemporaryDirectory())
        }
        catch{
            print("file deletion error")
        }
    }
    
    func setupScene() {
        let scene = SCNScene()
        sceneAR.autoenablesDefaultLighting = true
        sceneAR.allowsCameraControl = false
        sceneAR.scene = scene
    }
    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneAR.delegate = self
        sceneAR.session.run(configuration)
    }
    func addObject(path: String) {
        print("addObject")
        object.removeFromParentNode()
        object = Objects()
        object.loadModel(filename: path)
        object.position = addPosition
        object.rotation = SCNVector4Zero
        sceneAR.scene.rootNode.addChildNode(object)
        SliderChanged(Slider)
    }
    func addObject(urlpath: URL) {
        print("addObject 2")
        object.removeFromParentNode()
        object = Objects()
        object.loadModel(urlname: urlpath)
        object.position = addPosition
        object.rotation = SCNVector4Zero
        sceneAR.scene.rootNode.addChildNode(object)
        SliderChanged(Slider)
    }

    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.updateStartingVector(withGestureRecognizer:)))
        sceneAR.addGestureRecognizer(tapGestureRecognizer)
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
extension ViewController: ARSCNViewDelegate {
     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      // 1
      guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
      
      // 2
      let width = CGFloat(planeAnchor.extent.x)
      let height = CGFloat(planeAnchor.extent.z)
      let plane = SCNPlane(width: width, height: height)
      
      // 3
        plane.materials.first?.diffuse.contents = UIColor.transparentDeveloperColor
      
      // 4
      let planeNode = SCNNode(geometry: plane)
      
      // 5
      let x = CGFloat(planeAnchor.center.x)
      let y = CGFloat(planeAnchor.center.y)
      let z = CGFloat(planeAnchor.center.z)
      planeNode.position = SCNVector3(x,y,z)
      planeNode.eulerAngles.x = -.pi / 2

        node.isHidden = planeColorHidden
      // 6
      node.addChildNode(planeNode)
        node.name = "plane"
        sceneAR.scene.rootNode.addChildNode(node)
        
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
         guard let planeAnchor = anchor as?  ARPlaneAnchor,
             let planeNode = node.childNodes.first,
             let plane = planeNode.geometry as? SCNPlane
             else { return }
      
         // 2
         let width = CGFloat(planeAnchor.extent.x)
         let height = CGFloat(planeAnchor.extent.z)
         plane.width = width
         plane.height = height
                  
         // 3
         let x = CGFloat(planeAnchor.center.x)
         let y = CGFloat(planeAnchor.center.y)
         let z = CGFloat(planeAnchor.center.z)
         planeNode.position = SCNVector3(x, y, z)
    }
}
extension UIColor {
    open class var transparentDeveloperColor: UIColor {
        return UIColor(red: 0/255, green: 102/255, blue: 255/255, alpha: 0.65)
    }

}

