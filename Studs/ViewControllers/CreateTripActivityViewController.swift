//
//  CreateTripActivityViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import CoreLocation

class CreateTripActivityViewController: UIViewController {
  // MARK: - Properties
  private var createActivityTable: CreateTripActivityTableViewController!
  var editingActivity: TripActivity?
  private var isCreating: Bool {
    return editingActivity == nil
  }
  private lazy var user = UserManager.shared.user
  private var defaultNewActivity: TripActivity {
    let location = TripActivity.Location(
      address: "",
      coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    )
    return TripActivity(id: UUID().uuidString, city: nil, category: .attraction,
                        title: nil, description: "", price: nil, location: location,
                        createdDate: Date(), startDate: Date(), endDate: Date(),
                        peopleCount: 0, isUserActivity: true, author: user?.id)
  }

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
    let startDate = createActivityTable.startDate
    let endDate = createActivityTable.endDate
    guard startDate < endDate else {
      return showErrorPopup(message: "Activity has to start before it ends!")
    }
    let category = createActivityTable.activityCategory
    let location = TripActivity.Location(address: address,
                                         coordinate: clLocation.coordinate)

    var activity = editingActivity ?? defaultNewActivity
    activity.description = title
    activity.location.address = address
    activity.location = location
    activity.startDate = startDate
    activity.endDate = endDate
    activity.category = category

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
    if let activity = editingActivity {
      createActivityTable.activityCategory = activity.category
      createActivityTable.activityTitle = activity.description
      createActivityTable.address = activity.location.address
      let coordinate = activity.location.coordinate
      createActivityTable.location = CLLocation(latitude: coordinate.latitude,
                                                longitude: coordinate.longitude)
      createActivityTable.startDate = activity.startDate
      createActivityTable.endDate = activity.endDate
    }
  }
}
