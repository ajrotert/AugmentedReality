//
//  InstructionController.swift
//  ARDemo
//
//  Created by Andrew Rotert on 5/20/20.
//  Copyright © 2020 Andrew Rotert. All rights reserved.
//

import Foundation
import UIKit

class InsturctionController : UIViewController{
    @IBOutlet weak var PlaceholderLabel: UILabel!
    
    let helpText = """
Supported File Types:
3D Rendering supports: (.dea, .usdz, .usda, .usd, .usdc, .obj & .mtl, .abc, .ply, .stl, .scn)

Gestures:
Swiping Left/Right will rotate the model around the z-axis
Swiping Up/Down will rotate the model around the x-axis
Swiping with Two finger will rotate the model around the y-axis
Pinching rescales the model

Tips:
Objects in a model may render off the view of the camera, rotate the phone around your surroundings to locate objects.

Data:
Files are deleted after each session.

Controls:
(💡) Project light onto the model. Modes: On/Off.
(🌐) Show model geometry. Modes: On/ Off.

Control Group:
"""
    override func viewDidLoad() {
        super.viewDidLoad()
        PlaceholderLabel.text = helpText
    }
}
