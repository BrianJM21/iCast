//
//  MetaImageURLPath.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 16/08/23.
//

import Foundation

enum MetaImageURLPath: String {
case photoLibraryMetaImage
case urlMetaImage
    
    static func getURL(for castSource: Self) async -> URL? {
        let mediaStorageDevice = MediaStorageService()
        switch castSource {
        case .photoLibraryMetaImage: return try? await mediaStorageDevice.download(mediaTypePath: .photolibraryMetaImagePath)
        case .urlMetaImage: return try? await mediaStorageDevice.download(mediaTypePath: .urlMetaImagePath)
        }
    }
}
