//
//  EventDetailViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-30.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

  // MARK: - Outlets
  @IBOutlet weak var descriptionLabel: UILabel!

  // MARK: - Properties
  var event: Event!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    descriptionLabel.numberOfLines = 0

    title = event.companyName
    descriptionLabel.text = event.privateDescription
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "checkInSegue" else {
      return
    }

    if let checkinVC = segue.destination as? CheckInTableViewController {
      checkinVC.event = self.event
    }
  }
}
