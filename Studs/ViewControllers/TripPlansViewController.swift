//
//  TripPlansViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-10.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripPlansViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var tableView: UITableView!

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

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
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
        tripCell.titleLabel.text = activity.description
        tripCell.dateLabel.text =
          DateFormatter.dateAndTimeFormatter.string(from: activity.startDate)
        tripCell.locationLabel.text = activity.location.address
        tripCell.peopleCountLabel.text = "\(activity.peopleCount) going"
        tripCell.categoryButton.setImage(activity.category.icon, for: .normal)
        tripCell.categoryButton.tintColor = activity.category.color
        tripCell.registerButtonTappedAction = { [weak store] in
          store?.dispatch(action: .selectActivity(activity))
        }
      }
      return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return activities.count
  }
}
