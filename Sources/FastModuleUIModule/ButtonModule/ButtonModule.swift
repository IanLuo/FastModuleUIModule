//
//  ButtonModule.swift
//  UIModule
//
//  Created by ian luo on 22/03/2018.
//

import Foundation
import FastModule
import FastModuleLayoutable

public class ButtonModule: Layoutable {
    public enum ActionKey: String {
        case tapped
    }
    
    public func layoutContent() {
        
    }
    
    private let button = UIButton()
    
    public var view: UIView {
        return button
    }
    
    public static var identifier: String = "button"
    
    public static var routePriority: Int = 1
    
    public required init(request: Request) {}
    
    @objc func tapped() {
        self.notify(action: ActionKey.tapped.rawValue, value: ())
    }
    
    public func didInit() {
        button.setTitleColor(UIColor.darkText, for: .normal)
        
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        
        bindAction(pattern: "image/:image/:state") { [weak self] parameter, responder, request in
            
            do {
                let image = try parameter.required(":image", type: UIImage.self)
                let state = try parameter.required(":state", type: String.self)
                
                self?.button.setImage(image, for: UIControlStateString(rawValue: state)?.state ?? .normal)
                responder.success(value: image)
            } catch {
                responder.failure(error: error)
            }
            
        }
        
        bindAction(pattern: "title/:title/:state") { [weak self] parameter, responder, request in
            
            do {
                let title = try parameter.required(":title", type: String.self)
                let state = try parameter.required(":state", type: String.self)
                
                self?.button.setTitle(title, for: UIControlStateString(rawValue: state)?.state ?? .normal)
                responder.success(value: title)
            } catch {
                responder.failure(error: error)
            }
        }
    }
}
