//
//  GeneralCell.swift
//  UIModule
//
//  Created by ian luo on 22/03/2018.
//

import Foundation
import FastModule
import FastModuleLayoutable

public class GeneralCell: UICollectionViewCell {
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
        contentView.addSubview(layoutabel.view)
    }
}
