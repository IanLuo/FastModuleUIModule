//
//  ListViewModel.swift
//  ListModule
//
//  Created by ian luo on 19/03/2018.
//

import Foundation
import HNAModule

internal class CellData {
    let pattern: String
    var parameters: [String: Any]?
    let rawRequest: HNARequest
    let id: String = UUID().uuidString
    let isStatic: Bool
    let size: String?
    
    init(pattern: String, rawRequest: HNARequest, isStatic: Bool, size: String?) {
        self.pattern = pattern
        self.isStatic = isStatic
        self.rawRequest = rawRequest
        self.size = size
    }
}

public class ListViewModel {
    private var data: [Int: [CellData]] = [:]
    private var sectionHeader: [Int: CellData] = [:]
    private var staticCell: [IndexPath: Module] = [:]
    private let actionHandler: Module?
    private weak var collectionView: UICollectionView!
    
    init(collectionView: UICollectionView, actionHandler: Module) {
        self.collectionView = collectionView
        self.actionHandler = actionHandler
    }
    
    internal func selected(indexPath: IndexPath) {
        let cellData = self.cellData(for: indexPath)
        var data = ["pattern": cellData.pattern, "section": indexPath.section, "row": indexPath.row] as [String : Any]
        if let model = cellData.parameters {
            data["model"] = model
        }
        actionHandler?.notify(action: ListModule.ActionKey.didSelect.rawValue, value: data)
    }
    
    internal var moduleCount: Int {
        return data.count
    }
    
    internal func requests(in section: Int) -> [CellData]? {
        return data[section]
    }
    
    internal func pattern(for indexPath: IndexPath) -> String? {
        return data[indexPath.section]?[indexPath.row].pattern
    }
    
    internal func request(for indexPath: IndexPath) -> HNARequest? {
        return data[indexPath.section]?[indexPath.row].rawRequest
    }
    
    internal func parameter(for indexPath: IndexPath) -> [String: Any]? {
        return data[indexPath.section]?[indexPath.row].parameters
    }
    
    internal func cellData(for indexPath: IndexPath) -> CellData {
        return data[indexPath.section]![indexPath.row]
    }
    
    internal func sectionHeaderData(section: Int) -> CellData? {
        return sectionHeader[section]
    }
    
    internal func refresh() {
        collectionView.reloadData()
    }
    
    internal func fireNestedEvent(_ event: Event) {
        actionHandler?.notify(action: ListModule.ActionKey.nestedEvent.rawValue, value: event)
    }
    
    internal func changePageNumber(_ page: Int) {
        actionHandler?.notify(action: ListModule.ActionKey.pageChanged.rawValue, value: page)
    }
    
    internal func insertHeader(cellData: CellData, section: Int) {
        sectionHeader[section] = cellData
    }
    
    internal func insertCell(cellData: CellData, section: Int) -> Int {
        for i in 0..<section {
            if data[i] == nil {
                data[i] = []
            }
        }
        
        if var sectionData = data[section] {
            sectionData.append(cellData)
            data[section] = sectionData
        } else {
            data[section] = [cellData]
        }
        
        return data[section]?.count ?? 0
    }
}
