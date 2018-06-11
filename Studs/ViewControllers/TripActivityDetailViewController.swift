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
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var cardView: CardViewWithColorStrip!
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
      if let activity = activity, !activity.isUserActivity {
        titleLabel.text = activity.title
        dateLabel.text =
          DateFormatter.dateAndTimeFormatter.string(from: activity.startDate)
        locationLabel.text = activity.location.address
        peopleLabel.text = "\(activity.peopleCount) people going"
        priceLabel.text = activity.price

        let attributedDescription = NSAttributedString(
          html: activity.description,
          font: descriptionTextView.font ??
            UIFont.systemFont(ofSize: UIFont.systemFontSize),
          color: descriptionTextView.textColor ?? .black
        )
        descriptionTextView.attributedText = attributedDescription
        cardView.colorStripColor = activity.category.color
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
      self?.activity = state.selectedActivity
      self?.scrollView.isScrollEnabled = state.drawerPosition == .open
      self?.scrollView.contentInset =
        UIEdgeInsets(top: 0.0, left: 0.0,
                     bottom: CGFloat(state.drawerBottomSafeArea), right: 0.0)
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
