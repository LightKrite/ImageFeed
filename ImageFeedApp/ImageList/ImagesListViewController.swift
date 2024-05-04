//
//  ViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 01.12.2023.
//

import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    var presenter: ImagesListPresenterProtocol? = {
        return ImagesListPresenter()
    }()
    
    var cache = ImageCache.default
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
//    private var imagesListServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.view = self
        setupTableView()
        presenter?.viewDidLoad()
        
//        setupNotifications()
//        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard let photo = presenter?.getPhotoIndex(indexPath.row)?.largeImageURL else { return }
        let largeImageURL = URL(string: photo)
        viewController.image = largeImageURL
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

// MARK: Data Source
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let photosCount = presenter?.photosCount else { return 0 }
        return photosCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        setupCell(imageListCell, indexPath)
        return imageListCell
    }
    
    private func setupCell(_ cell: ImagesListCell, _ indexPath: IndexPath) {
        guard let photo = presenter?.getPhotoIndex(indexPath.row) else { return }
        cell.setupCell(from: photo)
    }
    
}

// MARK: Delegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplay(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.getPhotoIndex(indexPath.row)?.size else { return CGFloat() }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)

        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: Update Table View Animated
extension ImagesListViewController {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
        
    }
}

extension ImagesListViewController: ImagesListDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.imageListCellDidTapLike(indexPath.row, cell)
    }
}

extension ImagesListViewController {
    
    static func clean() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.backgroundCleanExpiredDiskCache()
        cache.cleanExpiredMemoryCache()
        cache.clearCache()
    }
}





