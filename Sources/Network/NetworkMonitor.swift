//
//  NetworkMonitor.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 23/06/25.
//

import Network
import Combine

final class NetworkMonitor: ObservableObject {
  static let shared = NetworkMonitor()
  
  private let monitor: NWPathMonitor
  private let queue = DispatchQueue(label: "NetworkMonitorQueue")
  
  // Expose network status as @Published for SwiftUI compatibility
  @Published private(set) var isOnline: Bool = true
  
  private var cancellables = Set<AnyCancellable>()
  
  private init() {
    monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async {
        self?.isOnline = (path.status == .satisfied)
      }
    }
    monitor.start(queue: queue)
  }
  
  /// Combine-compatible publisher for non-SwiftUI consumers
  var publisher: AnyPublisher<Bool, Never> {
    $isOnline.eraseToAnyPublisher()
  }
}
