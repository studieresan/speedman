//
//  Observable.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-10.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

protocol TripActions {
  func activitySelected(_ activity: TripActivity)
  func activityDeselected()
  func setDrawerPosition(_ position: DrawerPosition)
}

typealias Disposable = () -> Void

protocol Store: TripActions {
  var state: State { get }
  func subscribe(handler: @escaping (State) -> Void) -> Disposable
}

func synchronized(_ lock: Any, closure: () -> Void) {
  objc_sync_enter(lock)
  closure()
  objc_sync_exit(lock)
}

class StoreImpl: Store {
  private var observers = [UUID: ((State) -> Void)]()

  private(set) var state = State.defaultState {
    didSet {
      synchronized(observers) {
        observers.values.forEach({ $0(state) })
      }
    }
  }

  init() {
    fetchActivities()
  }

  func subscribe(handler: @escaping (State) -> Void) -> Disposable {
    let uuid = UUID()
    synchronized(observers) {
      observers[uuid] = handler
    }
    return { [unowned self] in
      synchronized(self.observers) {
        self.observers.removeValue(forKey: uuid)
      }
    }
  }

  private func fetchActivities() {
    Firebase.streamActivities { self.state.activities = $0 }
  }

  func activitySelected(_ activity: TripActivity) {
    state.selectedActivity = activity
  }

  func activityDeselected() {
    state.selectedActivity = nil
  }

  func setDrawerPosition(_ position: DrawerPosition) {
    state.drawerPosition = position
  }
}
