//
//  BottomSheetController.swift
//  MedicalRecordsUI
//
//  Created by Arya Vashisht on 18/01/25.
//

import UIKit
import SnapKit
import SwiftUI

/// Use this to add swiftUI View inside bottom sheet
/// It will only expand to the swiftUI View's intrinsic height
/// Make sure while presentation the modal transition style is overFullscreen

final class BottomSheetController: UIViewController {
  
  // MARK: - Properties
  
  var shouldDisableOverlayView: Bool = false {
    didSet {
      overlayView.isUserInteractionEnabled = !shouldDisableOverlayView
    }
  }
  
  var swiftUIView: any View
  
  private let overlayView = UIView()
  
  // MARK: - Init
  
  init(swiftUIView: any View) {
    self.swiftUIView = swiftUIView
    super.init(nibName: nil, bundle: nil)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycles
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    overlayView.backgroundColor = .clear
    setupSubviews()
    setupTouchGestures()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 0.2) { [weak self] in
      self?.overlayView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    overlayView.backgroundColor = .clear
  }
}

// MARK: - Subview Setup

extension BottomSheetController {
  private func setupSubviews() {
    view.addSubview(overlayView) /// Added Overlay view as background item in bottom sheet
    
    /// Swift UI Hosting View
    let controller = UIHostingController(rootView: AnyView(swiftUIView))
    let hostingView: UIView = controller.view
    hostingView.backgroundColor = .clear
    view.addSubview(hostingView)
    hostingView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalTo(view)
      make.height.lessThanOrEqualTo(UIScreen.main.bounds.height * 0.80)
    }
    
    /// Overlay view
    overlayView.snp.makeConstraints { make in
      make.leading.trailing.top.equalTo(view)
      make.bottom.equalTo(hostingView.snp.top).offset(EkaSpacing.spacingL) /// Extending overlay view to make bottom sheet top corner radius visible
    }
  }
}

// MARK: - Action Responders

extension BottomSheetController {
  private func setupTouchGestures() {
    let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapOverlay))
    self.overlayView.addGestureRecognizer(gesture)
  }
  
  @objc
  private func onTapOverlay() {
    dismiss(animated: true)
  }
}
