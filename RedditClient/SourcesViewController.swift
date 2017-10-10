//
//  SourcesViewController.swift
//  NewsAPIReader
//
//  Created by Rich Kolasa on 12/19/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//

import UIKit
import IGListKit

var cellWidth: CGFloat?

class TableSectionController: ListSectionController {
    var source: Source?
    
}

extension TableSectionController {
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        
        guard let context = collectionContext else { return .zero}
        let width = (context.containerSize.width)
        return CGSize(width: width, height: 60)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "sourceCell", for: self, at: index)
        
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.25
        cell.layer.shadowRadius = 2
        
        if let cell = cell as? Sourceable, let source = self.source {
            cell.setup(source: source)
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        source = object as? Source
    }
    
    override func didSelectItem(at index: Int) {
        
        if let vc = self.viewController as? SourcesViewController, let source = self.source {
            vc.getDetailsOf(source: source)
            vc.dismiss(animated: true, completion: nil)
        }
    }
}

class SourcesViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var sources: [Source] = []
    var name: String?
    
    /// Unique identifier- used to pass source back to PostViewController
    var sourceID: String?
    let sourceService = SourceService()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 6)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentMode = .center       
        
        sourceService.get { (sources) in
            self.sources += sources
            self.adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    /// Capture and store source name & ID to UserDefaults
    func getDetailsOf(source: Source) {
        
        let sourceID = source.id
        let sourceName = source.name
        
        name = source.name
        self.sourceID = sourceID
        
        UserDefaults.standard.set(sourceName, forKey: "sourceName")
        UserDefaults.standard.set(sourceID, forKey: "sourceID")
        
        UserDefaults.standard.synchronize()
    }
}

extension SourcesViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.sources
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return TableSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
}
