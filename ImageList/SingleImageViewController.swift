//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 07.01.2024.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: URL?
    
    var imageDownload: UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var singleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        loadAndShowImage(url: image)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackwardButton() {
        dismiss(animated: true, completion: nil)
    }
    
    func loadAndShowImage(url: URL?) {
        guard let url = url else { return }
        UIBlockingProgressHUD.show()
        singleImageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                self.imageDownload = imageResult.image
            case .failure(let error):
                debugPrint(error.localizedDescription)
//                self.showError(url: url)
                
            }
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
   
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    private func rescaleAndCenterImageInScrollView (image: UIImage) {
            let minZoomScale = scrollView.minimumZoomScale
            let maxZoomScale = scrollView.maximumZoomScale
            view.layoutIfNeeded()
            let visibleRectSize = scrollView.bounds.size
            let imageSize = image.size
            let hScale = visibleRectSize.width / imageSize.width
            let vScale = visibleRectSize.height / imageSize.height
            let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
            scrollView.setZoomScale(scale, animated: false)
            scrollView.layoutIfNeeded()
            let newContentSize = scrollView.contentSize
            let x = (newContentSize.width - visibleRectSize.width) / 2
            let y = (newContentSize.height - visibleRectSize.height) / 2
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
}

extension SingleImageViewController {
    private func showError(url: URL) {
        let alert = UIAlertController(title: "Что то пошло не так(", message: "Попробовать еще раз?", preferredStyle: .alert)
        let repeats = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.loadAndShowImage(url: url)
        }
        let cancel = UIAlertAction(title: "Не надо", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(repeats)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

extension SingleImageViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
