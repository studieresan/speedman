//
//  TripScheduleViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

protocol TripScheduleViewControllerDelegate: class {
  /// Tells the delegate that the user selected a specific trip activity in the list
  func tripScheduleViewController(_ tripScheduleVC: TripScheduleViewController,
                                  didSelectTripActivity activity: TripActivity)
}

class TripScheduleViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var tableView: UITableView!

  // MARK: - Properties
  weak var delegate: TripScheduleViewControllerDelegate?
  private var activities = [TripActivity]() {
    didSet {
      tableView.reloadData()
    }
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.delegate = self
    tableView.dataSource = self

    Firebase.streamActivities { self.activities = $0 }
  }
}

// MARK: - MapViewControllerDelegate
extension TripScheduleViewController: MapViewControllerActivitiesDelegate {
  // Select and scroll to the cell when user selects activity pin in map
  func mapViewController(_ mapVC: MapViewController,
                         didSelectTripActivity activity: TripActivity) {
    guard let row = activities.index(of: activity) else { return }
    let indexPath = IndexPath(row: row, section: 0)
    tableView.selectRow(at: indexPath,
                        animated: true,
                        scrollPosition: .top)
  }

  // Deselect selected cell when a pin is deselected in the map
  func mapViewControllerDidDeselectAnnotations(_ mapVC: MapViewController) {
    if let indexpath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexpath, animated: true)
    }
  }
}

// MARK: - UITableViewDelegate
extension TripScheduleViewController: UITableViewDelegate {
  // Forward the activity of the cell to the delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let activity = activities[indexPath.row]
    delegate?.tripScheduleViewController(self, didSelectTripActivity: activity)
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
