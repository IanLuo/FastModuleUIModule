//
//  AlertModule.swift
//  UIModule
//
//  Created by ian luo on 30/03/2018.
//

import Foundation
import FastModule
import FastModuleLayoutable
import FastModuleRoutable

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
    
    public required init(request: Request) {
        
    }
    
    public func didInit() {
        bindProperty(key: "title", type: String.self) { [weak self] in
            self?.vc.title = $0
        }
        
        bindProperty(key: "message", type: String.self) { [weak self] in
            self?.vc.message = $0
        }
                
        bindAction(pattern: "add/:style/:title") { [weak self] (parameter, responder, request) in
        
            do {
                let title = try parameter.required(":title", type: String.self)
                let style = try parameter.required(":style", type: String.self)
                
                guard let s = self?.actionStyle(style: style) else {
                    throw ModuleError.wrongValue("should be one of 'default, cancel, delete'", ":style")
                }
                
                self?.vc.addAction(UIAlertAction(title: title, style: s, handler: { _ in
                    self?.back()
                    self?.notify(action: ActionKey.didSelect.rawValue, value: title)
                }))
            } catch {
                responder.failure(error: error)
            }
            
        }
    }
    
    private func actionStyle(style: String) -> UIAlertAction.Style? {
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
