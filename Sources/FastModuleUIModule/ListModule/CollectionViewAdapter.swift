//
//  CollectionViewAdapter.swift
//  ListModule
//
//  Created by ian luo on 19/03/2018.
//

import Foundation
import UIKit
import FastModule
import FastModuleLayoutable

public class CollectionViewAdapter: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public var viewModel: ListViewModel!
    private lazy var modulePool = ModulePool {
        self.viewModel.fireNestedEvent($0)
    }
    
    internal func remove(model: [String: Any]) {
        
    }
    
    internal func insert(cellData: CellData, in section: Int, at index: Int = 0) -> Int {
        return viewModel.insertCell(cellData: cellData, section: section)
    }
    
    internal func header(cellData: CellData, section: Int) {
        viewModel.insertHeader(cellData: cellData, section: section)
    }
    
    internal func selected(model: [String: Any]) {
        
    }
    
    internal func refresh() {
        viewModel.refresh()
    }
    
    internal init(viewModel: ListViewModel) {
        self.viewModel = viewModel
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.requests(in: section)?.count ?? 0
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.moduleCount
    }
    
    private var registered: [String] = []
    
    private var cachedModule: [String: Layoutable] = [:]
    
    private var page: CGFloat = 0
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isPagingEnabled {
            let c_page = floor((scrollView.contentOffset.x + scrollView.bounds.width / 2) / scrollView.bounds.width)
            if c_page != page {
                page = c_page
                viewModel.changePageNumber(Int(page))
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellData = viewModel.cellData(for: indexPath)
        
        if !registered.contains(cellData.pattern) {
            /// 根据 url 来判断重用的 cell
            collectionView.register(GeneralCell.self, forCellWithReuseIdentifier: cellData.pattern)
            registered.append(cellData.pattern)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellData.pattern, for: indexPath) as! GeneralCell
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view = UICollectionReusableView()
        if let cellData = viewModel.sectionHeaderData(section: indexPath.section) {
            if kind == UICollectionElementKindSectionHeader {
                let resultIdentifier = cellData.pattern + UICollectionElementKindSectionHeader
                if !registered.contains(resultIdentifier) {
                    /// 根据 url 来判断重用的 cell
                    collectionView.register(GeneralReuseView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: resultIdentifier)
                    registered.append(resultIdentifier)
                }
                let container = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: resultIdentifier, for: indexPath) as! GeneralReuseView
                view = container
            } else {
                let resultIdentifier = cellData.pattern + UICollectionElementKindSectionFooter
                if !registered.contains(resultIdentifier) {
                    /// 根据 url 来判断重用的 cell
                    collectionView.register(GeneralReuseView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: resultIdentifier)
                    registered.append(resultIdentifier)
                }
                let container = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: resultIdentifier, for: indexPath) as! GeneralReuseView
                view = container
            }
        }
        
        return view
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let cellData = viewModel.sectionHeaderData(section: section) {
            return getSize(cellData: cellData, collectionView: collectionView)
        } else {
            return CGSize.zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let view = view as? GeneralReuseView {
            let cellData = viewModel.sectionHeaderData(section: indexPath.section)!
            let layoutable = modulePool.getModule(cellData: cellData)
            view.passRequestToEmbededLayoutabelModule(layoutabel: layoutable)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let view = view as? GeneralReuseView {
            let cellData = viewModel.sectionHeaderData(section: indexPath.section)!
            view.layoutabel?.view.removeFromSuperview()
            modulePool.returnToPool(cellData: cellData, module: view.layoutabel!)
            view.layoutabel = nil
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeneralCell {
            let cellData = viewModel.cellData(for: indexPath)
            let layoutable = modulePool.getModule(cellData: cellData)
            if !cellData.isStatic {
                layoutable.executor(request: cellData.rawRequest).run { _ in }
            }
            cell.passRequestToEmbededLayoutabelModule(layoutabel: layoutable)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeneralCell {
            let cellData = viewModel.cellData(for: indexPath)
            cell.layoutabel?.view.removeFromSuperview()
            modulePool.returnToPool(cellData: cellData, module: cell.layoutabel!)
            cell.layoutabel = nil
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selected(indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getSize(cellData: viewModel.cellData(for: indexPath), collectionView: collectionView)
    }
    
    private func getSize(cellData: CellData, collectionView: UICollectionView) -> CGSize {
        let layoutable = modulePool.getModule(cellData: cellData)
        
        var size = CGSize.zero
        
        // priority 1: 如果在参数中指定了大小，使用之
        if let s = cellData.size {
            if case let sizeComp = s.components(separatedBy: "x"),
                sizeComp.count == 2 && sizeComp[0].count > 0 && sizeComp[1].count > 0 {
                if let width = Double(sizeComp[0]), let height = Double(sizeComp[1]) {
                    size = CGSize(width: width, height: height)
                }
            }
        }
        
        switch (size.width, size.height) {
        case (0, 0): // 返回内部 view 计算的 size
            let s = layoutable.listViewSize(container: collectionView.bounds.size, pattern: cellData.pattern, parameter: cellData.parameters)
            size = CGSize(width: max(s.width, size.width), height: max(s.height, size.height))
        case (0, _): // 以参数中的 width 为上限按比例缩放
            let s = layoutable.listViewSize(container: collectionView.bounds.size, pattern: cellData.pattern, parameter: cellData.parameters)
            if s != CGSize.zero {
                let scale = size.height / max(s.height, 1)
                size = s.applying(CGAffineTransform(scaleX: scale, y: scale))
            }
        case (_, 0): // 以参数中的 height 为上限按比例缩放
            let s = layoutable.listViewSize(container: collectionView.bounds.size, pattern: cellData.pattern, parameter: cellData.parameters)
            if s != CGSize.zero {
                let scale = size.height / max(s.height, 1)
                size = s.applying(CGAffineTransform(scaleX: scale, y: scale))
            }
        case (_, _): break
        }
        
        // 如果 没有指定宽度，自动使用适合屏幕宽度
        if size.width == 0 {
            let insect = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)!.sectionInset
            size.width = collectionView.bounds.size.width - insect.left - insect.right
        }
        
        if size.height == 0 {
            let insect = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)!.sectionInset
            size.height = collectionView.bounds.size.height - insect.top - insect.bottom
        }
        
        modulePool.returnToPool(cellData: cellData, module: layoutable)
        return size
    }
}
