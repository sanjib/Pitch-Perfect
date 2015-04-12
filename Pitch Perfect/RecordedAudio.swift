//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Sanjib Ahmad on 4/10/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    
    var title: String!
    var filePath: NSURL!
    
    init(title:String, filePath:NSURL) {
        self.title = title
        self.filePath = filePath
    }
    
}