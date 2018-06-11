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
  private var createActivityTable: CreateTripActivityTableViewController!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: - Actions
  @IBAction func cancelButtonTapped(_ sender: Any) {
    self.dismiss(animated: true)
  }

  @IBAction func doneButtonTapped(_ sender: Any) {
    validateAndSubmit()
  }

  func validateAndSubmit() {
    let title = createActivityTable.activityTitle
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard !title.isEmpty else {
      return showErrorPopup(message: "Activity title cannot be empty!")
    }
    guard let address = createActivityTable.address, !address.isEmpty else {
      return showErrorPopup(message: "Address cannot be empty!")
    }
    guard let clLocation = createActivityTable.location else {
      return showErrorPopup(message: "No coordinates available for address. Rewrite it!")
    }
    guard createActivityTable.startDate > createActivityTable.endDate else {
      return showErrorPopup(message: "Activity has to start before it ends!")
    }
    guard let user = UserManager.shared.user else {
      return showErrorPopup(message: "You are not even logged in!")
    }
    let location = TripActivity.Location(address: address,
                                         coordinate: clLocation.coordinate)
    let trimmedTitle = title.replacingOccurrences(of: " ", with: "-")
    let id = String(format: "\(trimmedTitle)-%08X", arguments: [arc4random()])
    let activity = TripActivity(id: id,
                                city: nil,
                                category: createActivityTable.activityCategory,
                                title: nil,
                                description: title,
                                price: nil,
                                location: location,
                                createdDate: Date(),
                                startDate: createActivityTable.startDate,
                                endDate: createActivityTable.endDate,
                                peopleCount: 0,
                                isUserActivity: true,
                                author: user.id)
    Firebase.addOrUpdateActivity(activity)
    self.dismiss(animated: true)
  }

  func showErrorPopup(message: String) {
    let alert = UIAlertController(title: "Input Error",
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "I'll fix it!", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    createActivityTable = segue.destination as? CreateTripActivityTableViewController
  }
}
