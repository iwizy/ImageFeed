//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Вью контроллер для единичного изображения

import UIKit

final class SingleImageViewController: UIViewController {
    
    // Свойство для хранения отображаемого изображения
    // didSet автоматически обновляет интерфейс при изменении изображения
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return } // Проверяем что view загружена и изображение существует
            imageView.image = image // Устанавливаем изображение в imageView
            imageView.frame.size = image.size // Обновляем размер imageView под размер изображения
            rescaleAndCenterImageInScrollView(image: image) // Масштабируем и центрируем изображение в scrollView
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    // Жесты для закрытия контроллера свайпом вниз и вправо
    private var swipeDownGesture: UISwipeGestureRecognizer?
    private var swipeRightGesture: UISwipeGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image else { return } // Проверяем наличие изображения
        imageView.image = image
        imageView.frame.size = image.size
        scrollView.minimumZoomScale = 0.1 // Устанавливаем минимальный и максимальный масштаб zoom
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image) // Масштабируем и центрируем изображение
        setupSwipeGestures()
    }
    
    // Обработчик нажатия кнопки "Назад"
    @IBAction func backwardButton(_ sender: Any) {
        dismiss(animated: true, completion: nil) // Закрываем текущий контроллер
    }
    
    // Обработчик нажатия кнопки "Поделиться"
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return } // Проверяем наличие изображения
        let shareView = UIActivityViewController( // Создаем стандартный контроллер для шеринга
            activityItems: [image],
            applicationActivities: nil
        )
        present(shareView, animated: true, completion: nil) // Показываем контроллер шеринга
    }
    
    // Масштабирует и центрирует изображение в scrollView
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // Получаем текущие настройки масштабирования
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        // Обновляем layout если нужно
        view.layoutIfNeeded()
        
        // Рассчитываем оптимальный масштаб
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        
        // Выбираем масштаб с учетом ограничений
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        // Устанавливаем масштаб
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        // Центрируем изображение
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // Настройка жестов свайпа
    private func setupSwipeGestures() {
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipe(_:))
        )
        swipeDown.direction = .down
        scrollView.addGestureRecognizer(swipeDown)
        swipeDown.delegate = self
        self.swipeDownGesture = swipeDown  // Сохраняем в свойство (если нужно)
        
        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipe(_:))
        )
        swipeRight.direction = .right
        scrollView.addGestureRecognizer(swipeRight)
        swipeRight.delegate = self
        self.swipeRightGesture = swipeRight  // Сохраняем в свойство (если нужно)
    }
    
    // Обработчик жестов свайпа
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil) // Закрываем контроллер при любом свайпе
    }
}

// MARK: UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    // Указываем какой view должен масштабироваться
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    // Обновляем отступы после изменения масштаба
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInset()
    }
    
    // Обновление отступов для центрирования изображения
    private func updateInset() {
        let bounds = scrollView.bounds.size
        let content = scrollView.contentSize
        
        // Рассчитываем новые отступы
        let horizontal = max(0, (bounds.width - content.width) / 2)
        let vertical = max(0, (bounds.height - content.height) / 2)
        
        // Устанавливаем отступы
        scrollView.contentInset = UIEdgeInsets(
            top: vertical,
            left: horizontal,
            bottom: vertical,
            right: horizontal
        )
    }
}

// MARK: UIGestureRecognizerDelegate

extension SingleImageViewController: UIGestureRecognizerDelegate {
    // Разрешаем одновременную работу нескольких жестов
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
    
    // Определяем условия срабатывания жестов
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let swipeGesture = gestureRecognizer as? UISwipeGestureRecognizer {
            return switch swipeGesture.direction {
            case .down:
                // Свайп вниз работает только когда scrollView вверху
                scrollView.contentOffset.y <= 0
            case .right:
                // Свайп вправо работает только когда scrollView слева
                scrollView.contentOffset.x <= 0
            default: true
            }
        }
        return true
    }
}
