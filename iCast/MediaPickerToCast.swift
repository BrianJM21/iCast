//
//  MediaPickerToCast.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 14/08/23.
//

import UIKit

class MediaPickerToCast: UIImagePickerController {
    
    convenience init(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        self.init()
        self.sourceType = .photoLibrary
        if let mediaTypes = Self.availableMediaTypes(for: .photoLibrary) {
            self.mediaTypes = mediaTypes
        }
        self.delegate = delegate
    }
    
}
