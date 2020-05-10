//
//  Object.swift
//  ARDemo
//
//  Created by Andrew Rotert on 5/7/20.
//  Copyright © 2020 Andrew Rotert. All rights reserved.
//

import ARKit

class Objects: SCNNode{
    
    static var CyberTruckPath = "CyberTruck.scn"
    static var Animal = "dog/dog.scn"
    
    func loadModel(filename: String){
        print("Model File Load")

            guard let virtualObjectScene = SCNScene(named: filename) else {return}
            let wrapperNode = SCNNode()
            for child in virtualObjectScene.rootNode.childNodes{
                child.castsShadow = true
                wrapperNode.addChildNode(child)
            }
            print("Model Loaded Ending")
            addChildNode(wrapperNode)
        
    }
    func loadModel(urlname: URL){
        print("Model URL Load")

        do{
            let virtualObjectScene = try SCNScene(url: urlname)
            let wrapperNode = SCNNode()
            for child in virtualObjectScene.rootNode.childNodes{
                child.castsShadow = true
                wrapperNode.addChildNode(child)
            }
            print("Model Loaded Ending")
            addChildNode(wrapperNode)
        }
        catch{
            print("Model Loading Error")
        }
        
    }
    
}
