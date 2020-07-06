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
    
    // MARK: Preloaded paths for Objects
    static var CyberTruckPath = "Cybertruck.scn"
    static var Animal = "dog/dog.scn"
    static var Formula = "formula 1/Formula.scn"
    
    
    // MARK: Loads Model from Path
    func loadModel(filename: String){
        //Renders preloaded model
        print("Model File Load")

            guard let virtualObjectScene = SCNScene(named: filename) else {return}
            let wrapperNode = SCNNode()
            for child in virtualObjectScene.rootNode.childNodes{
                wrapperNode.addChildNode(child)
            }
                
            print("Model Loaded Ending")
            ViewController.StaticViewController.showPlaceholder(message: "Model Loaded Successfully\n\nScaling may be off.\n\nPress the info button for help.", animate: true)
            wrapperNode.castsShadow = true
            addChildNode(wrapperNode)
        
    }
    
    
    // MARK: Loads Model from URL
    func loadModel(urlname: URL){
        //Renders model from URL
        print("Model URL Load")
        
        do{
            let virtualObjectScene = try SCNScene(url: urlname)
            
            //Nothing is loaded from the url, nothing will be rendered
            if(virtualObjectScene.rootNode.childNodes.count == 0){
                let message = "(Filestream Error): Error processing file. Try a differnt file type, or fix the filestream.\n\nModel did not load."
                print(message)
                ViewController.StaticViewController.hidePlaceholder(isHidden: true)
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
                ViewController.StaticViewController.showPlaceholder(message: "Model Loaded Successfully\n\nScaling may be off.\n\nPress the info button for help.", animate: true)
            }
        }
        catch{
            //Error occured rendering file from url.
            let message = "(Rendering Error): File type(s) are not supported.\n\nParts of the model may not have loaded."
            print(message)
            ViewController.StaticViewController.showPlaceholder(message: "Model Loaded\n\nScaling may be off.\n\nPress the info button for help.", animate: true)
            ViewController.StaticViewController.showMessage(message: message)

        }
        
    }
    
}
