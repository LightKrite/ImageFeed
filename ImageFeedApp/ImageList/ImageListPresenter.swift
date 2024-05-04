//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Egor Partenko on 04.05.2024.
//

import Foundation

public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func updateTableView()
    func getPhotoIndex(_ index: Int) -> Photo?
    func willDisplay(_ indexPath: Int)
    func imageListCellDidTapLike(_ index: Int, _ cell: ImagesListCell)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private let imagesListService: ImagesListServiceProtocol
    
    weak var view: ImagesListViewControllerProtocol?
    
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        setupNotifications()
    }
    
    var photosCount: Int {
        photos.count
    }
    
    func getPhotoIndex(_ index: Int) -> Photo? {
        photos[index]
    }
    
    func willDisplay(_ indexPath: Int) {
        if indexPath + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func updateTableView() {
        updateTableViewAnimated()
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func imageListCellDidTapLike(_ index: Int, _ cell: ImagesListCell) {
        guard let photo = getPhotoIndex(index) else { return }
        UIBlockingProgressHUD.showWithoutAnimation()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[index].isLiked)
                UIBlockingProgressHUD.dismissWithoutAnimation()
            case .failure(let error):
                print(error.localizedDescription)
                UIBlockingProgressHUD.dismissWithoutAnimation()
            }
        }
    }
    
    private func setupNotifications() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    guard let self = self else { return }
                    self.updateTableView()
                }
    }
}
