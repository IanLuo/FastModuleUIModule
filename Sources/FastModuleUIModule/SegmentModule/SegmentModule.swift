//
//  SegmentModule.swift
//  UIModule
//
//  Created by ian luo on 22/03/2018.
//

import Foundation
import HNAModule
import HNAModuleLayoutable

public class SegmentModule: Layoutable {
    public func layoutContent() {
        
    }
    
    private let segmentView = UISegmentedControl()
    
    public var view: UIView {
        return segmentView
    }
    
    public static var identifier: String = "segment-view"
    
    public static var routePriority: Int = 1
    
    public required init(request: HNARequest) {
        
    }
}
