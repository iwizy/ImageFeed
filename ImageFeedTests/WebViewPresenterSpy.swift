//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Alexander Agafonov on 31.05.2025.
//

import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
  var viewDidLoadCalled = false
  var view: WebViewViewControllerProtocol?

  func viewDidLoad() {
    viewDidLoadCalled = true
  }

  func didUpdateProgressValue(_ newValue: Double) { }

  func code(from url: URL) -> String? {
    nil
  }
}
