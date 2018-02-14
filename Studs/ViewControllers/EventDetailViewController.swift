//
//  EventDetailViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-30.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import MapKit

class EventDetailViewController: UIViewController {

  // MARK: - Outlets
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!

  // MARK: - Properties
  var event: Event!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    descriptionLabel.numberOfLines = 0

    title = event.companyName
    descriptionLabel.text = event.privateDescription

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
        self.mapView.showAnnotations([pin], animated: true)
      }
    } else {
      mapView.isHidden = true
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "checkInSegue" else {
      return
    }

    if let checkinVC = segue.destination as? CheckInTableViewController {
      checkinVC.event = self.event
    }
  }
}
