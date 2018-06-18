import Foundation
import UIKit
import HNAModule
import HNAModuleLayoutable

public struct ModuleAction {
    
}

public class ListModule: NSObject, HNAModule.Module, Layoutable {
    public func layoutContent() {
        
    }
    
    public enum ActionKey: String {
        case didSelect
        case nestedEvent
        case pageChanged
    }
    
    private var viewControllerForNavigating: UIViewController?
    
    public var view: UIView {
        return collectionView
    }
    
    private lazy var collectionView: ListCollectionView = ListCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var collectionAdapter: CollectionViewAdapter = {
        let adapter = CollectionViewAdapter(viewModel: ListViewModel(collectionView: collectionView, actionHandler: self))
        self.collectionView.adapter = adapter
        return adapter
    }()
    
    public static var identifier: String = "list-view"
    
    public static var routePriority: Int = 1
    
    public required init(request: HNARequest) {
        
    }
    
    public func didInit() {
        
        bindActons()
    }
    
    private func bindActons() {
        bindAction(pattern: "insert/:section/:request") { [handleInsert] parameter, responder, request in
            guard let section = parameter.int(":section")
                else { responder.failure(error: ModuleError.missingParameter(":section")); return }
            
            guard let request = parameter.value(":request", type: HNAModule.HNARequest.self)
                else { responder.failure(error: ModuleError.missingParameter(":request")); return }
            

            let count = handleInsert(
                section,
                [request],
                parameter.truthy("static"),
                parameter["size"] as? String
            )
            
            responder.success(value: count)
        }
        
        bindAction(pattern: "header/:section/:request") { [weak self] (parameter, responder, request) in
            guard let section = parameter.int(":section")
                else { responder.failure(error: ModuleError.missingParameter(":section")); return }
            
            guard let request = parameter.value(":request", type: HNAModule.HNARequest.self)
                else { responder.failure(error: ModuleError.missingParameter(":request")); return }
            
            let newCellData = CellData(
                pattern: request.pattern,
                rawRequest: request,
                isStatic: parameter.truthy("static"),
                size: parameter["size"] as? String
            )
            
            self?.collectionAdapter.header(cellData: newCellData, section: section)
            responder.success(value: ())
        }
        
        bindAction(pattern: "batch-insert/:section/:requests") { [handleInsert] parameter, responder, request in
            guard let section = parameter.int(":section")
                else { responder.failure(error: ModuleError.missingParameter(":section")); return }
            
            guard let requests = parameter.value(":requests", type: [HNAModule.HNARequest].self)
                else { responder.failure(error: ModuleError.missingParameter(":requests")); return }
            
            let count = handleInsert(
                section,
                requests,
                parameter.truthy("static"),
                parameter["size"] as? String
            )
            
            responder.success(value: count)
        }
        
        bindAction(pattern: "refresh/:section/:row") { [weak self] parameter, responder, request in
            guard let section = parameter.int(":section")
                else { responder.failure(error: ModuleError.missingParameter(":section")); return }
            
            guard let row = parameter.int(":row")
                else { responder.failure(error: ModuleError.missingParameter(":row")); return }
            
            self?.collectionView.reloadItems(at: [IndexPath(row: row, section: section)])
            
            responder.success(value: ())
        }
        
        bindAction(pattern: "refresh/:section") { [weak self] parameter, responder, request in
            guard let section = parameter.int(":section")
                else { responder.failure(error: ModuleError.missingParameter(":section")); return }
            
            self?.collectionView.reloadSections(IndexSet(integer: section))
            
            responder.success(value: ())
        }
        
        bindAction(pattern: "refresh") { [weak self] _, responder, _ in
            self?.collectionAdapter.refresh()
            responder.success(value: ())
        }
        
        bindProperty(key: "sectionInset", type: UIEdgeInsets.self) { [recoverModifications] _ in
            recoverModifications()
        }
        
        bindProperty(key: "scrollDirection", type: UICollectionViewScrollDirection.self) { [recoverModifications] _ in
            recoverModifications()
        }
        
        bindProperty(key: "minimumInteritemSpacing", type: Double.self) { [recoverModifications] _ in
            recoverModifications()
        }
        
        bindProperty(key: "minimumLineSpacing", type: Double.self) { [recoverModifications] _ in
            recoverModifications()
        }
    }
    
    private func recoverModifications() {
        let layout = UICollectionViewFlowLayout()
        
        if let insect = property(key: "sectionInset", type: UIEdgeInsets.self) {
            layout.sectionInset = insect
        }
        
        if let direction = property(key: "scrollDirection", type: UICollectionViewScrollDirection.self) {
            layout.scrollDirection = direction
        }
        
        if let itemSpace = property(key: "minimumInteritemSpacing", type: Double.self) {
            layout.minimumInteritemSpacing = CGFloat(itemSpace)
        }
        
        if let lineSpace = property(key: "minimumLineSpacing", type: Double.self) {
            layout.minimumLineSpacing = CGFloat(lineSpace)
        }
        
        collectionView.collectionViewLayout = layout
    }
    
    private func handleInsert(section: Int, requests: [HNARequest], isStatic: Bool, size: String?) -> Int {
        var count = 0
        requests.forEach {
            let newCellData = CellData(pattern: $0.pattern, rawRequest: $0, isStatic: isStatic, size: size)
            count = collectionAdapter.insert(cellData: newCellData, in: section)
        }
        collectionView.reloadData()
        return count
    }
}
