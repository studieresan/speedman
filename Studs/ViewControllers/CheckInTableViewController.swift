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
    // Toggle checkin
    if !checkins.contains(where: { $0.userId == user.id }) {
      Firebase.addCheckin(userId: user.id, byUserId: user.id, eventId: event.id)
    } else {
      if let index = checkins.index(where: { $0.userId == user.id }) {
        let checkin = checkins[index]
        Firebase.removeCheckin(checkinId: checkin.id)
      }
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

    // Checkmark if checked in
    cell.accessoryType = checkins.contains { $0.userId == user.id }
      ? .checkmark
      : .none
    return cell
  }

}
