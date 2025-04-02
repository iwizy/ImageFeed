//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Вью контроллер для единичного изображения

import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage? {
            didSet {
                guard isViewLoaded else { return }
                imageView.image = image
            }
        }
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            imageView.image = image
        }
    @IBAction func backwardButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
