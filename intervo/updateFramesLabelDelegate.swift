//
//  didFinishUpdatingSeconds.swift
//  intervo
//
//  Created by DAVID GONZALEZ on 3/22/17.
//  Copyright © 2017 David Gonzalez. All rights reserved.
//

import Foundation

protocol UpdateFramesLabelDelegate {
    
    func didFinishUpdatingSeconds(secondsNeeded: Int)

    func didFinishUpdatingFrames(framesNeeded: Int)
    
}
