//
//  MediaPickerToCastExtension.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 16/08/23.
//
import UIKit

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        let loadingView = LoadingViewController()
        loadingView.modalPresentationStyle = .fullScreen
        present(loadingView, animated: true)
        if let avURL = info[.mediaURL] as? URL {
            if let avData = try? NSData(contentsOf: avURL, options: .mappedIfSafe) as Data {
                Task {
                    do {
                        try await mediaStorageService.upload(mediaData: avData, mediaTypePath: .avPath)
                        guard let urlCast = try await mediaStorageService.download(mediaTypePath: .avPath) else { return }
                        Caster.shared.startCast(withURL: urlCast, metaTitle: "Video from Photolibrary", metaSubtitle: "Casting media from local Photolibrary", metaImage: .photoLibraryMetaImage)
                        loadingView.dismiss(animated: false) {
                            Caster.shared.presentDefaultExpandedMediaControls()
                        }
                    } catch {
                        print(error)
                        loadingView.presentError(error: error)
                    }
                }
            }
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = image.pngData() {
            Task {
                do {
                    try await mediaStorageService.upload(mediaData: imageData, mediaTypePath: .imagePath)
                    guard let urlCast = try await mediaStorageService.download(mediaTypePath: .imagePath) else { return }
                    Caster.shared.startCast(withURL: urlCast, metaTitle: "Image from Photolibrary", metaSubtitle: "Casting media from local Photolibrary", metaImage: .photoLibraryMetaImage)
                    loadingView.dismiss(animated: false) {
                        Caster.shared.presentDefaultExpandedMediaControls()
                    }
                } catch {
                    print(error)
                    loadingView.presentError(error: error)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
