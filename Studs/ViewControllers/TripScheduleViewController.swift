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

// MARK: - UITableViewDelegate
extension TripScheduleViewController: UITableViewDelegate {
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
