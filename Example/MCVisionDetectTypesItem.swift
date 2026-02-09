//
//  MCVisionDetectTypesItem.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/6.
//  Copyright © 2026 MorganChen. All rights reserved.
//

import MCFastVision

class MCVisionDetectTypesItem: NSObject {
    var type: MCFastVisionDetectType
    var typeName: String
    
    init(type: MCFastVisionDetectType, typeName: String) {
        self.type = type
        self.typeName = typeName
    }
}
