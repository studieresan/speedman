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
      self.refreshControl?.endRefreshing()
      tableView.reloadData()
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
      navigationItem.prompt = activity.title
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
  }

  deinit {
    registrationSubscription?.unsubscribe()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    stateSubscription = store.subscribe { [weak self] state in
      self?.users = state.users
    }
    self.tableView.triggerRefresh()
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
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      return users.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
      let user = users[indexPath.row]
      cell.accessoryType = registrations.contains { user.id == $0.userId }
        ? .checkmark
        : .none
      cell.textLabel?.text = user.fullName
      return cell
  }
}

// MARK: UITableViewDelegate
extension TripActivityRegistrationTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let user = users[indexPath.row]
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
}
