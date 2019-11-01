//
//  SettingsViewController.swift
//  Spectrogeddon
//
//  Created by Tom York on 12/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit
import SpectroCoreiOS

protocol SettingsViewControllerDelegate: class {
    func didTapBackground()
    func didChangeSetting()
}

class SettingsViewController : UIViewController {
    
    weak var delegate: SettingsViewControllerDelegate?
    
    private var barView: UIVisualEffectView! = {
        return UIVisualEffectView(effect: UIBlurEffect(style: .dark)).usingAutolayout()
    }()
    
    private var stackView: UIStackView! = {
        let stack = UIStackView().usingAutolayout()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()
    
    private let presenter: SettingsPresenter
    
    init(store: SettingsStore) {
        self.presenter = SettingsPresenter(store: store)
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Settings", comment: "Title of the settings screen")
        presenter.client = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not supported for use in Storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.accept(action: .didAppear)
    }
    
    private func createUI() {
        
        guard barView.superview != view, stackView.arrangedSubviews.isEmpty else { return }
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(didTapOnBackground))
        view.addGestureRecognizer(tapper)

        barView.contentView.addSubview(stackView)
        view.addSubview(barView)
        
        stackView.pinToSuperviewEdges()
        barView.pinToSuperviewEdges(edges: [.bottom, .left, .right])
        barView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let barItems = [
            makeSettingButton(action: .nextScrollingSpeed, title: NSLocalizedString("Speed", comment: "")),
            makeSettingButton(action: .nextSharpness, title: NSLocalizedString("Clarity", comment: "")),
            makeSettingButton(action: .toggleLogFrequencyScale, title: NSLocalizedString("Scale", comment: "")),
            makeSettingButton(action: .nextColorMap, title: NSLocalizedString("Colors", comment: ""))
        ]
        
        barItems.forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func updateUI() {
        guard isViewLoaded else { return }
        // Nothing to do
    }
    
    private func makeSettingButton(action: SettingsPresenter.Action, title: String) -> SettingButton {
        
        return SettingButton(title: title, handler: { [weak self] in
            self?.presenter.accept(action: action)
        })
    }
    
    @objc
    private func didTapOnBackground() {
        delegate?.didTapBackground()
    }
}

extension SettingsViewController: SettingsPresenterClient {

    func settingsPresenterDidUpdate(_ update: SettingsPresenter.Update) {

        switch update {
        case .settingsUpdate:
            updateUI()
            delegate?.didChangeSetting()
        }
    }
}
