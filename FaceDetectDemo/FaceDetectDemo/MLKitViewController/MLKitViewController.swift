//
//  MLKitViewController.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

class MLKitViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet weak var faceResultContainerView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var mlkitCollectionViewControler: MLKitCollectionViewController?
    private var pendingFaces: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func reloadData(_ images: [UIImage]) {
        self.pendingFaces = images
        self.mlkitCollectionViewControler?.reloadData(images)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == String( describing: MLKitCollectionViewController.self),
           let destination = segue.destination as? MLKitCollectionViewController {
            self.mlkitCollectionViewControler = destination
            destination.onDataChanged = { [weak self] isEmpty in
                DispatchQueue.main.async {
                    self?.emptyLabel.isHidden = !isEmpty
                }
            }
            destination.reloadData(self.pendingFaces)
        }
    }
    

}
