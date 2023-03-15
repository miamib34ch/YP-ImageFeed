//
//  ViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 29.01.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0)
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.DidChangeNotification,
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
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            viewController.imageURL = photos[indexPath.row].largeImageURL
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let contentInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        // Вычисляем масштаб через ширину, поскольку высота ImageView будет ровно во столько же раз больше высоты image, во сколько раз ширина ImageView больше ширины image.
        let imageViewWidth = tableView.bounds.width - contentInsets.left - contentInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        
        // Определяем высоту ImageView и складываем её с отступами для получения высоты ячейки
        let cellHeight = photos[indexPath.row].size.height * scale + contentInsets.top + contentInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row + 1 == photos.count) {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.imageCell.backgroundColor = UIColor(named: "YPGray")
        cell.imageCell.contentMode = .scaleAspectFit
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: UIImage(named: "PlaceholderPhotoList")) { /*[weak self]*/ _ in
            //guard let self = self else { return }
            cell.imageCell.backgroundColor = .clear
            cell.imageCell.contentMode = .scaleAspectFill
            //self.tableView.reloadRows(at: [indexPath], with: .automatic) // MARK: Из-за этого метода дергается картинка при прокрутке, и зачем его вообще использовать если мы итак выставляем высоту фотографии, а не плейсхолдера
        }
        
        if let date = photo.createdAt {
            cell.dateCell.text = dateFormatter.string(from: date)
        }
        else {
            cell.dateCell.text = ""
        }
        
        if (photo.isLiked) {
            cell.likeCell.setImage(UIImage(named: "Active"), for: .normal)
        }
        else{
            cell.likeCell.setImage(UIImage(named: "NoActive"), for: .normal)
        }
        
        
        if (cell.gradientSublayer == nil) { // Если нет градиентного подслоя то добавляем, иначе каждое переиспользование клетки будет добавляться новый подслой
            
            let gradientLayer = CAGradientLayer() // Создание градиентного слоя
            
            gradientLayer.frame = cell.gradientView.bounds // Устанавливаем ему границы - границы градиентного вью
            // Frame используется поскольку слой будет вложен в gradientView и мы будем рисовать по отношению его координат
            // Bounds используется поскольку мы будем рисовать не по отношению координат вью клетки, а по координатам внутри gradientView
            
            gradientLayer.colors = [
                UIColor(named: "YPBlack")?.withAlphaComponent(0).cgColor as Any, // Верхний цвет
                UIColor(named: "YPBlack")?.withAlphaComponent(0.2).cgColor as Any // Нижний цвет
            ]
            
            cell.gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Скрываем верхние углы у градиентного вью
            cell.gradientView.layer.addSublayer(gradientLayer) // Добавляем созданный слой в подслои
            cell.gradientSublayer = gradientLayer // Запоминаем, что подслой есть
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] res in
            guard let self = self else { return }
            
            switch res {
            case .success:
                cell.setIsLiked()
                self.photos = ImagesListService.shared.photos
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showError()
            }
        }
    }
}

extension ImagesListViewController: AlertPresenterDelegate {
    public func showError() {
        let alertDelegate = AlertPresenter(delegate: self)
        let model = AlertModel(title: "Что-то пошло не так(", message: "Не удалось выполнить операцию", buttonOneText: "Ок", completionOne: {}, buttonTwoText: "", completionTwo: {})
        alertDelegate.showOneButton(model: model)
    }
}
