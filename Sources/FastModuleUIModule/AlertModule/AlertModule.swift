//
//  AlertModule.swift
//  UIModule
//
//  Created by ian luo on 30/03/2018.
//

import Foundation
import HNAModule
import HNAModuleLayoutable
import HNAModuleRoutable

public class AlertModule: Routable {
    public func layoutContent() {
        
    }
    
    public enum ActionKey: String {
        case didSelect
    }
    
    private let vc = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    public var viewController: UIViewController {
        return vc
    }
    
    public static var identifier: String = "alert"
    
    public static var routePriority: Int = 1
    
    public required init(request: HNARequest) {
        
    }
    
    public func didInit() {
        observeValue(action: "title", type: String.self) { [weak self] in
            self?.vc.title = $0
        }
        
        observeValue(action: "message", type: String.self) { [weak self] in
            self?.vc.message = $0
        }
                
        bindAction(pattern: "add/:style/:title") { [weak self] (parameter, responder, request) in
            guard let title = parameter.value(":title", type: String.self) else {
                responder.failure(error: ModuleError.missingParameter(":title"))
                return
            }
            
            guard let style = parameter.value(":style", type: String.self) else {
                responder.failure(error: ModuleError.missingParameter(":style"))
                return
            }
            
            guard let s = self?.actionStyle(style: style) else {
                responder.failure(error: ModuleError.wrongValue("should be one of 'default, cancel, delete'", ":style"))
                return
            }
            
            self?.vc.addAction(UIAlertAction(title: title, style: s, handler: { _ in
                self?.back()
                self?.notify(action: ActionKey.didSelect.rawValue, value: title)
            }))
        }
    }
    
    private func actionStyle(style: String) -> UIAlertActionStyle? {
        switch style {
        case "default":
            return .default
        case "cancel":
            return .cancel
        case "delete":
            return .destructive
        default:
            return nil
        }
    }
}
