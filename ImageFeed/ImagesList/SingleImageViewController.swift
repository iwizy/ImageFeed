//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Вью контроллер для единичного изображения

import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    private var swipeDownGesture: UISwipeGestureRecognizer!
    private var swipeRightGesture: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image)
        setupSwipeGestures()
    }
    @IBAction func backwardButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let shareView = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareView, animated: true, completion: nil)
    }
    
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func setupSwipeGestures() {
        
        swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDownGesture.direction = .down
        // Добавляем жесты к scrollView, а не к view
        scrollView.addGestureRecognizer(swipeDownGesture)
        
        swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        scrollView.addGestureRecognizer(swipeRightGesture)
        
        // Разрешаем одновременную работу жестов и скролла
        swipeDownGesture.delegate = self
        swipeRightGesture.delegate = self
    }
    
    // Обработчик жестов смахивания
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInset()
    }
    
    private func updateInset() {
        let bounds = scrollView.bounds.size
        let content = scrollView.contentSize
        
        let horizontal = max(0, (bounds.width - content.width) / 2)
        let vertical = max(0, (bounds.height - content.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}

extension SingleImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let swipeGesture = gestureRecognizer as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .down {
                // Для жеста вниз проверяем, что скролл вверху
                return scrollView.contentOffset.y <= 0
            } else if swipeGesture.direction == .right {
                // Для жеста вправо проверяем, что скролл слева
                return scrollView.contentOffset.x <= 0
            }
        }
        return true
    }
}
