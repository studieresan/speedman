//
//  EventDetailViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-30.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  A detail view for events

import UIKit
import MapKit
import SafariServices

class EventDetailViewController: UIViewController, UIScrollViewDelegate,
UITextViewDelegate {

  // MARK: - Outlets
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var infoCard: EventInfoCard!
  @IBOutlet weak var beforeSurveyButton: BarButton!
  @IBOutlet weak var afterSurveyButton: BarButton!
  @IBOutlet weak var descriptionCard: CardView!
  @IBOutlet weak var descriptionTextView: UITextView!

  // MARK: - Properties
  var event: Event!
  private let locationManager = CLLocationManager()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.delegate = self
    descriptionTextView.delegate = self

    infoCard.setup(for: event)

    if let description = event.privateDescription, !description.isEmpty {
      descriptionTextView.text = event.privateDescription
      // Remove stupid padding
      descriptionTextView.textContainer.lineFragmentPadding = 0
    } else {
      descriptionCard.isHidden = true
    }

    configureSurveyButtons()
    configureMapView()

    // Try to use location
    if CLLocationManager.locationServicesEnabled() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.distanceFilter = 10
    }

    // Hide button to check-in manager if insufficient permissions
    if let user = UserManager.shared.user,
      !user.permissions.contains(.checkins) {
      navigationItem.rightBarButtonItem = nil
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateNavbar()
  }

  override func viewWillDisappear(_ animated: Bool) {
    locationManager.stopUpdatingLocation()
    super.viewWillDisappear(animated)
  }

  deinit {
    applyMapViewMemoryLeakFix()
  }

  /// Mitigate MKMapView memory leaks
  /// http://www.openradar.me/33400943
  private func applyMapViewMemoryLeakFix() {
    switch mapView.mapType {
    case .standard, .mutedStandard:
      mapView.mapType = .satellite
    default:
      mapView.mapType = .standard
    }
    mapView.showsUserLocation = false
    mapView.delegate = nil
    mapView.removeFromSuperview()
    mapView = nil
  }

  // MARK: -
  /// Hide the event surveys buttons conditionally.
  /// Hides the after survey before the event and hides the before survey
  /// after the event starts.
  private func configureSurveyButtons() {
    beforeSurveyButton.isHidden = event.beforeSurveys?.isEmpty ?? true
    afterSurveyButton.isHidden = event.afterSurveys?.isEmpty ?? true
    if let date = event.date {
      if date.compare(Date()) == .orderedDescending {
        afterSurveyButton.isHidden = true
      } else {
        beforeSurveyButton.isHidden = true
      }
    }
  }

  private func configureMapView() {
    // Lookup coordinates for address and place pin on map
    if let address = event.location {
      let geocoder = CLGeocoder()
      geocoder.geocodeAddressString(address) { placemarks, _ in
        guard let placemarks = placemarks else { return }
        guard let coordinate = placemarks[0].location?.coordinate else { return }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "\(self.event.companyName ?? ""): \(address)"
        self.mapView.addAnnotation(pin)
        self.mapView.showAnnotations([pin], animated: false)
        // Zoom out map a bit
        self.mapView.setRegion({
            var region = self.mapView.region
            var span = region.span
            span.latitudeDelta *= 3
            span.longitudeDelta *= 3
            region.span = span
            return region
          }(),
          animated: false)
      }
    } else {
      mapView.isHidden = true
    }
  }

  // MARK: - Custom navbar management
  private lazy var navbar = navigationController?.navigationBar as? CustomNavigationBar
  func updateNavbar() {
    if scrollView.contentOffset.y + scrollView.adjustedContentInset.top > 190 {
      navbar?.style = .translucent
    } else {
      navbar?.style = .faded
    }
  }

  // MARK: - Actions
  @IBAction func beforeSurveyTapped(_ sender: UITapGestureRecognizer) {
    guard let url = event.beforeSurveys?.first else { return }
    openURL(url: url)
  }

  @IBAction func afterSurveyTapped(_ sender: UITapGestureRecognizer) {
    guard let url = event.afterSurveys?.first else { return }
    openURL(url: url)
  }

  /// Open the given url in a SFSafariViewController
  private func openURL(url: String) {
    guard let url = URL(string: url) else { return }
    let safariVC = SFSafariViewController(url: url)
    self.present(safariVC, animated: true)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case "checkInSegue":
      if let checkinVC = segue.destination as? EventCheckinTableViewController {
        checkinVC.event = self.event
      }
    case "checkinButtonSetupSegue":
      if let buttonVC = segue.destination as? EventCheckinButtonViewController {
        buttonVC.event = self.event
        // Make the container view size itself to the embedded VC
        buttonVC.view.translatesAutoresizingMaskIntoConstraints = false
      }
    default:
      break
    }
  }

  // MARK: - UITextViewDelegate
  func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    // Open URLs from textview in in app browser instead of external
    openURL(url: URL.absoluteString)
    return false
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    updateNavbar()
  }
}
