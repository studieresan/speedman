//
//  CreateTripActivityViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class CreateTripActivityViewController: UIViewController {
  // MARK: - Properties
  private var createActivityTable: CreateTripActivityTableViewController?

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: - Actions
  @IBAction func cancelButtonTapped(_ sender: Any) {
    self.dismiss(animated: true)
  }

  @IBAction func doneButtonTapped(_ sender: Any) {
    if validateFields() {
      print("Fields valid")
    }
  }

  func validateFields() -> Bool {
    guard let createVC = createActivityTable else { return false }
    if createVC.activityTitle.isEmpty {
      return showErrorPopup(message: "Activity title cannot be empty!")
    }
    if (createVC.address ?? "").isEmpty {
      return showErrorPopup(message: "Address cannot be empty!")
    }
    if createVC.location == nil {
      return showErrorPopup(message: "No coordinates available for address. Rewrite it!")
    }
    if createVC.startDate > createVC.endDate {
      return showErrorPopup(message: "Activity has to start before it ends!")
    }
    return true
  }

  func showErrorPopup(message: String) -> Bool {
    let alert = UIAlertController(title: "Input Error",
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "I'll fix it!", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
    return false
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    createActivityTable = segue.destination as? CreateTripActivityTableViewController
  }
}
