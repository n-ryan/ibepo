//
//  InputViewController.swift
//  ibepo
//
//  Created by Steve Gigou on 2020-05-02.
//  Copyright © 2020 Novesoft. All rights reserved.
//

import UIKit


// MARK: - InputViewController

/// Full keyboard view
final class InputViewController: UIViewController {
  
  /// Delegate that will get text CRUD.
  weak var delegate: KeyboardActionProtocol?
  
  private var autocorrectViewController: AutocorrectViewController!
  private var keypadViewController: KeypadViewController!
  private var keypadHeightConstraint: NSLayoutConstraint!
  private var autocorrectHeightConstraint: NSLayoutConstraint!
  
  private var rowHeight: CGFloat {
    if UIDevice.current.userInterfaceIdiom == .phone {
      if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
        return 50.0
      } else {
        return 45.0
      }
    } else {
      if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
        return 75.0
      } else {
        return 70.0
      }
    }
  }
  
  
  // MARK: Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadViews()
  }
  
  
  // MARK: Configuration
  
  /**
   Refresh document proxy values.
   */
  func update(textDocumentProxy: UITextDocumentProxy) {
    KeyboardSettings.shared.update(textDocumentProxy)
    autocorrectViewController.autocorrect.update()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    updateHeights()
  }
  
  // MARK: Loading
  
  private func loadViews() {
    loadKeypadView()
    loadSuggestionsView()
  }
  
  private func loadKeypadView() {
    keypadViewController = KeypadViewController()
    keypadViewController.delegate = self
    add(keypadViewController, with: [
      keypadViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      keypadViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      keypadViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])
    keypadHeightConstraint = NSLayoutConstraint(item: keypadViewController.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: rowHeight * 4)
    keypadHeightConstraint.isActive = true
    keypadViewController.view.layer.zPosition = 10.0
  }
  
  private func loadSuggestionsView() {
    autocorrectViewController = AutocorrectViewController()
    autocorrectViewController.delegate = self
    add(autocorrectViewController, with: [
      autocorrectViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      autocorrectViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      autocorrectViewController.view.bottomAnchor.constraint(equalTo: keypadViewController.view.topAnchor),
      autocorrectViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])
    autocorrectHeightConstraint = NSLayoutConstraint(item: autocorrectViewController.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: rowHeight)
    autocorrectHeightConstraint.isActive = true
  }
  
  private func updateHeights() {
    autocorrectHeightConstraint.constant = rowHeight
    keypadHeightConstraint.constant = rowHeight * 4
  }
  
}


// MARK: - KeyboardActionProtocol

extension InputViewController: KeyboardActionProtocol {
  
  func insert(text: String) {
    if let replacement = autocorrectViewController.autocorrect.correction(for: text) {
      replace(charactersAmount: KeyboardSettings.shared.textDocumentProxyAnalyzer.currentWord.count, by: "\(replacement)")
    } else {
      delegate?.insert(text: text)
      autocorrectViewController.autocorrect.update()
    }
  }
  
  func replace(charactersAmount: Int, by text: String) {
    deleteBackward(amount: charactersAmount)
    delegate?.insert(text: text)
    autocorrectViewController.autocorrect.update()
  }
  
  func deleteBackward() {
    delegate?.deleteBackward()
    autocorrectViewController.autocorrect.update()
  }
  
  func deleteBackward(amount: Int) {
    if amount == 0 { return }
    delegate?.deleteBackward(amount: amount)
    autocorrectViewController.autocorrect.update()
  }
  
  func nextKeyboard() {
    delegate?.nextKeyboard()
  }
  
}
