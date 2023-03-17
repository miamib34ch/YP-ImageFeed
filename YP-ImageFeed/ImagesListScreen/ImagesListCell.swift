//
//  ImagesListCell.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 02.02.2023.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    var gradientSublayer: CALayer?
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var likeCell: UIButton!
    @IBOutlet weak var dateCell: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        imageCell.kf.cancelDownloadTask()
    }
    
    @IBAction private func tapLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked() {
        if (likeCell.image(for: .normal) == UIImage(named: "Active")) {
            likeCell.setImage(UIImage(named: "NoActive"), for: .normal)
            likeCell.accessibilityIdentifier = "NoActive"
        }
        else{
            likeCell.setImage(UIImage(named: "Active"), for: .normal)
            likeCell.accessibilityIdentifier = "Active"
        }
    }
}
