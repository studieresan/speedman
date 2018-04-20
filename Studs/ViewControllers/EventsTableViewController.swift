//
//  EventsTableViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {
  // MARK: - Outlets
  @IBOutlet weak var nextEventCard: EventInfoCard!

  // MARK: - Properties
  private var events = [Event]() {
    didSet {
      // Split into upcoming and past events
      let now = Date() - 60 * 60 // - 1h (to not make it switch directly on event start)
      upcomingEvents = events.filter({ $0.date != nil && $0.date! >= now })
        .sorted()
      pastEvents = events.filter({ $0.date != nil && $0.date! < now })
        .sorted().reversed()
      nextEvent = upcomingEvents.removeFirst()

      tableView.reloadData()
      scheduleEventsNotifications()
    }
  }
  private var nextEvent: Event? {
    didSet {
      tableView.tableHeaderView?.isHidden = nextEvent == nil
      guard let event = nextEvent else { return }
      nextEventCard.setup(for: event)
    }
  }
  private var upcomingEvents = [Event]()
  private var pastEvents = [Event]()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupStretchyHeader()

    // Use autolayout for determining the height of cells and section headers
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    tableView.estimatedSectionHeaderHeight = 56

    // Setup swipe down to refresh action
    refreshControl?.addTarget(self, action: #selector(fetchEvents),
                              for: .valueChanged)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateNavbar()
    if events.isEmpty {
      // Manually pull to refresh once
      self.tableView.triggerRefresh()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navbar?.tintColor = #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
  }

  // MARK: - Stretchy header
  private lazy var tableHeaderHeight = tableView.tableHeaderView?.frame.height ?? 200
  private var stretchyHeaderView: UIView!

  /// Moves the header view to a property and replaces it with a fake view of the
  /// same size
  func setupStretchyHeader() {
    stretchyHeaderView = tableView.tableHeaderView
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0,
                                                     width: 0, height: tableHeaderHeight))
    // Add the actual header view to the table
    tableView.addSubview(stretchyHeaderView)

    // Place refresh control on top of header view
    if let refreshControl = tableView.refreshControl {
      refreshControl.frame.origin.y -= tableHeaderHeight
      tableView.bringSubview(toFront: refreshControl)
    }
    updateHeaderView()
  }

  /// Updates the size of the header view as we scroll down to make it look like it
  /// stretches
  func updateHeaderView() {
    var headerRect = CGRect(x: 0, y: 0,
                            width: tableView.bounds.width, height: tableHeaderHeight)
    if tableView.contentOffset.y < 0 {
      headerRect.origin.y = tableView.contentOffset.y
      headerRect.size.height = -tableView.contentOffset.y + tableHeaderHeight
    } else {
      headerRect.origin.y = 0;
      headerRect.size.height = tableHeaderHeight;
    }
    stretchyHeaderView.frame = headerRect
  }

  // MARK: - Custom navbar management
  private lazy var navbar = navigationController?.navigationBar as? CustomNavigationBar
  private var navbarShouldBeClear: Bool {
    return tableView.contentOffset.y + tableView.adjustedContentInset.top < 10
  }
  override var prefersStatusBarHidden: Bool {
    return navbarShouldBeClear
  }
  func updateNavbar() {
    UIView.animate(withDuration: 0.2, animations: {
      self.setNeedsStatusBarAppearanceUpdate()
    })
    navbar?.style = navbarShouldBeClear ? .clear : .translucent
    navbar?.tintColor = navbarShouldBeClear ? #colorLiteral(red: 0.968627451, green: 0.8666666667, blue: 0.7882352941, alpha: 1) : #colorLiteral(red: 0.2451893389, green: 0.2986541092, blue: 0.3666122556, alpha: 1)
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
    let storyboard = UIStoryboard(name: "Events", bundle: nil)
    let logInCtrl = storyboard.instantiateViewController(withIdentifier: "loginVC")
    self.present(logInCtrl, animated: true) {}
  }

  // MARK: - UIScrollViewDelegate
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    updateHeaderView()
    updateNavbar()
  }

  // MARK: - UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
    -> UIView? {
    let view = tableView.dequeueReusableCell(withIdentifier: "header")
    if let sectionHeader = view as? EventTableViewSectionHeader {
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
    default:
      break
    }
  }
}
