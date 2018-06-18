//
//  ButtonModule.swift
//  UIModule
//
//  Created by ian luo on 22/03/2018.
//

import Foundation
import HNAModule
import HNAModuleLayoutable

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
    
    public required init(request: HNARequest) {}
    
    @objc func tapped() {
        self.notify(action: ActionKey.tapped.rawValue, value: ())
    }
    
    public func didInit() {
        button.setTitleColor(UIColor.darkText, for: .normal)
        
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        
        bindAction(pattern: "image/:image/:state") { [weak self] parameter, responder, request in
            guard let image = parameter.value(":image", type: UIImage.self) else {
                responder.failure(error: ModuleError.missingParameter(":image"))
                return
            }
            
            guard let state = parameter.value(":state", type: String.self) else {
                responder.failure(error: ModuleError.missingParameter(":state"))
                return
            }
            
            self?.button.setImage(image, for: UIControlStateString(rawValue: state)?.state ?? .normal)
            responder.success(value: image)
        }
        
        bindAction(pattern: "title/:title/:state") { [weak self] parameter, responder, request in
            guard let title = parameter.value(":title", type: String.self) else {
                responder.failure(error: ModuleError.missingParameter(":title"))
                return
            }
            
            guard let state = parameter.value(":state", type: String.self) else {
                responder.failure(error: ModuleError.missingParameter(":state"))
                return
            }
            
            self?.button.setTitle(title, for: UIControlStateString(rawValue: state)?.state ?? .normal)
            responder.success(value: title)
        }
    }
}
