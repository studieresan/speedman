//
//  CheckInTableViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-31.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class CheckInTableViewController: UITableViewController {

  // MARK: - Properties
  var users = [User]()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    API.getUsers() { result in
      switch result {
      case .success(let users):
        self.users = users
        self.tableView.reloadData()
      case .failure(let error):
        print(error)
      }
    }
  }

  // MARK: - UITableViewController
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }

  // MARK: - UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "checkInCell",
                                             for: indexPath)
    let user = users[indexPath.row]
    cell.textLabel?.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
    return cell
  }

}
