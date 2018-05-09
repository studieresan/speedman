//
//  MapViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-07.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate: MapViewControllerActivitiesDelegate {}
protocol MapViewControllerActivitiesDelegate: MapViewControllerCommonDelegate {
  func mapViewController(_ mapVC: MapViewController,
                         didSelectTripActivity activity: TripActivity)
}
protocol MapViewControllerCommonDelegate: class {
  func mapViewControllerDidDeselectAnnotations(_ mapVC: MapViewController)
}

class MapViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var buttonsView: UIView!
  @IBOutlet weak var userLocationButton: UIButton!

  // MARK: - Properties
  weak var delegate: MapViewControllerDelegate?
  private let locationManager = CLLocationManager()
  private var shouldZoomToPins = true
  var activities = [TripActivity]() {
    didSet {
      pinsToActivities.removeAll()
      activities.forEach { activity in
        let pin = MKPointAnnotation()
        pin.coordinate = activity.location.coordinate
        pin.title = activity.title
        pin.subtitle = activity.location.address
        pinsToActivities[pin] = activity
        activitiesToPins[activity] = pin
      }
      updateActivityPins()
    }
  }
  // TODO: Replace with bidirectional dict
  private var pinsToActivities = [MKPointAnnotation: TripActivity]()
  private var activitiesToPins = [TripActivity: MKPointAnnotation]()

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
    Firebase.streamActivities { self.activities = $0 }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // TODO: Move this up to pulley controller.
    if let tripTabVC =
      pulleyViewController?.drawerContentViewController as? TripTabBarController {
      tripTabVC.tripScheduleDelegate = self
    }
  }

  // MARK: - UI Refresh
  /// Updates the pin annotations of the map to match the current list of activities
  private func updateActivityPins() {
    let newPins = pinsToActivities.keys
    // Get the diffs and only update those
    // Se MKPointAnnotation extension below
    let pinsOnMap = mapView.annotations.compactMap({ $0 as? MKPointAnnotation })
    let annotationsToRemove = pinsOnMap.filter({ !newPins.contains($0) })
    let annotationsToAdd = newPins.filter({ !pinsOnMap.contains($0) })
    mapView.removeAnnotations(annotationsToRemove)
    mapView.addAnnotations(annotationsToAdd)

    if shouldZoomToPins {
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
extension MapViewController: MKMapViewDelegate {
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

  // When an annotation is selected we'll pass on the actual TripActivity to the delegate
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let pin = view.annotation as? MKPointAnnotation,
      let activity = pinsToActivities[pin] {
      delegate?.mapViewController(self, didSelectTripActivity: activity)
    }
  }

  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    delegate?.mapViewControllerDidDeselectAnnotations(self)
  }
}

// MARK: - TripScheduleViewControllerDelegate
extension MapViewController: TripScheduleViewControllerDelegate {
  // Select and zoom to pin in map when selected in schedule
  func tripScheduleViewController(_ tripScheduleVC: TripScheduleViewController,
                                  didSelectTripActivity activity: TripActivity) {
    if let pin = activitiesToPins[activity] {
      mapView.selectAnnotation(pin, animated: true)
      mapView.showAnnotations([pin], animated: true)
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
        self.title == other.title
    } else {
      return false
    }
  }
}
