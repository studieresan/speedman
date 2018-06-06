//
//  TripActivityDetailViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-05.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripActivityDetailViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!

  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var peopleLabel: UILabel!

  @IBOutlet weak var descriptionTextView: UITextView!

  // MARK: - Properties
  private lazy var store = (UIApplication.shared.delegate as? AppDelegate)!.tripStore
  private var stateSubscription: Subscription<TripState>?

  private var activity: TripActivity? {
    didSet {
      if let activity = activity {
        titleLabel.text = activity.title
        dateLabel.text =
          DateFormatter.dateAndTimeFormatter.string(from: activity.startDate)
        locationLabel.text = activity.location.address
        peopleLabel.text = "\(activity.peopleCount) people going"
        priceLabel.text = activity.price
        descriptionTextView.text = activity.description
      } else {
        // TODO: Create a nice animation when dismissing
        navigationController?.popViewController(animated: false)
      }
    }
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    descriptionTextView.textContainer.lineFragmentPadding = 0
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    stateSubscription = store.subscribe { [weak self] state in
      // Get the activity from the list of activites instead to make sure it's updated
      self?.activity = state.activities.first {
        $0.id == state.selectedActivity?.id ?? ""
      }
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stateSubscription?.unsubscribe()
  }

  // MARK: Actions
  @IBAction func backButtonTapped(_ sender: UIButton) {
    store.dispatch(action: .selectActivity(nil))
  }
}
