//
//  TripScheduleViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripScheduleViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var tableView: UITableView!

  // MARK: - Properties
  private lazy var store = (UIApplication.shared.delegate as? AppDelegate)!.tripStore
  private var stateSubscription: Subscription<TripState>?

  private var activities = [TripActivity]() {
    didSet {
      guard oldValue != activities else { return }
      tableView.reloadData()
    }
  }
  private var selectedActivity: TripActivity? {
    didSet {
      guard oldValue != selectedActivity else { return }
      guard selectedActivity != nil else { return }
      let detailVC = UIStoryboard(name: "Trip", bundle: nil)
        .instantiateViewController(withIdentifier: "tripActivityDetailVC")
      navigationController?.pushViewController(detailVC, animated: false)
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
      self?.activities = state.activities
      self?.selectedActivity = state.selectedActivity
      self?.tableView.isScrollEnabled = state.drawerPosition == .open
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stateSubscription?.unsubscribe()
  }
}

// MARK: - UITableViewDelegate
extension TripScheduleViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let activity = activities[indexPath.row]
    store.dispatch(action: .selectActivity(activity))
    store.dispatch(action: .changeDrawerPosition(
      isVerticallyCompact ? .collapsed : .partiallyRevealed
    ))
  }
}

// MARK: - UITableViewDataSource
extension TripScheduleViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "tripActivityCell",
                                               for: indexPath)
      let activity = activities[indexPath.row]
      if let tripCell = cell as? TripActivityTableViewCell {
        tripCell.titleLabel.text = activity.title
        tripCell.dateLabel.text =
          DateFormatter.dateAndTimeFormatter.string(from: activity.startDate)
        tripCell.locationLabel.text = activity.location.address
      }
      return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return activities.count
  }
}
