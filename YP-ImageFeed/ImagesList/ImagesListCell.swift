//
//  ImagesListCell.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 02.02.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var likeCell: UIButton!
    @IBOutlet weak var dateCell: UILabel!
    @IBOutlet weak var gradientView: UIView!
}
