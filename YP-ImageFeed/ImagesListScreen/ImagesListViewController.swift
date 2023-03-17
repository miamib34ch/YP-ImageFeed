//
//  ViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 29.01.2023.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set}
    var tableView: UITableView! { get set }
    var photos: [Photo] { get set }
    func showAlert()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent } 
    
    @IBOutlet var tableView: UITableView!
    
    var presenter: ImagesListViewPresenterProtocol?
    var photos: [Photo] = []
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private var imageListServiceObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ImagesListViewPresenter()
        presenter?.view = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0)
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    private func updateTableViewAnimated() {
        let imagesListService = ImagesListService.shared
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // Нажатие на клетку
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            presenter?.prepare(for: segue, sender: sender)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else { return 0 }
        return presenter.tableView(tableView, heightForRowAt: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.imageCell.backgroundColor = UIColor(named: "YPGray")
        cell.imageCell.contentMode = .scaleAspectFit
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: UIImage(named: "PlaceholderPhotoList")) { _ in
            cell.imageCell.backgroundColor = .clear
            cell.imageCell.contentMode = .scaleAspectFill
        }
        
        if let date = photo.createdAt {
            cell.dateCell.text = presenter?.dateFormatter.string(from: date)
        }
        else {
            cell.dateCell.text = ""
        }
        
        photo.isLiked ? cell.likeCell.setImage(UIImage(named: "Active"), for: .normal) : cell.likeCell.setImage(UIImage(named: "NoActive"), for: .normal)
        
        if (cell.gradientSublayer == nil) { // Если нет градиентного подслоя то добавляем, иначе каждое переиспользование клетки будет добавляться новый подслой
            guard let gradientLayer = presenter?.createGradient(cell: cell) else { return }
            
            cell.gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Скрываем верхние углы у градиентного вью
            cell.gradientView.layer.addSublayer(gradientLayer) // Добавляем созданный слой в подслои
            cell.gradientSublayer = gradientLayer // Запоминаем, что подслой есть
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.imageListCellDidTapLike(cell)
    }
}

extension ImagesListViewController: AlertPresenterDelegate {
    func showAlert() {
        let alertDelegate = AlertPresenter(delegate: self)
        guard let model = presenter?.createAlertModel else { return }
        alertDelegate.showAlertWithOneButton(model: model)
    }
}
