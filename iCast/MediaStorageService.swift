//
//  MediaStorageService.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 14/08/23.
//

import Foundation
import FirebaseStorage

class MediaStorageService {
    
    private let mediaStorage = Storage.storage().reference()
    
    func upload(mediaData: Data, mediaTypePath: MediaTypePath) async throws {
        _ = try await mediaStorage.child(mediaTypePath.rawValue).putDataAsync(mediaData)
    }
    
    func download(mediaTypePath: MediaTypePath) async throws -> URL? {
        return try await mediaStorage.child(mediaTypePath.rawValue).downloadURL()
    }
}
