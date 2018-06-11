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
    didSet { tableView.reloadData() }
  }
  private var selectedActivity: TripActivity? {
    didSet {
      guard let selectedActivity = selectedActivity,
        !selectedActivity.isUserActivity else { return }
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
      self?.activities = state.activities.filter { !$0.isUserActivity }
      self?.selectedActivity = state.selectedActivity
      self?.tableView.isScrollEnabled = state.drawerPosition == .open
      self?.tableView.contentInset =
        UIEdgeInsets(top: 0.0, left: 0.0,
                     bottom: CGFloat(state.drawerBottomSafeArea), right: 0.0)
    }
    store.dispatch(action: .changeDrawerPage(.schedule))
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
        tripCell.edgeColor = activity.category.color
      }
      return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return activities.count
  }
}

extension TripActivity.Category {
  var color: UIColor {
    switch self {
    case .attraction:
      return UIColor(named: "AttractionOrange") ?? .orange
    case .food:
      return UIColor(named: "FoodGreen") ?? .green
    case .drink:
      return UIColor(named: "DrinkPink") ?? .purple
    case .other:
      return UIColor(named: "OtherBlue") ?? .blue
    }
  }
}
