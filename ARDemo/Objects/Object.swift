//
//  Object.swift
//  ARDemo
//
//  Created by Andrew Rotert on 5/7/20.
//  Copyright © 2020 Andrew Rotert. All rights reserved.
//

import ARKit
import SceneKit

class Objects: SCNNode{
    
    static var CyberTruckPath = "Cybertruck.scn"
    static var Animal = "dog/dog.scn"
    static var Formula = "formula 1/Formula.scn"
    
    func loadModel(filename: String){
        print("Model File Load")

            guard let virtualObjectScene = SCNScene(named: filename) else {return}
            let wrapperNode = SCNNode()
            for child in virtualObjectScene.rootNode.childNodes{
                wrapperNode.addChildNode(child)
            }
                
            print("Model Loaded Ending")
            wrapperNode.castsShadow = true
            addChildNode(wrapperNode)
        
    }
    func loadModel(urlname: URL){
        print("Model URL Load")
        
        do{
            let virtualObjectScene = try SCNScene(url: urlname)
            if(virtualObjectScene.rootNode.childNodes.count == 0){
                let message = "(Filestream Error): Error processing file. Try a differnt file type, or fix the filestream."
                print(message)
                ViewController.StaticViewController.showMessage(message: message)
            }
            else{
                let wrapperNode = SCNNode()
                for child in virtualObjectScene.rootNode.childNodes{
                    
                    if(child.geometry?.materials.count == 1){
                        child.geometry?.materials.first?.diffuse.contents = UIColor.darkGray
                        child.geometry?.materials.first?.diffuse.intensity = CGFloat(3)
                        child.geometry?.materials.first?.metalness.intensity = CGFloat(0.5)
                        child.geometry?.materials.first?.roughness.intensity = CGFloat(0.5)
                    }
                    else{
                        print("Materials: ", child.geometry?.materials.count ?? "cannot determine")
                    }
                    
                    wrapperNode.addChildNode(child)
                }
                print("Model Loaded Ending")
                
                wrapperNode.castsShadow = true
                addChildNode(wrapperNode)
            }
        }
        catch{
            let message = "(Rendering Error): File type is not supported."
            print(message)
            ViewController.StaticViewController.showMessage(message: message)

        }
        
    }
    
}
