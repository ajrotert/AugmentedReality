//
//  Coaching.swift
//  ARDemo
//
//  Created by Andrew Rotert on 5/20/20.
//  Copyright © 2020 Andrew Rotert. All rights reserved.
//

import ARKit
import UIKit

extension ViewController : ARCoachingOverlayViewDelegate{
    
    // MARK: Coaching View Delegates
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //When the coaching activates all the user controls are hidden
        hideUserInterfaceObjects(val: true, all: true)
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //When the coaching deactivates the selectable plane is visable to the user. Coaching should not be activated after this point.
        PlaceHolderLabel.isHidden = false
        let text = "Tap a blue surface\nTo place an object."
        PlaceHolderLabel.text = text
        coachingOverlayView.activatesAutomatically = false
    }

    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    }

    
    // MARK: Coaching Properties
    func setupCoachingOverlay() {
        //Inital coaching properties
        coachingOverlay.session = sceneAR.session
        coachingOverlay.delegate = self
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        sceneAR.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        
        setActivatesAutomatically()
        setGoal()
    }
    
    func setActivatesAutomatically() {
        coachingOverlay.activatesAutomatically = true
    }

    func setGoal() {
        coachingOverlay.goal = .horizontalPlane
    }
}
