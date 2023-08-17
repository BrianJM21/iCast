//
//  ViewController.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 10/08/23.
//

import UIKit
import GoogleCast

class ViewController: UIViewController, GCKRequestDelegate, GCKSessionManagerListener {
    
    let mediaStorageService = MediaStorageService()
    lazy var screenRecorder = ScreenRecorder(mediaStorageService: mediaStorageService)
    lazy var mediaView = {
        let view = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 70 - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!, width: self.view.frame.width, height: 70))
        return view
    }()
    lazy var miniMediaControlsViewController = {
        let miniMediaControls = Caster.shared.createMiniMediaControlsViewController()
        miniMediaControls.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentMediaControls))
        miniMediaControls.view.addGestureRecognizer(tapGesture)
        return miniMediaControls
    }()
    lazy var screenCastButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitle("Start Casting Screen", for: .normal)
        var config = UIButton.Configuration.plain()
        config.subtitle = "- EXPERIMENTAL -"
        config.titleAlignment = .center
        button.configuration = config
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(toggleScreenCasting), for: .touchDown)
        button.isEnabled = false
        return button
    }()
    lazy var urlTextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.placeholder = "Paste URL to cast here."
        text.borderStyle = .roundedRect
        text.inputAccessoryView = keyboardToolBar
        return text
    }()
    lazy var castURLButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitle("Cast URL", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(castURL), for: .touchDown)
        button.isEnabled = false
        return button
    }()
    lazy var keyboardToolBar = {
        let toolBar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "Listo", style: .plain, target: self, action: #selector(hideKeyboard))
        let clearButton = UIBarButtonItem(title: "Borrar", style: .plain, target: self, action: #selector(clearUrlTextField))
        let pasteButton = UIBarButtonItem(title: "Pegar", style: .plain, target: self, action: #selector(pasteUrl))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.items = [clearButton, flexSpace, pasteButton, flexSpace, doneButton]
        toolBar.sizeToFit()
        return toolBar
    }()
    lazy var urlStack = {
        let stack = UIStackView(arrangedSubviews: [urlTextField, castURLButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    lazy var urlStackBottomAnchor = urlStack.bottomAnchor.constraint(equalTo: screenCastButton.topAnchor, constant: -30)
    let castButton = {
        let button = GCKUICastButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    let lightCircle = UIImageView(image: UIImage(named: "lightCircle"))
    let lightArrow = UIImageView(image: UIImage(named: "lightArrow"))
    let darkCircle = UIImageView(image: UIImage(named: "darkCircle"))
    let darkArrow = UIImageView(image: UIImage(named: "darkArrow"))
    lazy var lightStack = {
        let stack = UIStackView(arrangedSubviews: [lightCircle, lightArrow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    lazy var darkStack = {
        let stack = UIStackView(arrangedSubviews: [darkCircle, darkArrow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        Caster.shared.assignRequestDelegate(self)
        Caster.shared.assingListenerForReceivingNotifications(to: self)
        updateControlBarsVisibility()
        addChild(miniMediaControlsViewController)
        miniMediaControlsViewController.view.frame = mediaView.bounds
        title = "iCast"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cast from PhotoLibrary", style: .plain, target: self, action: #selector(castFromPhotoLibrary))
        navigationItem.rightBarButtonItem?.isEnabled = false
        var imageStack = UIStackView()
        var castButtonCenterXAnchor: NSLayoutConstraint
        var castButtonCenterYAnchor: NSLayoutConstraint
        if traitCollection.userInterfaceStyle == .light {
            imageStack = lightStack
            castButtonCenterXAnchor = castButton.centerXAnchor.constraint(equalTo: lightCircle.centerXAnchor)
            castButtonCenterYAnchor = castButton.centerYAnchor.constraint(equalTo: lightCircle.centerYAnchor)
        } else {
            imageStack = darkStack
            castButtonCenterXAnchor = castButton.centerXAnchor.constraint(equalTo: darkCircle.centerXAnchor)
            castButtonCenterYAnchor = castButton.centerYAnchor.constraint(equalTo: darkCircle.centerYAnchor)
        }
        view.addSubview(imageStack)
        imageStack.addSubview(castButton)
        view.addSubview(screenCastButton)
        view.addSubview(urlStack)
        view.addSubview(mediaView)
        mediaView.addSubview(miniMediaControlsViewController.view)
        miniMediaControlsViewController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            imageStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -75),
            castButtonCenterXAnchor,
            castButtonCenterYAnchor,
            screenCastButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            screenCastButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130),
            urlStackBottomAnchor,
            urlStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlStack.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(castState), name: NSNotification.Name.gckCastStateDidChange, object: nil)
    }
    
    @objc func castFromPhotoLibrary() {
        present(MediaPickerToCast(delegate: self), animated: true)
    }
    
    @objc func castURL() {
        let alert = UIAlertController(title: "Invalid URL", message: "The URL String is either empty or invalid. Check and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        guard let urlText = urlTextField.text, !urlText.isEmpty, let url = URL(string: urlText) else {
            present(alert, animated: true)
            return
        }
        Caster.shared.startCast(withURL: url, metaTitle: "URL Casting", metaSubtitle: url.absoluteString, metaImage: .urlMetaImage)
        Caster.shared.presentDefaultExpandedMediaControls()
    }

    @objc func toggleScreenCasting() {
        if screenRecorder.isRecording {
            screenCastButton.setTitle("Start Casting Screen", for: .normal)
            screenCastButton.backgroundColor = .systemBlue
            screenRecorder.toggleScreenCasting()
        } else {
            screenCastButton.setTitle("Stop Casting Screen", for: .normal)
            screenCastButton.backgroundColor = .systemRed
            screenRecorder.toggleScreenCasting()
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func clearUrlTextField() {
        urlTextField.text = ""
    }
    
    @objc func pasteUrl() {
        let pb = UIPasteboard.general
        urlTextField.text = pb.string
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            urlStackBottomAnchor.constant = -keyboardHeight + 130 + screenCastButton.intrinsicContentSize.height
        }
    }
    
    @objc func keyboardWillDisappear() {
        urlStackBottomAnchor.constant = -30
    }
    
    @objc func castState(_ notification: Notification) {
        if GCKCastContext.sharedInstance().castState.rawValue == 3 {
            screenCastButton.isEnabled = true
            castURLButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            screenCastButton.isEnabled = false
            castURLButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func updateControlBarsVisibility(shouldAppear: Bool = false) {
        if shouldAppear {
            mediaView.isHidden = false
        } else {
            mediaView.isHidden = true
        }
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        view.setNeedsLayout()
    }
    
    @objc func presentMediaControls() {
        Caster.shared.presentDefaultExpandedMediaControls()
    }

}
