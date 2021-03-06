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
            let currentPage = floor((scrollView.contentOffset.x + scrollView.bounds.width / 2) / scrollView.bounds.width)
            if currentPage != page {
                page = currentPage
                viewModel.changePageNumber(Int(page))
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellData = viewModel.cellData(for: indexPath)
        
        // if the url is new, add to the regiested list
        if !registered.contains(cellData.pattern) {
            // get reuse cell type based on url
            collectionView.register(GeneralCell.self, forCellWithReuseIdentifier: cellData.pattern)
            registered.append(cellData.pattern)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellData.pattern, for: indexPath) as! GeneralCell
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view = UICollectionReusableView()
        if let cellData = viewModel.sectionHeaderData(section: indexPath.section) {
            if kind == UICollectionView.elementKindSectionHeader {
                let resultIdentifier = cellData.pattern + UICollectionView.elementKindSectionHeader
                if !registered.contains(resultIdentifier) {
                    // get reuse cell type based on url
                    collectionView.register(GeneralReuseView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: resultIdentifier)
                    registered.append(resultIdentifier)
                }
                let container = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: resultIdentifier, for: indexPath) as! GeneralReuseView
                view = container
            } else {
                let resultIdentifier = cellData.pattern + UICollectionView.elementKindSectionFooter
                if !registered.contains(resultIdentifier) {
                    // get reuse cell type based on url
                    collectionView.register(GeneralReuseView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: resultIdentifier)
                    registered.append(resultIdentifier)
                }
                let container = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: resultIdentifier, for: indexPath) as! GeneralReuseView
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
    
    /// initial the cell content with the layoutable
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let view = view as? GeneralReuseView {
            let cellData = viewModel.sectionHeaderData(section: indexPath.section)!
            let layoutable = modulePool.getModule(cellData: cellData)
            view.passRequestToEmbededLayoutabelModule(layoutabel: layoutable)
        }
    }
    
    /// when display completes, return the module instance back to the pool
    /// and remove the reference of the layoutable on the cell
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let view = view as? GeneralReuseView {
            let cellData = viewModel.sectionHeaderData(section: indexPath.section)!
            view.layoutabel?.view.removeFromSuperview()
            modulePool.returnToPool(cellData: cellData, module: view.layoutabel!)
            view.layoutabel = nil
        }
    }
    
    /// get cell instance from module pool
    /// if the cell is not static cell, means the display content of the module is dynamically rendered based on the request
    /// run the request again
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
    
    /// get an instance of the corresponding module, use the cellData to calculate the size, then return the cell instance back to the pool
    private func getSize(cellData: CellData, collectionView: UICollectionView) -> CGSize {
        let layoutable = modulePool.getModule(cellData: cellData)
        
        var size = CGSize.zero
        
        // priority 1: if the size if specified in parameter, use it
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
