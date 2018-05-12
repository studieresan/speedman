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
  private lazy var store: Store! = (UIApplication.shared.delegate as? AppDelegate)?.store
  private var unsubsribeFromStore: Disposable?
  private var activities = [TripActivity]() {
    didSet {
      guard activities != oldValue else { return }
      tableView.reloadData()
    }
  }
  private var selectedActivity: TripActivity? {
    didSet {
      guard selectedActivity != oldValue else { return }
      if let activity = selectedActivity {
        guard let row = activities.index(of: activity) else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.selectRow(at: indexPath,
                            animated: true,
                            scrollPosition: .top)
      } else {
        guard let indexpath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: indexpath, animated: true)
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
    activities = store.state.activities
    unsubsribeFromStore = store?.subscribe { [weak self] state in
      self?.activities = state.activities
      self?.selectedActivity = state.selectedActivity
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    unsubsribeFromStore?()
  }
}

// MARK: - UITableViewDelegate
extension TripScheduleViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let activity = activities[indexPath.row]
    store.activitySelected(activity)
    store.setDrawerPosition(isVerticallyCompact ? .collapsed : .partiallyRevealed)
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
