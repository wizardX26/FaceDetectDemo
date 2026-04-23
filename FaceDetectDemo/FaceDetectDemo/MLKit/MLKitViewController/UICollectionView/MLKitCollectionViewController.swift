//
//  MLKitCollectionViewController.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 19/4/26.
//

import UIKit

private let reuseIdentifier = "MLKitCollectionViewCell"

class MLKitCollectionViewController: UICollectionViewController {
    private let sectionInset: CGFloat = 16
    private let itemSpacing: CGFloat = 12
    private let lineSpacing: CGFloat = 8
    private let numberOfColumns: CGFloat = 3
    
    private var hasInvalidatedLayout = false
    
    private var outputs: [MLKitFaceOutput] = [] {
        didSet {
            self.updateEmptyState()
        }
    }
    
    var onDataChanged: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(MLKitCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView.showsVerticalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // Ensure delegate sizing is used consistently after each reload.
            layout.estimatedItemSize = .zero
        }
        self.updateEmptyState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !self.hasInvalidatedLayout {
            self.hasInvalidatedLayout = true
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func reloadData(_ outputs: [MLKitFaceOutput]) {
        self.outputs = outputs
        DispatchQueue.main.async {
//            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
    
    private func updateEmptyState() {
        self.onDataChanged?(self.outputs.isEmpty)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.outputs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MLKitCollectionViewCell else {
            assertionFailure("Cannot dequeue reusable cell \(MLKitCollectionViewCell.self) with reuseIdentifier: \(reuseIdentifier)")
            return UICollectionViewCell()
        }
    
        let output = self.outputs[indexPath.item]
        cell.fill(with: output.faceImage)
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item >= 0, indexPath.item < self.outputs.count else { return }
        let detailViewController = MLKitDetailViewController.instantiateViewController()
        detailViewController.configure(with: self.outputs[indexPath.item])
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension MLKitCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalInset = self.sectionInset * 2
        let totalSpacing = (self.numberOfColumns - 1) * self.itemSpacing
        let availableWidth = collectionView.bounds.width - totalHorizontalInset - totalSpacing
        let itemWidth = floor(availableWidth / self.numberOfColumns)

        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.sectionInset, left: self.sectionInset, bottom: self.sectionInset, right: self.sectionInset)
    }
}
