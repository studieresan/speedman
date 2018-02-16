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
      Firebase.removeCheckin(checkinId: checkin.id)
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
    cell.textLabel?.text = "\(user.fullName)"

    // Setup cell depending on checked in or not
    if let checkin = checkins.first(where: { $0.userId == user.id }) {
      let time = dateFormatter.string(from: checkin.checkedInAt)
      cell.detailTextLabel?.text = "\(time)"
      cell.accessoryType = .checkmark
    } else {
      cell.detailTextLabel?.text = " "
      cell.accessoryType = .none
    }
    return cell
  }

  // MARK - UITableViewDelegate
  // Return an action to call a person on left swipe on user cell
  override func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let user = users[indexPath.row]

    let empty = UISwipeActionsConfiguration()
    guard let number = user.phone?
      .replacingOccurrences(of: " ", with: "") else { return empty }
    guard let callURL = URL(string: "tel://\(number)") else { return empty }
    guard UIApplication.shared.canOpenURL(callURL) else { return empty }

    // If there's a number that can be made into an URL and called, setup action
    let call = UIContextualAction(style: .normal, title: "Call") {
      _ ,_ , completion in
      UIApplication.shared.open(callURL)
      completion(true)
    }
    call.image = UIImage(named: "PhoneIcon")
    // TODO: Break out color to constant class
    call.backgroundColor = #colorLiteral(red: 0.1876, green: 0.2319, blue: 0.2957, alpha: 1)
    return UISwipeActionsConfiguration(actions: [call])
  }

}
