//
//  LoadingViewController.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 15/08/23.
//

import UIKit

class LoadingViewController: UIViewController {
    
    private let loadingView = {
        let busy = UIActivityIndicatorView(style: .large)
        busy.translatesAutoresizingMaskIntoConstraints = false
        busy.startAnimating()
        return busy
    }()
    private let loadingLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.text = "LOADING\n\nMedia is being prepared for casting..."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    private lazy var dismissButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitle("OK", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(dismissVC), for: .touchDown)
        button.isHidden = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        view.addSubview(loadingView)
        view.addSubview(loadingLabel)
        view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: 50),
            loadingLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            loadingLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    
    func presentError(error: Error) {
        loadingView.stopAnimating()
        loadingLabel.text = "Couldn't prepare media for casting. The Following error ocurred during the process: \(error.localizedDescription) - \(error)"
        dismissButton.isHidden = false
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
}
