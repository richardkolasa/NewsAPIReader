//
//  SourcesViewController.swift
//  NewsAPIReader
//
//  Created by Rich Kolasa on 12/19/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//

import UIKit
import BubbleTransition
import IGListKit
import Hero

class TableSectionController: IGListSectionController {
    var source: Source?
}

extension TableSectionController: IGListSectionType {
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        
        guard let context = collectionContext else { return .zero}
        let width = (context.containerSize.width / 2.1)
        
        return CGSize(width: width, height: width)
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "sourceCell", for: self, at: index)
        
        cell.layer.cornerRadius = 5
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.masksToBounds = false
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 4
        
        if let cell = cell as? Sourceable, let source = self.source {
            cell.setup(source: source)
        }
        return cell
    }
    
    func didUpdate(to object: Any) {
        source = object as? Source
    }
    
    func didSelectItem(at index: Int) {
        
        if let vc = self.viewController as? SourcesViewController, let source = self.source {
            vc.getDetailsOf(source: source)
            vc.dismiss(animated: true, completion: nil)
        }
    }
}

class SourcesViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: IGListCollectionView!
    
    var sources: [Source] = []
    var name: String?
    
    /// Unique identifier- used to pass source back to PostViewController
    var sourceID: String?
    let sourceService = SourceService()
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 6)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gridCollectionLayout = IGListGridCollectionViewLayout()
        gridCollectionLayout.minimumInteritemSpacing = 10
        gridCollectionLayout.minimumLineSpacing = 10
        
        collectionView.contentMode = .scaleAspectFit
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        collectionView.collectionViewLayout = gridCollectionLayout
        
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

extension SourcesViewController: IGListAdapterDataSource {
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return self.sources
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        return TableSectionController()
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
}
