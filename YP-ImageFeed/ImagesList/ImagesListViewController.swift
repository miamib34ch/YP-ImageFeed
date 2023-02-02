//
//  ViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 29.01.2023.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
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

extension ImagesListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //нажатие на клетку
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let contentInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        //вычисляем масштаб через ширину, поскольку высота ImageView будет ровно во столько же раз больше высоты image, во сколько раз ширина ImageView больше ширины image.
        let imageViewWidth = tableView.bounds.width - contentInsets.left - contentInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        
        //определяем высоту ImageView и складываем её с отступами для получения высоты ячейки
        let cellHeight = image.size.height * scale + contentInsets.top + contentInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        cell.imageCell.image = image
        
        cell.dateCell.text = dateFormatter.string(from: Date())
        
        if (indexPath.row % 2 == 0){
            cell.likeCell.setImage(UIImage(named: "Active"), for: .normal)
        }
        else{
            cell.likeCell.setImage(UIImage(named: "NoActive"), for: .normal)
        }
    
    }
    
}
