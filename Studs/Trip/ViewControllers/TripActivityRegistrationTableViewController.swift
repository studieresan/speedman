//
//  TripActivityRegistrationTableViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-06.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  Viewcontroller for registering people to trip activities

import UIKit

class TripActivityRegistrationTableViewController: UITableViewController {
  // MARK: - Properties
  private lazy var store = (UIApplication.shared.delegate as? AppDelegate)!.tripStore
  private var stateSubscription: Subscription<TripState>?
  private lazy var activity: TripActivity! = self.store.state.selectedActivity
  private var users = [User]() {
    didSet {
      guard oldValue != users else { return }
      tableView.reloadData()
    }
  }
  private var registeredUsers: [User] {
    return users.filter { user in
      return registrations.contains(where: { $0.userId == user.id })
    }
  }
  private var unregisteredUsers: [User] {
    return users.filter { user in
      return !registrations.contains(where: { $0.userId == user.id })
    }
  }
  private var registrations = [TripActivityRegistration]() {
    didSet { tableView.reloadData() }
  }
  private let haptic = UISelectionFeedbackGenerator()
  private var registrationSubscription: Subscription<[TripActivityRegistration]>?

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    if let activity = activity {
      navigationItem.prompt = activity.title ?? activity.description
      registrationSubscription =
        Firebase.streamActivityRegistrations(activityId: activity.id) { [weak self] in
        self?.registrations = $0
      }
    } else {
      dismiss(animated: true)
    }
    // Setup swipe down to refresh action
    refreshControl?.addTarget(self, action: #selector(fetchUsers),
                              for: .valueChanged)

    setupTheming() // Themable
  }

  deinit {
    registrationSubscription?.unsubscribe()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    stateSubscription = store.subscribe { [weak self] state in
      self?.users = state.users
      if state.pendingUsersFetchRequest {
        self?.refreshControl?.beginRefreshing()
      } else {
        self?.refreshControl?.endRefreshing()
      }
    }
  }

  @objc func fetchUsers() {
    store.dispatch(action: .fetchUsers)
  }

  @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true)
  }
}

// MARK: UITableViewDataSource
extension TripActivityRegistrationTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
    -> String? {
      return section == 0 ? "Registered" : "Not Registered"
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      return section == 0 ? registeredUsers.count : unregisteredUsers.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
      let row = indexPath.row
      let user = indexPath.section == 0 ? registeredUsers[row] : unregisteredUsers[row]
      cell.accessoryType = registrations.contains { user.id == $0.userId }
        ? .checkmark
        : .none
      cell.textLabel?.text = user.fullName
      applyThemeToCell(cell, theme: themeManager.currentTheme)
      return cell
  }
}

// MARK: UITableViewDelegate
extension TripActivityRegistrationTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let row = indexPath.row
    let user = indexPath.section == 0 ? registeredUsers[row] : unregisteredUsers[row]
    guard let actingUser = UserManager.shared.user else { return }
    if let registration = registrations.first(where: { user.id == $0.userId }) {
      Firebase.removeActivityRegistration(registrationId: registration.id,
                                          activityId: activity.id)
    } else {
      Firebase.addActivityRegistration(userId: user.id,
                                       byUserId: actingUser.id,
                                       activityId: activity.id)
    }
    haptic.selectionChanged()
  }

  override func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
      let user = users[indexPath.row]

      let empty = UISwipeActionsConfiguration()
      guard
        let number = user.phone?
          .replacingOccurrences(of: " ", with: "")
          .replacingOccurrences(of: "-", with: ""),
        let callURL = URL(string: "tel://\(number)"),
        UIApplication.shared.canOpenURL(callURL)
        else { return empty }

      // If there's a number that can be made into an URL and called, setup action
      let call = UIContextualAction(style: .normal, title: "Call") { _, _, completion in
        UIApplication.shared.open(callURL)
        completion(true)
      }
      call.image = UIImage(named: "Phone")
      call.backgroundColor = UIColor(named: "StudsBlue")
      return UISwipeActionsConfiguration(actions: [call])
  }
}

extension TripActivityRegistrationTableViewController: Themable {
  func applyThemeToCell(_ cell: UITableViewCell, theme: Theme) {
    cell.backgroundColor = theme.backgroundColor
    cell.tintColor = theme.tintColor
    cell.textLabel?.textColor = theme.primaryTextColor
  }

  func applyTheme(_ theme: Theme) {
    tableView.visibleCells.forEach { applyThemeToCell($0, theme: theme) }
    tableView.separatorColor = theme.separatorColor
    view.backgroundColor = theme.backgroundColor
    tableView.refreshControl?.tintColor = theme.tintColor
    navigationItem.rightBarButtonItem?.tintColor = theme.tintColor
    navigationController?.navigationBar.barStyle = theme.barStyle
  }
}
