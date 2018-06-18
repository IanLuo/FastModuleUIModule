//
//  ImageViewModule.swift
//  UIModule
//
//  Created by ian luo on 22/03/2018.
//

import Foundation
import FastModule
import FastModuleLayoutable

public class ImageModule: Layoutable {
    public func layoutContent() {
        
    }
    
    public var view: UIView {
        return imageView
    }
    
    public func listViewSize(container size: CGSize, pattern: String, parameter: [String: Any]?) -> CGSize {
        if let image = parameter?[":image"] as? UIImage {
            return image.size
        }
        
        return CGSize.zero
    }
    
    private let imageView =  UIImageView()
    
    public static var identifier: String = "image-view"
    
    public static var routePriority: Int = 0
    
    public required init(request: HNARequest) {}
    
    public func didInit() {
        observeValue(action: "image", type: UIImage.self) { [weak self] in
            self?.imageView.image = $0
        }
        
        bindAction(pattern: "image/:image") { [weak self] parameter, responder, _ in
            guard let image = parameter.value(":image", type: UIImage.self) else {
                responder.failure(error: ModuleError.missingParameter(":image"))
                return
            }
            
            self?["image"] = image
            responder.success(value: image)
        }
    }
}
