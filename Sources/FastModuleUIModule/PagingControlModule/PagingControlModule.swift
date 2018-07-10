//
//  PagingControlModule.swift
//  UIModule
//
//  Created by ian luo on 24/03/2018.
//

import Foundation
import UIKit
import FastModule
import FastModuleLayoutable

public class PagingControlModule: Layoutable {
    private let pagingControl = UIPageControl()
    
    public var view: UIView {
        return pagingControl
    }
    
    public func layoutContent() {
    }
    
    public static var identifier: String = "paging-control-view"
    
    public static var routePriority: Int = 1
    
    public required init(request: Request) {}
    
    public func didInit() {
        bindProperty(key: "numberOfPages", type: Int.self) { [weak self] in
            self?.pagingControl.numberOfPages = $0
        }
        
        bindProperty(key: "currentPage", type: Int.self) { [weak self] in
            self?.pagingControl.currentPage = $0
        }
    }
}
