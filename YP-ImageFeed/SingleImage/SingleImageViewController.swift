//
//  SingleImageViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 04.02.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            if let image = image {
                imageView.image = image
                rescaleAndCenterImageInScrollView(image: image)
            }
            else {
                return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        guard let image = image else { return }
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBAction private func tapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        let activity = UIActivityViewController(activityItems: [image as Any],
                                                applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        
        // Масштабирование
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        // Самый правый max определяет оптимальный скейл, чтобы картинка занимала весь экран
        // Средний max определяет, выходит ли оптимальный скейл за нижнюю границу скейлинга
        // Левый min определяет, выходит ли оптимальный скейл за верхнюю границу скейлинга
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        // Центрирование
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
