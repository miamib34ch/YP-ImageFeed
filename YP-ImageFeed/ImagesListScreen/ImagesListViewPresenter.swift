//
//  ImagesListViewPresenter.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 16.03.2023.
//

import UIKit

protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var dateFormatter: DateFormatter { get set }
    var createAlertModel: AlertModel { get }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell)
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func createGradient(cell: ImagesListCell) -> CAGradientLayer
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var createAlertModel: AlertModel {
        return AlertModel(title: "Что-то пошло не так(",
                          message: "Не удалось выполнить операцию",
                          firstButtonText: "Ок",
                          firstButtonCompletion: nil,
                          secondButtonText: nil,
                          secondButtonCompletion: nil)
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let view = view else { return }
        UIBlockingProgressHUD.show()
        guard let indexPath = view.tableView.indexPath(for: cell) else { return }
        let photo = view.photos[indexPath.row]
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak view] res in
            guard let view = view else { return }
            UIBlockingProgressHUD.dismiss()
            switch res {
            case .success:
                cell.setIsLiked()
                view.photos = ImagesListService.shared.photos
            case .failure:
                view.showAlert()
            }
        }
    }
    
    func createGradient(cell: ImagesListCell) -> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer() // Создание градиентного слоя
        
        gradientLayer.frame = cell.gradientView.bounds // Устанавливаем ему границы - границы градиентного вью
        // Frame используется поскольку слой будет вложен в gradientView и мы будем рисовать по отношению его координат
        // Bounds используется поскольку мы будем рисовать не по отношению координат вью клетки, а по координатам внутри gradientView
        
        gradientLayer.colors = [
            UIColor(named: "YPBlack")?.withAlphaComponent(0).cgColor as Any, // Верхний цвет
            UIColor(named: "YPBlack")?.withAlphaComponent(0.2).cgColor as Any // Нижний цвет
        ]
        
        return gradientLayer
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let view = view else { return }
        if (indexPath.row + 1 == view.photos.count) {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let view = view else { return 0 }
        let contentInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        // Вычисляем масштаб через ширину, поскольку высота ImageView будет ровно во столько же раз больше высоты image, во сколько раз ширина ImageView больше ширины image.
        let imageViewWidth = tableView.bounds.width - contentInsets.left - contentInsets.right
        let imageWidth = view.photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        
        // Определяем высоту ImageView и складываем её с отступами для получения высоты ячейки
        let cellHeight = view.photos[indexPath.row].size.height * scale + contentInsets.top + contentInsets.bottom
        return cellHeight
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let view = view as? ImagesListViewController else { return }
        guard let viewController = segue.destination as? SingleImageViewController else { return }
        guard let indexPath = sender as? IndexPath else { return }
        
        viewController.imageURL = view.photos[indexPath.row].largeImageURL
        viewController.delegate = view
    }
}
