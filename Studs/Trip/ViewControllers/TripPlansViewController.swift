//
//  TripPlansViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-10.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  The trip plans view shows all trip activities shared by users

import UIKit

class TripPlansViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var addNewButton: UIButton!

  // MARK: - Properties
  private lazy var store = (UIApplication.shared.delegate as? AppDelegate)!.tripStore
  private var stateSubscription: Subscription<TripState>?

  private var activities = [TripActivity]() {
    didSet { tableView.reloadData() }
  }
  private var selectedActivity: TripActivity? {
    didSet {
      guard selectedActivity != oldValue else { return }
      if let activity = selectedActivity {
        selectActivityInTable(activity: activity)
      }
    }
  }
  private lazy var user = UserManager.shared.user

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    setupTheming() // Themable
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    stateSubscription = store.subscribe { [weak self] state in
      self?.activities = state.activities.filter { $0.isUserActivity }
      self?.selectedActivity = state.selectedActivity
      self?.tableView.isScrollEnabled = state.drawerPosition == .open
      self?.tableView.contentInset =
        UIEdgeInsets(top: 0.0, left: 0.0,
                     bottom: CGFloat(state.drawerBottomSafeArea + 500), right: 0.0)
    }
    store.dispatch(action: .changeDrawerPage(.plans))
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stateSubscription?.unsubscribe()
  }

  func selectActivityInTable(activity: TripActivity) {
    guard let row = activities.index(of: activity) else { return }
    guard tableView.indexPathForSelectedRow?.row != row else { return }
    tableView.selectRow(at: IndexPath(row: row, section: 0),
                        animated: true,
                        scrollPosition: .top)
  }

  func editActivity(activity: TripActivity) {
    let alert = UIAlertController(title: nil,
                                  message: nil,
                                  preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Edit", style: .default,
                                  handler: { [weak self] _ in
      self?.performSegue(withIdentifier: "editUserActivity", sender: activity)
    }))
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
      Firebase.deleteActivity(activity)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      segue.identifier == "editUserActivity",
      let navVC = segue.destination as? UINavigationController,
      let destinationVC =
        navVC.viewControllers.first as? TripActivityEditorViewController,
      let activity = sender as? TripActivity
    else { return }
    destinationVC.editingActivity = activity
  }
}

// MARK: - UITableViewDelegate
extension TripPlansViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let activity = activities[indexPath.row]
    store.dispatch(action: .selectActivity(activity))
  }
}

// MARK: - UITableViewDataSource
extension TripPlansViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "tripUserActivityCell",
                                               for: indexPath)
      let activity = activities[indexPath.row]
      if let tripCell = cell as? TripUserActivityTableViewCell {
        tripCell.editButton.isHidden = user?.id != activity.author
        tripCell.titleLabel.text = activity.description
//        tripCell.titleLabel.textColor = activity.category.color
        tripCell.dateLabel.text =
          DateFormatter.dateAndTimeFormatter.string(from: activity.startDate)
        tripCell.locationLabel.text = activity.location.address
        if let author = store.state.users.first(where: { $0.id == activity.author }) {
          tripCell.peopleCountLabel.text =
            "\(author.firstName ?? "") & \(max((activity.peopleCount - 1), 0)) others"
        } else {
          tripCell.peopleCountLabel.text = "\(activity.peopleCount)"
        }
        tripCell.categoryButton.setImage(activity.category.icon, for: .normal)
        tripCell.categoryButton.tintColor = activity.category.color
        tripCell.registerButtonTappedAction = { [weak store] in
          store?.dispatch(action: .selectActivity(activity))
        }
        tripCell.editButtonTappedAction = { [weak self] in
          self?.editActivity(activity: activity)
        }
      }
      return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return activities.count
  }
}

// MARK: - Themable
extension TripPlansViewController: Themable {
  func applyTheme(_ theme: Theme) {
    titleLabel.textColor = theme.primaryTextColor
    addNewButton.tintColor = theme.tintColor
    addNewButton.setTitleColor(theme.tintColor, for: .normal)
    addNewButton.titleLabel?.tintColor = theme.tintColor
    addNewButton.titleLabel?.textColor = theme.tintColor
  }
}
