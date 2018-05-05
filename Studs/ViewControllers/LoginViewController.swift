//
//  LoginViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import OnePasswordExtension

class LoginViewController: UIViewController, UITextFieldDelegate {

  // MARK: Outlets
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var onePasswordButton: UIButton!
  @IBOutlet weak var errorView: CardView!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  // MARK: Properties
  var activeTextField: UITextField?
  private var error: String? {
    didSet {
      errorLabel.text = error ?? ""
      errorView.isHidden = error == nil
    }
  }

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    emailField.delegate = self
    passwordField.delegate = self
    onePasswordButton.isHidden =
      !OnePasswordExtension.shared().isAppExtensionAvailable()

    // Setup listening to keyboard events
    NotificationCenter.default
      .addObserver(self, selector: #selector(keyboardDidShow(notification:)),
                   name: .UIKeyboardDidShow, object: nil)
    NotificationCenter.default
      .addObserver(self, selector: #selector(keyboardDidHide(notification:)),
                   name: .UIKeyboardDidHide, object: nil)

    scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "FlowerPattern")!)
    contentView.backgroundColor = UIColor.clear
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Keyboard handling
  // When the keyboard appears, it might cover the active text field.
  // This allows scrolling of the view and scrolls it so that the active
  // text-field is visible
  @objc func keyboardDidShow(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
      let inset = UIEdgeInsets(top: 0, left: 0,
                               bottom: (kbSize?.height ?? 0) + 10, right: 0)
      scrollView.contentInset = inset
      scrollView.scrollIndicatorInsets = inset

      if let activeTextField = activeTextField {
        var visibleRect = self.view.frame
        visibleRect.size.height -= kbSize?.height ?? 0

        let textFieldRect = activeTextField.convert(activeTextField.frame,
                                                    to: scrollView)

        // If the active field is not visible, scroll so that it is.
        if !visibleRect.contains(textFieldRect) {
          scrollView.scrollRectToVisible(textFieldRect, animated: true)
        }
      }
    }
  }

  @objc func keyboardDidHide(notification: NSNotification) {
    scrollView.contentInset = UIEdgeInsets.zero
    scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
  }

  // MARK: Actions
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    tryLogin()
  }

  // MARK: -
  func tryLogin() {
    guard
      let email = emailField.text, !email.isEmpty,
      let password = passwordField.text, !password.isEmpty else {
        error = "Email and/or password may not be blank."
        return // TODO: show user error
    }
    activityIndicator.startAnimating()
    API.login(email: email, password: password) { result in
      self.activityIndicator.stopAnimating()
      switch result {
      case .success:
        self.error = nil
        // Get main storyboard from Info.plist
        guard let sbName =
            Bundle.main.object(forInfoDictionaryKey: "UIMainStoryboardFile") as? String
        else { return }
        let startingSB = UIStoryboard(name: sbName, bundle: nil)
        if let startingVC = startingSB.instantiateInitialViewController() {
            self.present(startingVC, animated: true)
        }
      case .failure(let error):
        self.error = "Login failed. Please check your credentials."
        print(error)
      }
    }
  }

  // MARK: - UITextFieldDelegate
  func textFieldDidBeginEditing(_ textField: UITextField) {
    activeTextField = textField
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    activeTextField = nil
  }

  // Move next text field or try to submit login
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case emailField:
      passwordField.becomeFirstResponder()
    case passwordField:
      passwordField.resignFirstResponder()
      tryLogin()
    default:
      break
    }
    return false
  }

  // MARK: - 1Password
  @IBAction func autofillFrom1Password(_ sender: UIButton) {
    // swiftlint:disable line_length
    OnePasswordExtension.shared()
      .findLogin(forURLString: "https://studieresan.se", for: self, sender: sender) { (loginDictionary, error) in
        guard let loginDictionary = loginDictionary else {
          if let error = error as NSError?,
            error.code != AppExtensionErrorCodeCancelledByUser {
            print("Error invoking 1Password App Extension for find login: \(error)")
          }
          return
        }

        self.emailField.text = loginDictionary[AppExtensionUsernameKey] as? String
        self.passwordField.text = loginDictionary[AppExtensionPasswordKey] as? String
      }
    // swiftlint:enable line_length
  }
}
