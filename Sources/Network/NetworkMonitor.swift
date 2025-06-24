//
//  NetworkMonitor.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 23/06/25.
//

import Foundation
import Network
import Combine

final class NetworkMonitor {
  static let shared = NetworkMonitor()
  
  private let monitor: NWPathMonitor
  private let queue = DispatchQueue(label: "NetworkMonitorQueue")
  
  // Publishes network availability changes
  private let subject = CurrentValueSubject<Bool, Never>(true)
  var publisher: AnyPublisher<Bool, Never> {
    subject.eraseToAnyPublisher()
  }

  private init() {
    monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { [weak self] path in
      self?.subject.send(path.status == .satisfied)
    }
    monitor.start(queue: queue)
  }
}
