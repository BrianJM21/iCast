//
//  ScreenRecorder.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 15/08/23.
//

import Foundation
import ReplayKit

class ScreenRecorder {
    
    init(mediaStorageService: MediaStorageService) {
        self.mediaStorageService = mediaStorageService
    }
    
    private let mediaStorageService: MediaStorageService
    private let recorder = RPScreenRecorder.shared()
    var isRecording: Bool {
        recorder.isRecording
    }
    
    func toggleScreenCasting() {
        if recorder.isRecording {
            recorder.stopCapture { error in
                guard error == nil else { print(error!); return}
            }
        } else {
            recorder.startCapture { sampleBuffer, sampleBufferType, error in
                guard error == nil else { print(error!); return }
                self.handleSampleBuffer(sampleBuffer, sampleBufferType)
            } completionHandler: { error in
                guard error == nil else { print(error!); return }
            }
        }
    }
    
    private func handleSampleBuffer(_ sampleBuffer: CMSampleBuffer, _ sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video: handleVideoFrame(sampleBuffer)
        case .audioApp: handleAudio(sampleBuffer)
        default: break
        }
    }
    
    private func handleVideoFrame(_ sampleBuffer: CMSampleBuffer) {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
        let image = UIImage(cgImage: cgImage)
        guard let imageData = image.pngData() else { return }
        Task {
            do {
                try await mediaStorageService.upload(mediaData: imageData, mediaTypePath: .imagePath)
                let urlCast = try await mediaStorageService.download(mediaTypePath: .imagePath)
                await Caster.shared.startCastAsync(withURL: urlCast!)
            } catch {
                print(error)
            }
        }
    }
    
    private func handleAudio(_ sampleBuffer: CMSampleBuffer) {
        // Audio builder
    }
}
