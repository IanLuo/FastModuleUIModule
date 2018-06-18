//
//  GeneralReuseView.swift
//  UIModule
//
//  Created by ian luo on 29/03/2018.
//

import Foundation
import UIKit
import HNAModule
import HNAModuleLayoutable

public class GeneralReuseView: UICollectionReusableView {
    internal var layoutabel: Layoutable?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func passRequestToEmbededLayoutabelModule(layoutabel: Layoutable) {
        self.layoutabel = layoutabel
        layoutabel.view.frame = bounds
        addSubview(layoutabel.view)
    }
}
