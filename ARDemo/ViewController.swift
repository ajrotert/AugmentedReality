//
//  ViewController.swift
//  ARDemo
//
//  Created by Andrew Rotert on 5/7/20.
//  Copyright © 2020 Andrew Rotert. All rights reserved.
//

import ARKit
import UIKit
import SceneKit
import MobileCoreServices

let kAnimationDurationMoving: TimeInterval = 0.2
var kMovingLengthPerLoop: CGFloat = 0.05
let kRotationRadianPerLoop: CGFloat = 0.05
var planeColorHidden: Bool = false

class ViewController: UIViewController {
            
    enum Options: String{
        case cyberTruck = "Tesla CyberTruck"
        case animal = "Dog"
        case formula = "Formula One"
        case custom = "Use Your Own"
    }
    public static var StaticViewController: ViewController = ViewController()
    public func showMessage(message: String){
        let alert = UIAlertController(title: "A Error Occured", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    public func showPlaceholder(message: String, animate: Bool){
        PlaceHolderLabel.text = message
        PlaceHolderLabel.isHidden = false
        
        if(animate){
            UIView.animate(withDuration: 5, animations: {
                self.PlaceHolderLabel.alpha = 0
            }) { (finished) in
                self.PlaceHolderLabel.alpha = 1
                self.PlaceHolderLabel.isHidden = true
            }
        }
    }
    public func hidePlaceholder(isHidden: Bool){
        PlaceHolderLabel.isHidden = isHidden
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
        
        hideUserInterfaceObjects(val: false, all: false)
    }
    @IBAction func ObjectClicked(_ sender: UIButton) {
        guard let title = sender.currentTitle, let option = Options(rawValue: title) else { return }
            
        deleteTmpDirectory()
        
        let starting_message = "Model loading from file..."
        showPlaceholder(message: starting_message, animate: false)
        
        var path = ""
        switch option{
        case .cyberTruck:
            path = Objects.CyberTruckPath
            addObject(path: path)
        case .animal:
            path = Objects.Animal
            addObject(path: path)
        case .formula:
            path = Objects.Formula
            addObject(path: path)
        case .custom:
            let types: [String] = [kUTTypeItem as String]
            let importMenu = UIDocumentPickerViewController(documentTypes: types, in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            importMenu.allowsMultipleSelection = true
            present(importMenu, animated: false, completion: nil)
        }
        
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
    @IBOutlet weak var DebugLabel: UIButton!
    @IBOutlet weak var HideControls: UIButton!
    @IBOutlet weak var LightButton: UIButton!
    @IBOutlet weak var OptionsStack: UIStackView!
    @IBOutlet weak var PlaceHolderLabel: UILabel!
    @IBOutlet weak var InfoButton: UIButton!
    @IBOutlet weak var RefreshButton: UIButton!
    
    @IBAction func Debug(_ sender: Any) {
        let fileManager = FileManager.default
        do{
            let files = try fileManager.contentsOfDirectory(atPath: NSTemporaryDirectory())
            for file in files{
                print(file)
            }
        }
        catch{
            print("files error")
        }
        
        if(sceneAR.debugOptions.contains(.renderAsWireframe))
        {
            sceneAR.debugOptions = []
        }
        else{
            sceneAR.debugOptions = [.renderAsWireframe, .showBoundingBoxes, .showFeaturePoints, .showPhysicsFields, .showPhysicsShapes]
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
            sender.setTitle("Allow Free Float", for: UIControl.State.normal)
            addGesturesToSceneView(tap: false, pan: true, pinch: true, rotation: true)
            OptionsStack.isHidden = false
            RefreshButton.isHidden = false
        }
        else{
            sceneAR.scene.background.contents = UIImage(named: "Background")
            sender.setTitle("Reset to Fixed", for: UIControl.State.normal)
            for gesture in sceneAR.gestureRecognizers!{
                if(gesture.isEnabled){
                    if(gesture.isKind(of: UIPanGestureRecognizer.self)){
                        sceneAR.removeGestureRecognizer(gesture)
                    }
                    else if(gesture.isKind(of: UIPinchGestureRecognizer.self)){
                        sceneAR.removeGestureRecognizer(gesture)
                    }
                    else if(gesture.isKind(of: UIRotationGestureRecognizer.self)){
                        sceneAR.removeGestureRecognizer(gesture)
                    }
                }
            }
            let text = "Tap to lock\nposition"
            PlaceHolderLabel.text = text
            PlaceHolderLabel.isHidden = false
            OptionsStack.isHidden = true
            RefreshButton.isHidden = true
        }
        sceneAR.allowsCameraControl = !sceneAR.allowsCameraControl
    }

    @IBAction func LightClicked(_ sender: Any) {
        sceneAR.automaticallyUpdatesLighting = !sceneAR.automaticallyUpdatesLighting
        if(sceneAR.automaticallyUpdatesLighting){
            let img = UIImage(systemName: "lightbulb")
            LightButton.setImage(img, for: UIControl.State.normal)
        }
        else{
            let img = UIImage(systemName: "lightbulb.fill")
            LightButton.setImage(img, for: UIControl.State.normal)
        }
    }

    @IBAction func HideControls(_ sender: Any) {
        
        if(HideControls.currentTitle == "Hide Controls"){
            HideControls.setTitle("Show Controls", for: UIControl.State.normal)
            hideUserInterfaceObjects(val: true, all: false)
        }
        else{
            HideControls.setTitle("Hide Controls", for: UIControl.State.normal)
            hideUserInterfaceObjects(val: false, all: false)
        }
    }
    @IBAction func RefreshClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Restart", message: "Restarting will reset the scene, and delete any existing files.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Restart", style: .destructive, handler: {action in self.restartScene()}))

        self.present(alert, animated: true)
    }
    
    @objc func updateStartingVector(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if(!planeColorHidden){
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
            hideUserInterfaceObjects(val: false, all: true)
            hideUserInterfaceObjects(val: true, all: false)
            PlaceHolderLabel.isHidden = true
        }
        else if(!PlaceHolderLabel.isHidden){
            PlaceHolderLabel.isHidden = true
        }
    }
    
    var object = Objects()
    var addPosition: SCNVector3 = SCNVector3(0,0,0)
    let coachingOverlay = ARCoachingOverlayView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.StaticViewController = self
        setupCoachingOverlay()
        addGesturesToSceneView(tap: true, pan: true, pinch: true, rotation: true)
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
        deleteTmpDirectory()
    }
    func restartScene(){
        print("Restart Session")
        deleteTmpDirectory()
        object.removeFromParentNode()
        planeColorHidden = false
        hideUserInterfaceObjects(val: true, all: true)
        PlaceHolderLabel.isHidden = false
        PlaceHolderLabel.text = "Tap a blue surface\nTo place an object."
        for child in sceneAR.scene.rootNode.childNodes{
            if(child.name=="plane"){
                child.isHidden = false
            }
        }
        
    }
    func setupScene() {
        let scene = SCNScene()
        sceneAR.autoenablesDefaultLighting = true
        sceneAR.allowsCameraControl = false
        sceneAR.showsStatistics = true
        sceneAR.scene = scene
    }
    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        configuration.isLightEstimationEnabled = true
        sceneAR.automaticallyUpdatesLighting = false
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
        let box = [abs(object.boundingBox.max.x), abs(object.boundingBox.max.y), abs(object.boundingBox.max.z), abs(object.boundingBox.min.x), abs(object.boundingBox.min.y), abs(object.boundingBox.min.z)]
        scaleObject(unit: box.max()!)
        sceneAR.scene.rootNode.addChildNode(object)
        sceneAR.scene.rootNode.camera?.usesOrthographicProjection = true
        sceneAR.scene.rootNode.camera?.orthographicScale = 0.5
    }
    func addObject(urlpath: URL) {
        print("addObject 2")
        object.removeFromParentNode()
        object = Objects()
        object.loadModel(urlname: urlpath)
        object.position = addPosition
        object.rotation = SCNVector4Zero
        let box = [abs(object.boundingBox.max.x), abs(object.boundingBox.max.y), abs(object.boundingBox.max.z), abs(object.boundingBox.min.x), abs(object.boundingBox.min.y), abs(object.boundingBox.min.z)]
        scaleObject(unit: box.max()!)
        sceneAR.scene.rootNode.addChildNode(object)
    }
    func deleteTmpDirectory() {
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(atPath: NSTemporaryDirectory())
        }
        catch{
            print("file deletion error")
        }
    }
    func hideUserInterfaceObjects(val: Bool, all: Bool){
        RightButton.isHidden = val
        DownButton.isHidden = val
        UpButton.isHidden = val
        LeftButton.isHidden = val
        RRightButton.isHidden = val
        RLeftButton.isHidden = val
        AwayButton.isHidden = val
        CloserButton.isHidden = val
        FreeButton.isHidden = val
        DebugLabel.isHidden = val
        LightButton.isHidden = val
        if(all){
            OptionsStack.isHidden = val
            DebugLabel.isHidden = val
            HideControls.isHidden = val
            InfoButton.isHidden = val
            RefreshButton.isHidden = val
        }
    }

