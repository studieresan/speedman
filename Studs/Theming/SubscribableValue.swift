//
//  SubscribableValue.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-26.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

/// A box that allows us to weakly hold on to an object
struct Weak<Object: AnyObject> {
  weak var value: Object?
}

/// Stores a value of type T, and allows objects to subscribe to
/// be notified with this value is changed.
struct SubscribableValue<T> {
  private typealias Subscription = (object: Weak<AnyObject>, handler: (T) -> Void)
  private var subscriptions: [Subscription] = []

  var value: T {
    didSet {
      for (object, handler) in subscriptions where object.value != nil {
        handler(value)
      }
    }
  }

  init(value: T) {
    self.value = value
  }

  mutating func subscribe(_ object: AnyObject, using handler: @escaping (T) -> Void) {
    subscriptions.append((Weak(value: object), handler))
    cleanupSubscriptions()
  }

  private mutating func cleanupSubscriptions() {
    subscriptions = subscriptions.filter({ entry in
      return entry.object.value != nil
    })
  }
}
