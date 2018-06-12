//
//  TripMapViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-07.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  Map view that shows trip activities either from the event group or user created ones.

import UIKit
import MapKit

class TripMapViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var buttonsView: UIView!
  @IBOutlet weak var userLocationButton: UIButton!

  // MARK: - Properties
  private lazy var store = (UIApplication.shared.delegate as? AppDelegate)!.tripStore
  private var stateSubscription: Subscription<TripState>?

  private let locationManager = CLLocationManager()
  private var shouldZoomToPins = true
  private var activities = [TripActivity]() {
    didSet {
      pinsToActivities.removeAll()
      activities.forEach { activity in
        let pin = activitiesToPins[activity] ?? MKPointAnnotation()
        pin.coordinate = activity.location.coordinate
        if activity.isUserActivity {
          pin.title = activity.description
        } else {
          pin.title = activity.title
        }
        pin.subtitle = activity.location.address
        activitiesToPins[activity] = pin
        pinsToActivities[pin] = activity
      }
      updateActivityPins()
    }
  }
  private var pinsToActivities = [MKPointAnnotation: TripActivity]()
  private var activitiesToPins = [TripActivity: MKPointAnnotation]()
  private var selectedActivity: TripActivity? {
    didSet {
      if let activity = selectedActivity {
        self.selectActivityInMap(activity)
      } else {
        self.deselectAllAnnotations()
      }
    }
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    mapView.delegate = self

    // Try to use location
    if CLLocationManager.locationServicesEnabled() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.distanceFilter = 10
    }

    addCompass()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    stateSubscription = store.subscribe { [weak self] state in
      self?.activities = state.activities.filter {
        $0.isUserActivity == (state.drawerPage == .plans)
      }
      self?.selectedActivity = self?.activities.first {
        $0.id == state.selectedActivity?.id
      }
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stateSubscription?.unsubscribe()
  }

  // MARK: - UI Updates
  /// Selects the pin of an activity in the map
  private func selectActivityInMap(_ activity: TripActivity) {
    guard let pin = activitiesToPins[activity] else { return }
    mapView.selectAnnotation(pin, animated: true)
    mapView.showAnnotations([pin], animated: true)
  }

  /// Deselects all selected annotations in the map
  private func deselectAllAnnotations() {
    mapView.annotations.forEach {
      mapView.deselectAnnotation($0, animated: true)
    }
  }

  /// Updates the pin annotations of the map to match the current list of activities
  private func updateActivityPins() {
    let newPins = pinsToActivities.keys
    // Get the diffs and only update those
    // See MKPointAnnotation extension below
    let pinsOnMap = mapView.annotations.compactMap({ $0 as? MKPointAnnotation })
    let annotationsToRemove = pinsOnMap.filter({ !newPins.contains($0) })
    let annotationsToAdd = newPins.filter({ !pinsOnMap.contains($0) })
    mapView.removeAnnotations(annotationsToRemove)
    mapView.addAnnotations(annotationsToAdd)

    if shouldZoomToPins && !mapView.annotations.isEmpty {
      mapView.showAnnotations(annotationsToAdd, animated: true)
      shouldZoomToPins = false
    }
  }

  // MARK: - Misc
  /// Adds a compass and positions it to be right under the buttons view
  private func addCompass() {
    let compassButton = MKCompassButton(mapView: mapView)
    compassButton.compassVisibility = .adaptive
    compassButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(compassButton)
    view.addConstraints([
      compassButton.topAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: 11),
      compassButton.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
    ])
  }

  /// Toggles the location tracking mode
  @IBAction func toggleLocationMode(_ sender: UIButton) {
    switch mapView.userTrackingMode {
    case .none:
      mapView.setUserTrackingMode(.follow, animated: true)
    case .follow:
      mapView.setUserTrackingMode(.followWithHeading, animated: true)
    case .followWithHeading:
      mapView.setUserTrackingMode(.none, animated: true)
    }
  }
}

// MARK: - MKMapViewDelegate
extension TripMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
    -> MKAnnotationView? {
      guard let pin = annotation as? MKPointAnnotation else { return nil }
      guard let activity = pinsToActivities[pin] else { return nil }
      let marker = MKMarkerAnnotationView()
      marker.markerTintColor = activity.category.color
      marker.glyphImage = activity.category.icon?.addingImagePadding(x: 12, y: 12)
      marker.displayPriority = .required
      return marker
  }

  // Updates the location button with the correct image for the current mode
  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    switch mode {
    case .none:
      userLocationButton.setImage(#imageLiteral(resourceName: "Navigation"), for: .normal)
    case .follow:
      userLocationButton.setImage(#imageLiteral(resourceName: "Navigation+Active"), for: .normal)
    case .followWithHeading:
      userLocationButton.setImage(#imageLiteral(resourceName: "Navigation+Direction"), for: .normal)
    }
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let pin = view.annotation as? MKPointAnnotation,
      let activity = pinsToActivities[pin] {
      store.dispatch(action: .selectActivity(activity))
      store.dispatch(action: .changeDrawerPosition(
        isVerticallyCompact ? .open : .partiallyRevealed
      ))
    }
  }

  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    // Dispatch the deselection async to deal with this method firing before the
    // selection one when picking a new annotation without actually deselecting first.
    DispatchQueue.main.async { [weak self] in
      self?.maybeDispatchDeselection()
    }
  }

  func maybeDispatchDeselection() {
    if mapView.selectedAnnotations.isEmpty {
      store.dispatch(action: .selectActivity(nil))
    }
  }
}

// MARK: - MKPointAnnotation
// We override the equality and hashvalue function in order to easily
// diff which pins have changed and only update those
extension MKPointAnnotation {
  override open var hashValue: Int {
    return self.coordinate.latitude.hashValue ^ self.coordinate.longitude.hashValue
  }
  override open func isEqual(_ object: Any?) -> Bool {
    if let other = object as? MKPointAnnotation {
      return self.coordinate.latitude == other.coordinate.latitude &&
        self.coordinate.longitude == other.coordinate.longitude &&
        self.title == other.title && self.subtitle == other.subtitle
    } else {
      return false
    }
  }
}

extension TripActivity.Category {
  var icon: UIImage? {
    switch self {
    case .drink:
      return UIImage(named: "Cocktail")
    case .food:
      return UIImage(named: "Food")
    case .attraction:
      return UIImage(named: "Camera")
    case .other:
      return UIImage(named: "MoreHorizontal")
    }
  }
}
