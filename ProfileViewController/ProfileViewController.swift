//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 03.01.2024.
//

import Foundation
import UIKit


final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBAction func didTapExitButton() {
    }
}
