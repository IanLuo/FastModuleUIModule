//
//  LabelViewModule.swift
//  UIModule
//
//  Created by ian luo on 22/03/2018.
//

import Foundation
import FastModule
import FastModuleLayoutable

public class LabelModule: Layoutable {
    public func layoutContent() {
        
    }
    
    public var view: UIView { return label }
    
    private let label = UILabel()
    
    public static var identifier: String = "label-view"
    
    public static var routePriority: Int = 1
    
    public required init(request: Request) {
        label.numberOfLines = 0
    }
    
    public func listViewSize(container size: CGSize, pattern: String, parameter: [String : Any]?) -> CGSize {
        if let text = parameter?.value(":text", type: String.self) {
            let constrainedSize = size
            let attributes = [NSAttributedString.Key.font: label.font!]
            let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
            let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
            return CGSize(width: 0, height: ceil(bounds.height))
        }
        
        return CGSize.zero
    }
    
    public func didInit() {
        
        bindProperty(key: "text", type: String.self) { [weak self] in
            self?.label.text = $0
        }
        
        bindProperty(key: "font", type: UIFont.self) { [weak self] in
            self?.label.font = $0
        }
        
        bindProperty(key: "numberOfLines", type: Int.self) { [weak self] in
            self?.label.numberOfLines = $0
        }
        
        bindAction(pattern: "add-attribute/:range/:attributes") { [weak self] (parameter, responder, request) in
            
            do {
                let range = try parameter.required(":range", type: NSRange.self)
                let attributes = try parameter.required(":attributes", type: [NSAttributedString.Key: Any].self)
                
                let text = self?.label.text ?? ""
                let attributedString = self?.label.attributedText ?? NSAttributedString(string: text)
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                mutableAttributedString.addAttributes(attributes, range: range)
                self?.label.attributedText = mutableAttributedString
                
                responder.success(value: mutableAttributedString)
            } catch {
                responder.failure(error: error)
            }
        }
    }
}

