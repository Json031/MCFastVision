//
//  MCVisionDetectTypesItem.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/6.
//  Copyright © 2026 MorganChen. All rights reserved.
//

class MCVisionDetectTypesItem: NSObject {
    public var type: MCFastVisionDetectType
    public var typeName: String
    
    init(type: MCFastVisionDetectType, typeName: String) {
        self.type = type
        self.typeName = typeName
    }
}
