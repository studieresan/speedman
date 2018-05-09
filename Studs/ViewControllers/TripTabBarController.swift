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
  private weak var tripScheduleVC: TripScheduleViewController?

  private var isVerticallyCompact: Bool {
    return self.traitCollection.verticalSizeClass == .compact
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupDelegates()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // TODO: Move this up to pulley controller.
    if let mapVC =
      pulleyViewController?.primaryContentViewController as? MapViewController {
      mapVC.delegate = self
    }
  }

  /// Setup ourself as the delegate viewcontrollers of each tab and grab a hold of
  /// a reference to each vc.
  /// This is done to intercept delegate events to change the drawer height.
  /// The delegate action is then passed on.
  private func setupDelegates() {
    guard let viewControllers = viewControllers else { return }
    for vc in viewControllers {
      switch vc {
      case let scheduleVC as TripScheduleViewController:
        scheduleVC.delegate = self
        tripScheduleVC = scheduleVC
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
    pulleyViewController?.setDrawerPosition(
      position: isVerticallyCompact ? .collapsed : .partiallyRevealed,
      animated: true
    )
  }
}

extension TripTabBarController: MapViewControllerDelegate {
  func mapViewController(_ mapVC: MapViewController,
                         didSelectTripActivity activity: TripActivity) {
    tripScheduleVC?.mapViewController(mapVC,
                                      didSelectTripActivity: activity)
    pulleyViewController?.setDrawerPosition(
      position: isVerticallyCompact ? .open : .partiallyRevealed,
      animated: true
    )
  }

  func mapViewControllerDidDeselectAnnotations(_ mapVC: MapViewController) {
    if let currentVC = selectedViewController as? MapViewControllerCommonDelegate {
      currentVC.mapViewControllerDidDeselectAnnotations(mapVC)
    }
  }
}
