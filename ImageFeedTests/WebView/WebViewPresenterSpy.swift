//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Наблюдатель WebViewPresenter

@testable import ImageFeed
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
