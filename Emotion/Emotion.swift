//
//  Emotion.swift
//  MEL
//
//  Created by Edward Arenberg on 10/2/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import Foundation

enum Emotion: String, Codable {
    
    case happy = "happy"
    case sad = "sad"
    case angry = "angry"
    case surprised = "surprised"
    case unknown = "unknown"

    static func all() -> [Emotion] {
        return [.happy, .sad, .angry, .surprised, .unknown]
    }
}
