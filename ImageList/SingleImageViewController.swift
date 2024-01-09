//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 07.01.2024.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            singleImage.image = image
        }
    }
    
    @IBOutlet private var singleImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleImage.image = image
    }
    
    
    @IBAction private func didTapBackwardButton() {
        dismiss(animated: true, completion: nil)
    }
    
}
