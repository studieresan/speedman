//
//  CheckInTableViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-31.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class CheckInTableViewController: UITableViewController {

  // MARK: - Properties
  var event: Event!
  var users = [User]()
  var checkins = [EventCheckin]()
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    API.getUsers() { result in
      switch result {
      case .success(let users):
        self.users = users
        self.tableView.reloadData()
      case .failure(let error):
        self.navigationController?.popViewController(animated: true)
        print(error)
      }
    }
    // Stream realtime updates from the checkins-database
    Firebase.streamCheckins(eventId: event.id) { [weak self] checkins in
      self?.checkins = checkins
      self?.tableView.reloadData()
    }
  }

  // MARK: - UITableViewController
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let user = users[indexPath.row]
    guard let loggedInUser = UserManager.shared.user else { return }

    // Toggle checkin
    if let checkin = checkins.first(where: { $0.userId == user.id }) {
      if checkin.userId == loggedInUser.id ||
        checkin.checkedInById == loggedInUser.id {
        // Only allow users to remove their own checkins
        // TODO: Allow users with event permissions to modify all checkins
        Firebase.removeCheckin(checkinId: checkin.id)
      } else {
        // Show error alert
        let alert = UIAlertController(title: "Not Allowed",
                                      message: "You may only remove check-ins of yourself or check-ins done by yourself.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
      }
    } else {
      Firebase.addCheckin(userId: user.id, byUserId: loggedInUser.id,
                          eventId: event.id)
    }
  }

  // MARK: - UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "checkInCell",
                                             for: indexPath)
    let user = users[indexPath.row]
    cell.textLabel?.text = "\(user.firstName ?? "") \(user.lastName ?? "")"

    // Setup cell depending on checked in or not
    if let checkin = checkins.first(where: { $0.userId == user.id }) {
      let time = dateFormatter.string(from: checkin.checkedInAt)
      let actor = users.first(where: { $0.id == checkin.checkedInById })
      cell.detailTextLabel?.text = "\(actor?.fullName ?? "-") at \(time)"
      cell.accessoryType = .checkmark
    } else {
      cell.detailTextLabel?.text = " "
      cell.accessoryType = .none
    }
    return cell
  }

}
