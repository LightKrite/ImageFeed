//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Egor Partenko on 21.12.2023.
//

import Foundation
import UIKit
import Kingfisher

protocol ImagesListDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
   
    static let reuseIdentifier = "ImagesListCell"
    let cache = ImageCache.default
    weak var delegate: ImagesListDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func setupCell(from photo:Photo) {
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        let url = URL(string: photo.smallImageURL)
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceholder")) { result in
            switch result {
            case .success(let image):
                self.cellImage.contentMode = .scaleAspectFill
                self.cellImage.image = image.image
            case .failure(let error):
                debugPrint("Ошибка загрузки картинки: \(error)")
                self.cellImage.image = UIImage(named: "ImagePlaceholder")
            }
        }
        dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        setIsLiked(isLiked: photo.isLiked)
        
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imagesListCellDidTapLike(self)
    }
}
