//
//  LoadingViewModule.swift
//  CFDemo
//
//  Created by ian luo on 23/03/2018.
//  Copyright © 2018 hna. All rights reserved.
//

import Foundation
import FastModule
import FastModuleLayoutable

public class LoadingViewModule: Layoutable {
    public func layoutContent() {
        
    }
    
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    public var view: UIView {
        return activityIndicator
    }
    
    public static var identifier: String = "loading-view"
    
    public static var routePriority: Int = 1
    
    public required init(request: HNARequest) {}
    
    public func didInit() {
        bindAction(pattern: "start") { [weak self] (_, responder, _) in
            self?.activityIndicator.startAnimating()
            responder.success(value: ())
        }
        
        bindAction(pattern: "stop") { [weak self] (_, responder, _) in
            self?.activityIndicator.stopAnimating()
            responder.success(value: ())
        }
    }
}
