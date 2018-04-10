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
  private var users = [User]()
  private var checkins = [EventCheckin]()
  private var remainingUsers: [User] {
    return users.filter { user in
      return !checkins.contains(where: { $0.userId == user.id })
    }
  }
  private let haptic = UISelectionFeedbackGenerator()
  private var hidesCheckedIn = false { didSet { tableView.reloadData() }}

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableViewAutomaticDimension

    // Setup swipe down to refresh action
    refreshControl?.addTarget(self, action: #selector(fetchUsers),
                              for: .valueChanged)
    fetchUsers()

    // Stream realtime updates from the checkins-database
    Firebase.streamCheckins(eventId: event.id) { [weak self] checkins in
      self?.checkins = checkins
      self?.tableView.reloadData()
    }

    // Add switch to toggle hiding or showing of checked in people
    let hideCheckedInSwitch = UISwitch()
    hideCheckedInSwitch.isOn = false
    hideCheckedInSwitch.addTarget(self, action: #selector(switchChanged),
                                  for: .valueChanged)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: hideCheckedInSwitch)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if users.isEmpty {
      // Manually pull to refresh once
      self.tableView.triggerRefresh()
    }
  }

  @objc func switchChanged(sender: UISwitch!) {
    hidesCheckedIn = sender.isOn
  }

  @objc func fetchUsers() {
    API.getUsers { result in
      switch result {
      case .success(let users):
        self.users = users.sorted { user1, user2 in
          user1.fullName < user2.fullName
        }
        self.tableView.reloadData()
      case .failure(let error):
        self.navigationController?.popViewController(animated: true)
        print(error)
      }
      self.refreshControl?.endRefreshing()
    }
  }

  // MARK: - UITableViewController
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let user = getUser(for: indexPath)
    guard let loggedInUser = UserManager.shared.user else { return }

    // Toggle checkin
    if let checkin = checkins.first(where: { $0.userId == user.id }) {
      Firebase.removeCheckin(checkinId: checkin.id)
    } else {
      Firebase.addCheckin(userId: user.id, byUserId: loggedInUser.id,
                          eventId: event.id)
    }
    haptic.selectionChanged()
  }

  // MARK: - UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
    -> String? {
      return hidesCheckedIn
        ? "Remaining: \(users.count - checkins.count)"
        : "Checked in: \(checkins.count)/\(users.count)"
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return hidesCheckedIn ? remainingUsers.count : users.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "checkInCell",
                                             for: indexPath)
    let user = getUser(for: indexPath)
    cell.textLabel?.text = "\(user.fullName)"

    // Setup cell depending on checked in or not
    if let checkin = checkins.first(where: { $0.userId == user.id }) {
      let time = DateFormatter.timeFormatter.string(from: checkin.checkedInAt)
      cell.detailTextLabel?.text = "\(time)"
      cell.accessoryType = .checkmark
    } else {
      cell.detailTextLabel?.text = " "
      cell.accessoryType = .none
    }
    return cell
  }

  // MARK: - UITableViewDelegate
  // Return an action to call a person on left swipe on user cell
  override func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
      let user = getUser(for: indexPath)

      let empty = UISwipeActionsConfiguration()
      guard
        let number = user.phone?.replacingOccurrences(of: " ", with: ""),
        let callURL = URL(string: "tel://\(number)"),
        UIApplication.shared.canOpenURL(callURL)
      else { return empty }

      // If there's a number that can be made into an URL and called, setup action
      let call = UIContextualAction(style: .normal, title: "Call") { _, _, completion in
        UIApplication.shared.open(callURL)
        completion(true)
      }
      call.image = UIImage(named: "PhoneIcon")
      // TODO: Break out color to constant class
      call.backgroundColor = #colorLiteral(red: 0.1876, green: 0.2319, blue: 0.2957, alpha: 1)
      return UISwipeActionsConfiguration(actions: [call])
  }

  func getUser(for indexPath: IndexPath) -> User {
    return hidesCheckedIn ? remainingUsers[indexPath.row] : users[indexPath.row]
  }
}
