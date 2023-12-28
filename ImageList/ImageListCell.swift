//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Egor Partenko on 21.12.2023.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    static let reuseIdentifier = "ImagesListCell"
}
