//
//  EventsTableViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

  // MARK: - Properties
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E dd/MM, HH:mm"
    return dateFormatter
  }()
  private var events = [Event]()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Events"

    fetchEvents()
    // Setup swipe down to refresh action
    refreshControl?.addTarget(self, action: #selector(fetchEvents),
                              for: .valueChanged)
  }

  // MARK: -
  /// Fetch events from API and reload table view
  @objc func fetchEvents() {
    API.getEvents() { result in
      switch result {
      case .success(let events):
        self.events = events.sorted() { (e1, e2) in
          guard let e1Date = e1.date else { return false }
          guard let e2Date = e2.date else { return false }
          return e1Date.timeIntervalSince(e2Date) < 0
        }
        self.tableView.reloadData()
      case .failure(let error):
        print(error)
      }
    }
    // If triggered by manual refresh, end the animation
    self.refreshControl?.endRefreshing()
  }

  // MARK: - Actions
  @IBAction func logout(_ sender: UIBarButtonItem) {
    API.logout()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let logInCtrl = storyboard.instantiateViewController(withIdentifier: "loginVC")
    self.present(logInCtrl, animated: true) {}
  }

  // MARK: - UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return events.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell",
                                             for: indexPath)

    let event = events[indexPath.row]
    if let eventsCell = cell as? EventTableViewCell {
      eventsCell.nameLabel.text = event.companyName
      eventsCell.dateLabel.text = nil
      if let date = event.date {
        eventsCell.dateLabel?.text = dateFormatter.string(from: date)
      }
      eventsCell.locationLabel.text = event.location
    }
    return cell
  }

  // MARK: - Navigation
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "eventDetailSegue", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "eventDetailSegue" else {
      return
    }

    if let selectedCell = tableView.indexPathForSelectedRow {
      if let eventsVC = segue.destination as? EventDetailViewController {
        eventsVC.event = events[selectedCell.row]
      }
    }
  }

}
