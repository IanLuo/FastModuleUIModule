//
//  ModulePool.swift
//
//  Created by ian luo on 21/03/2018.
//

import Foundation
import FastModule
import FastModuleLayoutable

/// module is put in this pool, just like the cell reuse pool, actrually, they are synchorolized
internal class ModulePool {
    private var nestedEventAction: (Event) -> Void

    internal init(nestedEventAction: @escaping (Event) -> Void) {
        self.nestedEventAction = nestedEventAction
    }

    private var pool: [String: [Layoutable]] = [:]

    private var staticPool: [String: Layoutable] = [:]
    
    private func createModuleInstance(cellData: CellData) -> Layoutable {
        guard let layoutable = ModuleContext.request(cellData.rawRequest) as? Layoutable else {
            fatalError("\(cellData.rawRequest.module) is not layoutable")
        }
        
        // delegate all event in module, and put in side of nextedEventAction and notify observer on list modual
        layoutable.observeEvent(action: "*", callback: {
            self.nestedEventAction($0)
        })
        
        return layoutable
    }
    
    internal func getModule(cellData: CellData) -> Layoutable {
        if cellData.isStatic {
            if let layoutable = staticPool[cellData.id] {
                return layoutable
            } else {
                let layoutable = createModuleInstance(cellData: cellData)
                staticPool[cellData.id] = layoutable
                return layoutable
            }
        } else if var poolRow = pool[cellData.rawRequest.pattern] {
            if poolRow.count > 0 {
                let module = poolRow.remove(at: 0)
                pool[cellData.rawRequest.pattern] = poolRow
                return module
            } else {
                return createModuleInstance(cellData: cellData)
            }
        } else {
            return createModuleInstance(cellData: cellData)
        }
    }
    
    internal func returnToPool(cellData: CellData, module: Layoutable) {
        guard !cellData.isStatic else { return }
        
        if var poolRow = pool[cellData.rawRequest.pattern] {
            poolRow.append(module)
            pool[cellData.rawRequest.pattern] = poolRow
        } else {
            pool[cellData.rawRequest.pattern] = [module]
        }
    }
}
