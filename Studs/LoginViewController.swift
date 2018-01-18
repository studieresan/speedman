//
//  LoginViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  // MARK: Outlets
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: Actions
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    guard
      let email = emailField.text, !email.isEmpty,
      let password = passwordField.text, !password.isEmpty else {
      return // TODO: show user error
    }
    print(email, password)
  }

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}
