//
//  ListCollectionView.swift
//  ListModule
//
//  Created by ian luo on 19/03/2018.
//

import Foundation
import UIKit

public class ListCollectionView: UICollectionView {
    
    internal var adapter: CollectionViewAdapter? {
        didSet {
            self.dataSource = adapter
            self.delegate = adapter
        }
    }
}
