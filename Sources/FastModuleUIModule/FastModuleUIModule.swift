//
//  FastModuleUIModule.swift
//  FastModuleUIModule
//
//  Created by ian luo on 22/03/2018.
//

import Foundation
import HNAModule
import HNAModuleRoutable

public class UIModule: Module {
    public static var identifier: String = ""
    
    public static var routePriority: Int = 1
    
    public required init(request: HNARequest) {
        
    }
    
    public static func register() {
        ListModule.register()
        LabelModule.register()
        ImageModule.register()
        SegmentContainerModule.register()
        SegmentModule.register()
        ButtonModule.register()
        LoadingViewModule.register()
        RemoteImageModule.register()
        PagingControlModule.register()
        AlertModule.register()
    }
}

public enum UIControlStateString: String {
    case normal
    case selected
    case highlighted
    
    public var state: UIControlState {
        switch self {
        case .normal: return .normal
        case .selected: return .selected
        case .highlighted: return .highlighted
        }
    }
}
