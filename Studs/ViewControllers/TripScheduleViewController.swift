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
      highlightSelectedActivity()
    }
  }
  private var selectedActivity: TripActivity? {
    didSet {
      guard oldValue != selectedActivity else { return }
      highlightSelectedActivity()
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
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stateSubscription?.unsubscribe()
  }

  /// Selects the currently selected activity in the table, or deselects all cells if none
  private func highlightSelectedActivity() {
    if let activity = selectedActivity {
      self.selectActivityInTable(activity)
    } else {
      self.deselectAllSelections()
    }
  }

  /// Selects (highlights) an activity in the table
  private func selectActivityInTable(_ activity: TripActivity) {
    guard let row = activities.index(of: activity) else { return }
    let indexPath = IndexPath(row: row, section: 0)
    tableView.selectRow(at: indexPath,
                        animated: true,
                        scrollPosition: .top)
  }

  /// Deselects all selected cells of the table
  private func deselectAllSelections() {
    tableView.indexPathsForSelectedRows?.forEach {
      tableView.deselectRow(at: $0, animated: true)
    }
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
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      let activity = activities[indexPath.row]
      cell.textLabel?.text = activity.title
      cell.detailTextLabel?.text = activity.location.address
      return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return activities.count
  }
}
