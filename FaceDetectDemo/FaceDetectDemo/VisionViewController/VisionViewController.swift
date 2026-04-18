//
//  VisionViewController.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

class VisionViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var visionCollectionView: UICollectionView!
    
    var visionFace: VisionFace!
    
    private let visionDataSource = DataSource()
    private let visionDelegate = Delegate()
    private let visionLayout = Layout()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.visionCollectionView.dataSource = self.visionDataSource
        self.visionCollectionView.delegate = self.visionDelegate
        self.visionCollectionView.collectionViewLayout = self.visionLayout
        self.loadMockData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

private extension VisionViewController {
    func loadMockData() {
        self.visionDataSource.items = (0..<12).map { index in
            let side = CGFloat(0.15 + (Double(index % 4) * 0.02))
            return VisionFace(
                boundingBox: CGRect(x: 0.1, y: 0.1, width: side, height: side),
                confidence: 0.9,
                yaw: nil,
                roll: nil,
                landmarks: VisionLandmarks(
                    leftEye: nil,
                    rightEye: nil,
                    nose: nil,
                    outerLips: nil
                )
            )
        }
        self.visionCollectionView.reloadData()
    }
}
