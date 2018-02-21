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
  @IBOutlet weak var onePasswordButton: UIButton!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    emailField.delegate = self
    passwordField.delegate = self
    onePasswordButton.isHidden =
      !OnePasswordExtension.shared().isAppExtensionAvailable()
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
        return // TODO: show user error
    }
    activityIndicator.startAnimating()
    API.login(email: email, password: password) { result in
      self.activityIndicator.stopAnimating()
      switch result {
      case .success():
        self.performSegue(withIdentifier: "loginSegue", sender: self)
      case .failure(let error):
        // TODO: Show some error to user
        print(error)
      }
    }
  }

  // MARK: - UITextFieldDelegate
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
    OnePasswordExtension.shared().findLogin(forURLString: "https://studieresan.se", for: self, sender: sender, completion: { (loginDictionary, error) in
      guard let loginDictionary = loginDictionary else {
        if let error = error as NSError?, error.code != AppExtensionErrorCodeCancelledByUser {
          print("Error invoking 1Password App Extension for find login: \(String(describing: error))")
        }
        return
      }

      self.emailField.text = loginDictionary[AppExtensionUsernameKey] as? String
      self.passwordField.text = loginDictionary[AppExtensionPasswordKey] as? String
    })
  }
}
