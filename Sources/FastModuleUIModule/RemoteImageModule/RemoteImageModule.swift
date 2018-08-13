//
//  RemoteImageModule.swift
//  CFDemo
//
//  Created by ian luo on 23/03/2018.
//  Copyright © 2018 wod. All rights reserved.
//

import Foundation
import FastModule
import FastModuleLayoutable
import FastModuleNetwork
import UIKit

public class RemoteImageModule: Layoutable {
    private lazy var imageViewModule: ImageModule = {
        return ImageModule.instance() as! ImageModule
    }()
    
    public var view: UIView {
        return imageViewModule.view
    }
    
    public func listViewSize(container size: CGSize, pattern: String, parameter: [String : Any]?) -> CGSize {
        return imageViewModule.listViewSize(container:size, pattern:pattern, parameter:parameter)
    }
    
    public static var identifier: String = "remote-image-view"
    
    public static var routePriority: Int = 1
    
    private lazy var httpModule = FastModuleHTTP.instance(name: "image-download", pattern: "")
    
    public required init(request: FastModule.Request) {
        bindProperty(key: "url", type: String.self) { [weak self] url in
            self?.childLayoutable(id: "loading")?
                .executor(request: "start")
                .run { _ in }
            
            self?.httpModule
                .executor(request: Request(path: "download/#url(\(url))"), type: Data.self)
                .map { UIImage(data: $0) }
                .run { [weak self] in
                    self?.imageViewModule.update(properties: ["image": $0 as Any])
                    self?.childLayoutable(id: "loading")?.fire(request: "stop")
                }
        }
        

        bindProperty(key: "default", type: UIImageView.self) { [weak self] in
            self?.imageViewModule.update(properties: ["image": $0])
        }
        
        bindAction(pattern: "default/:image") { [weak self] (parameter, responder, request) in
            guard let image = parameter.value(":image", type: UIImage.self) else {
                responder.failure(error: ModuleError.missingParameter(":image"))
                return
            }
            
            self?.imageViewModule.executor(requestPattern: "image/#image", arguments: image).run({ [weak self] in
                switch $0 {
                case .success(let image):
                    self?.childLayoutable(id: "loading")?.fire(request: "stop")
                    responder.success(value: image)
                case .failure(let error):
                    responder.failure(error: error)
                }
            })
        }
    }
    
    public func didInit() {
        addChildLayoutable(id: "loading", request: LoadingViewModule.request())
    }
    
    public func layoutContent() {
        layout {
            $0.justifyContent = .center
            $0.alignItems = .center
        }
    }
}
