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
  @IBOutlet weak var agendaLabel: UILabel!

  // MARK: - Properties
  var event: Event!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    descriptionLabel.numberOfLines = 0
    agendaLabel.numberOfLines = 0

    title = event.companyName
    descriptionLabel.text = event.privateDescription
    agendaLabel.text = event.schedule
  }
}
