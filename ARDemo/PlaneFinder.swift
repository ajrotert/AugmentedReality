import UIKit
import ARKit

extension ViewController: ARSCNViewDelegate {
     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
      
        plane.materials.first?.diffuse.contents = UIColor.transparentDeveloperColor
      
        let planeNode = SCNNode(geometry: plane)
      
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2

        node.isHidden = planeColorHidden

        node.addChildNode(planeNode)
        node.name = "plane"
        sceneAR.scene.rootNode.addChildNode(node)
        
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as?  ARPlaneAnchor,
             let planeNode = node.childNodes.first,
             let plane = planeNode.geometry as? SCNPlane
             else { return }
      
         let width = CGFloat(planeAnchor.extent.x)
         let height = CGFloat(planeAnchor.extent.z)
         plane.width = width
         plane.height = height
                  
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

