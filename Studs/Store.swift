//
//  Store.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-10.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  Redux inspired store doing and tracking state updates

import Foundation

typealias Command<Action> = (@escaping (Action) -> Void) -> Void
typealias Reducer<State, Action> = (State, Action) -> (State, Command<Action>?)

class Store<State, Action> {
  private(set) var state: State {
    didSet {
      observers.values.forEach({ $0(state) })
    }
  }
  private var observers = [UUID: (State) -> Void]()
  private var reduce: Reducer<State, Action>

  init(state: State, reduce: @escaping Reducer<State, Action>) {
    self.state = state
    self.reduce = reduce
  }

  /// Subscribes a handler that will get updates each time the state changes
  func subscribe(handler: @escaping (State) -> Void) -> Subscription<State> {
    let uuid = UUID()
    observers[uuid] = handler
    handler(state)
    // Returns a function for unsubscribing handler
    return Subscription { [unowned self] in
      self.observers.removeValue(forKey: uuid)
    }
  }

  /// Dispatches an action trhough the reducer which updates the state
  func dispatch(action: Action) {
    let (newState, command) = reduce(state, action)
    state = newState
    command? { [weak self] action in
      self?.dispatch(action: action)
    }
  }
}
