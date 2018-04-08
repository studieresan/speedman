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
  private var events = [Event]() {
    didSet {
      upcomingEvents = events.filter({ $0.date != nil && $0.date! >= Date() })
        .sorted()
      pastEvents = events.filter({ $0.date != nil && $0.date! < Date() })
        .sorted().reversed()
      nextEvent = upcomingEvents.removeFirst()

      tableView.reloadData()
      scheduleEventsNotifications()
    }
  }
  private var nextEvent: Event? {
    didSet {
      // Set up "Next Event" card or hide view if no next event
      cardVC?.event = nextEvent
      tableView.tableHeaderView?.isHidden = nextEvent == nil
    }
  }
  private var upcomingEvents = [Event]()
  private var pastEvents = [Event]()
  private var cardVC: EventDetailCardViewController?

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    tableView.estimatedSectionHeaderHeight = 56

    // Setup swipe down to refresh action
    refreshControl?.addTarget(self, action: #selector(fetchEvents),
                              for: .valueChanged)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if events.isEmpty {
      // Manually pull to refresh once
      self.tableView.triggerRefresh()
    }
  }

  // MARK: -
  /// Fetch events from API
  @objc func fetchEvents() {
    API.getEvents { result in
      switch result {
      case .success(let events):
        self.events = events
      case .failure(let error):
        print(error)
      }
      // If triggered by manual refresh, end the animation
      self.refreshControl?.endRefreshing()
    }
  }

  private func scheduleEventsNotifications() {
    let manager = NotificationsManager.shared
    events.forEach(manager.scheduleNotifications)
  }

  private func getEvent(for indexPath: IndexPath) -> Event {
    let events = indexPath.section == 0 ? upcomingEvents : pastEvents
    return events[indexPath.row]
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
    return 2
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
    -> UIView? {
    let view = tableView.dequeueReusableCell(withIdentifier: "header")
    if let sectionHeader = view as? EventSectionHeaderTableViewCell {
      sectionHeader.sectionTitle.text = section == 0 ? "Upcoming Events" : "Past Events"
      return sectionHeader
    }
    return view
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? upcomingEvents.count : pastEvents.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
    let event = getEvent(for: indexPath)
    if let eventsCell = cell as? EventTableViewCell {
      eventsCell.nameLabel.text = event.companyName
      if let date = event.date {
        eventsCell.dateLabel.text = DateFormatter.dateFormatter.string(from: date)
      }
    }
    return cell
  }

  // MARK: - Navigation
//  @IBAction func nextEventTapped(_ sender: UITapGestureRecognizer) {
//    performSegue(withIdentifier: "nextEventSegue", sender: <#T##Any?#>)
//  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "eventDetailSegue", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case "nextEventDetailSegue":
      guard
        let event = nextEvent,
        let eventsVC = segue.destination as? EventDetailViewController
      else { return }
      eventsVC.event = event
    case "eventDetailSegue":
      guard
        let selectedCell = tableView.indexPathForSelectedRow,
        let eventsVC = segue.destination as? EventDetailViewController
      else { return }
      eventsVC.event = getEvent(for: selectedCell)
    case "detailCardSetupSegue":
      // Save a reference to the Card VC
      cardVC = segue.destination as? EventDetailCardViewController
      // Make the container view size itself to the embedded VC
      cardVC?.view.translatesAutoresizingMaskIntoConstraints = false
    default:
      break
    }
  }
}
