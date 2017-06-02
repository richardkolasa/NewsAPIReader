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


class TableSectionController: IGListSectionController {
    var source: Source?
}

extension TableSectionController: IGListSectionType {
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        
        guard let context = collectionContext else { return .zero}
        let width = context.containerSize.width
        
        return CGSize(width: width, height: 60)
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "sourceCell", for: self, at: index)
        cell.layer.cornerRadius = 3
        
        if let cell = cell as? Sourceable, let source = self.source {
            cell.setup(source: source)
        }
        
        return cell
    }
    
    func didUpdate(to object: Any) {
        source = object as? Source
    }
    
    func didSelectItem(at index: Int) {
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "sourceCell", for: self, at: index)
        cell.contentView.backgroundColor = .black
        
        if let vc = self.viewController as? SourceLogoViewController, let source = self.source {
            vc.getDetailsOf(source: source)
            vc.dismiss(animated: true, completion: nil)
        }
    }
}

class SourceLogoViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: IGListCollectionView!
    
    var sources: [Source] = []
    var name: String?
    var sourceID: String?
    let sourceService = SourceService()
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 6)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gridCollectionLayout = IGListGridCollectionViewLayout()
        gridCollectionLayout.minimumInteritemSpacing = 20
        gridCollectionLayout.minimumLineSpacing = 10
        
        collectionView.contentMode = .scaleAspectFit
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 50, bottom: 0, right: 50)
        collectionView.collectionViewLayout = gridCollectionLayout
                
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sourceService.get { (sources) in
            self.sources += sources
            self.adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
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

extension SourceLogoViewController: IGListAdapterDataSource {
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