    func addGesturesToSceneView(tap: Bool, pan: Bool, pinch: Bool, rotation: Bool) {
        if(tap){
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.updateStartingVector(withGestureRecognizer:)))
            sceneAR.addGestureRecognizer(tapGestureRecognizer)
        }
        
        if(pan){
            let panRecognizer = UIPanGestureRecognizer(target: self, action:(#selector(self.panGesture(sender:))))
            sceneAR.addGestureRecognizer(panRecognizer)
        }
        
        if(pinch){
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:(#selector(self.pinchGesture(sender:))))
            sceneAR.addGestureRecognizer(pinchRecognizer)
        }
        
        if(rotation){
            let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: (#selector(self.rotationGesture(sender:))))
            sceneAR.addGestureRecognizer(rotationRecognizer)
        }
        
    }
    
    var totalX: Int = 0, totalY: Int = 0
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        totalX += Int(translation.x)
        totalY += Int(translation.y)
        
        if(sender.state == UIGestureRecognizer.State.ended) {
            if(abs(totalX) >= abs(totalY)){
                let mult = totalX > 0 ? -1 : 1
                let rotateBy = SCNQuaternion(x: 0, y: 0, z: (0.7071), w: (Float(mult) * 0.7071))
                object.localRotate(by: rotateBy)
            }
            else{
                let mult = totalY > 0 ? 1 : -1
                let rotateBy = SCNQuaternion(x: (0.7071), y: 0, z: 0, w: (Float(mult) * 0.7071))
                object.localRotate(by: rotateBy)
            }
            
            totalX = 0
            totalY = 0
        }
    }
    
    @objc func pinchGesture(sender: UIPinchGestureRecognizer){
        if(sender.state == .began || sender.state == .changed){
            let scaler = Float(object.scale.x) * Float(sender.scale)
            object.scale = SCNVector3(scaler, scaler, scaler)
            sender.scale = 1.0
        }
    }
    @objc func rotationGesture(sender: UIRotationGestureRecognizer){
        let rotation = sender.rotation
        let action = SCNAction.rotateBy(x: 0, y: rotation, z: 0, duration: 0)
        object.runAction(action)
    }

    func scaleObject(unit: Float){
        object.scale = SCNVector3(1/(unit + 25), 1/(unit + 25), 1/(unit + 25))
    }
    func moveObject(x: CGFloat, z: CGFloat, sender: Any) {
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    func deltas() -> (sin: CGFloat, cos: CGFloat) {
        return (sin: kMovingLengthPerLoop * CGFloat(sin(object.eulerAngles.y)), cos: kMovingLengthPerLoop * CGFloat(cos(object.eulerAngles.y)))
    }
    
    func rotateObject(yRadian: CGFloat, sender: Any) {
        let action = SCNAction.rotateBy(x: 0, y: yRadian, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    func execute(action: SCNAction, sender: Any) {
        let loopAction = SCNAction.repeat(action, count: 6)
        object.runAction(loopAction)
    }
}

