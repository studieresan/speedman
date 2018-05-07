//
//  MapViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-07.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var buttonsView: UIView!
  @IBOutlet weak var userLocationButton: UIButton!

  // MARK: - Properties
  private let locationManager = CLLocationManager()

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
}
