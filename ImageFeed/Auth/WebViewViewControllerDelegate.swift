//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Делегат WebView Controller

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
