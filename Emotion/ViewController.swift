//
//  ViewController.swift
//  Emotion
//
//  Created by Edward Arenberg on 10/15/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var emotionIV: UIImageView!

    var emotionHist = [Emotion:Int]()
    let threshhold: Double = 0.6
    
    var emotionModel = EmotionModel()

    func resetTrackingConfiguration(images:[ARReferenceImage]? = nil) {

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true

        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}


extension ViewController: ARSessionDelegate {

}

extension ViewController: ARSCNViewDelegate {

    // MARK: - ARSCNViewDelegate
        
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        var emotionProbabilities: [Emotion:NSNumber] = [:]
        
        // blendShapes = [BlendShapeLocation : NSNumber]
        // ["A", "D", "Z"]
        let valueArray = faceAnchor.blendShapes.sorted { $0.key.rawValue < $1.key.rawValue }.map { $0.value }
        
        let mlInputArray = try! MLMultiArray(shape: [51], dataType: .double)
                
        valueArray.enumerated().forEach { (offset, element) in
            mlInputArray[offset] = element
        }
        let emotionModelInput = EmotionModelInput(input1: mlInputArray)
        let prediction = try! emotionModel.prediction(input: emotionModelInput)
        
        // order: happy, sad, angry, surprised
        emotionProbabilities[.happy] = prediction.output1[0]
        emotionProbabilities[.sad] = prediction.output1[1]
        emotionProbabilities[.angry] = prediction.output1[2]
        emotionProbabilities[.surprised] = prediction.output1[3]


        if let highestSet = emotionProbabilities.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.value.doubleValue > rhs.value.doubleValue
        }).first {
            
            let currentEmotion = highestSet.value.doubleValue >= threshhold ? highestSet.key : .unknown

            let cnt = emotionHist[currentEmotion] ?? 0
            emotionHist[currentEmotion] = cnt + 1
            
            DispatchQueue.main.async {
                let emotion = currentEmotion.rawValue
                self.emotionIV.image = UIImage(named: emotion)
            }
        }
    }


    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
