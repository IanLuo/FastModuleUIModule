//
//  SegmentContainerModule.swift
//  UIModule
//
//  Created by ian luo on 22/03/2018.
//

import Foundation
import FastModuleLayoutable
import FastModule
import FastModuleRoutable

public class SegmentContainerModule: Routable {
    public func layoutContent() {
        
    }
    
    private let vc = SegmentContainerViewController()
    public var viewController: UIViewController {
        return vc
    }
    
    public static var identifier: String = "segment-container"
    
    public static var routePriority: Int = 1
    
    public required init(request: HNARequest) {}
}
