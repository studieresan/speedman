//
//  TripTabBarController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripTabBarController: PulleyCompatibleTabBarController {
  // MARK: - Properties
  weak var tripScheduleDelegate: TripScheduleViewControllerDelegate?

  private var isVerticallyCompact: Bool {
    return self.traitCollection.verticalSizeClass == .compact
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupDelegates()
  }

  /// Setup ourself as the delegate viewcontrollers of each tab.
  /// This is done to intercept delegate events to change the drawer height.
  /// The delegate action is then passed on up.
  private func setupDelegates() {
    guard let viewControllers = viewControllers else { return }
    for vc in viewControllers {
      switch vc {
      case let scheduleVC as TripScheduleViewController:
        scheduleVC.delegate = self
      default:
        return
      }
    }
  }
}

// MARK: - TripScheduleViewControllerDelegate
extension TripTabBarController: TripScheduleViewControllerDelegate {
  // Passes on the delegate action and changes drawer position
  func tripScheduleViewController(_ tripScheduleVC: TripScheduleViewController,
                                  didSelectTripActivity activity: TripActivity) {
    tripScheduleDelegate?.tripScheduleViewController(tripScheduleVC,
                                                     didSelectTripActivity: activity)
    if isVerticallyCompact {
      pulleyViewController?.setDrawerPosition(position: .collapsed,
                                              animated: true)
    } else {
      pulleyViewController?.setDrawerPosition(position: .partiallyRevealed,
                                              animated: true)
    }
  }
}
