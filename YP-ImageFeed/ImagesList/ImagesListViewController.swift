//
//  ViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 29.01.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
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
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return 0 }
        let contentInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        // Вычисляем масштаб через ширину, поскольку высота ImageView будет ровно во столько же раз больше высоты image, во сколько раз ширина ImageView больше ширины image.
        let imageViewWidth = tableView.bounds.width - contentInsets.left - contentInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        
        // Определяем высоту ImageView и складываем её с отступами для получения высоты ячейки
        let cellHeight = image.size.height * scale + contentInsets.top + contentInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return }
        
        cell.imageCell.image = image
        
        cell.dateCell.text = dateFormatter.string(from: Date())
        
        if (indexPath.row % 2 == 0) {
            cell.likeCell.setImage(UIImage(named: "Active"), for: .normal)
        }
        else {
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
