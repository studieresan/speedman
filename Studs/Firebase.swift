//
//  Firebase.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-02-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  This handles all communication with the Firebase "Cloud Firestore" DB.
//  In order to connect to the db, the API keys .plist will have to be included
//  in the project: https://support.google.com/firebase/answer/7015592
//

import Foundation
import UIKit
import FirebaseFirestore

struct Firebase {

  /// Add a check-in for a user at a specific event.
  /// The current timestamp is used as checkin time.
  /// `byUserId` is the acting user checking in someone.
  static func addCheckin(userId: String, byUserId: String, eventId: String) {
    // TODO: Look into a way to do this better
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    guard let db = appDelegate.firestoreDB else { return }

    db.collection("checkins").addDocument(data: [
      "eventId": eventId,
      "userId": userId,
      "checkedInById": byUserId,
      "checkedInAt": DateFormatter.iso8601Fractional.string(from: Date()),
      ]) { err in
        if let err = err {
          print("Error adding document: \(err)")
        }
    }
  }

  /// Remove the check-in with a specific id from an event
  static func removeCheckin(checkinId: String) {
    // TODO: Look into a way to do this better
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    guard let db = appDelegate.firestoreDB else { return }

    db.collection("checkins").document(checkinId).delete() { err in
      if let err = err {
        print("Error removing document: \(err)")
      }
    }
  }

  /// Stream updates from the check-in database
  static func streamCheckins(eventId: String, handler: @escaping ([EventCheckin]) -> Void) {
    // TODO: Look into a way to do this better
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    guard let db = appDelegate.firestoreDB else { return }

    db.collection("checkins").whereField("eventId", isEqualTo: eventId)
      .addSnapshotListener { querySnapshot, error in
        guard let documents = querySnapshot?.documents else {
          print("Error fetching documents: \(error!)")
          return
        }
        let checkins = documents.map { (doc) -> EventCheckin in
          let date = DateFormatter.iso8601Fractional.date(from: doc["checkedInAt"]! as! String)
          return EventCheckin(
            id: doc.documentID,
            eventId: doc["eventId"]! as! String,
            userId: doc["userId"]! as! String,
            checkedInById: doc["checkedInById"]! as! String,
            checkedInAt: date ?? Date()
          )
        }
        handler(checkins)
    }
  }
}
