//
//  TripActivityDetailViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-05.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  A detail-view for trip activities

import UIKit

class TripActivityDetailViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var cardView: CardViewWithColorStrip!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!

  @IBOutlet weak var priceIcon: UIButton!
  @IBOutlet weak var priceStackView: UIStackView!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var peopleIcon: UIButton!
  @IBOutlet weak var peopleLabel: UILabel!
  @IBOutlet weak var registerButton: UIButton!

  @IBOutlet weak var descriptionTextView: UITextView!

  @IBOutlet var separators: [UIView]!

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
        priceStackView.isHidden = activity.price == nil
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
    setupTheming() // Themable
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

extension TripActivityDetailViewController: Themable {
  func applyTheme(_ theme: Theme) {
    cardView.backgroundColor = theme.backgroundColor
    backButton.tintColor = theme.secondaryTextColor
    backButton.setTitleColor(theme.secondaryTextColor, for: .normal)
    titleLabel.textColor = theme.primaryTextColor
    dateLabel.textColor = theme.secondaryTextColor
    locationLabel.textColor = theme.secondaryTextColor
    priceLabel.textColor = theme.primaryTextColor
    priceIcon.tintColor = theme.secondaryTextColor
    peopleLabel.textColor = theme.primaryTextColor
    peopleIcon.tintColor = theme.secondaryTextColor
    descriptionTextView.textColor = theme.primaryTextColor
    descriptionTextView.tintColor = theme.tintColor
    registerButton.tintColor = theme.tintColor
    separators.forEach { $0.backgroundColor = theme.separatorColor }
  }
}
