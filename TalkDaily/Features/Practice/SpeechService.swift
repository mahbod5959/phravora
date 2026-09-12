import AVFoundation
import Speech
import UIKit

@MainActor
final class SpeechService: NSObject, ObservableObject {
    @Published private(set) var transcript = ""
    @Published private(set) var isRecording = false
    @Published var error: AppError?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func toggleRecording() { isRecording ? stop() : requestAuthorizationAndStart() }
    func requestAndStartRecording() async throws {
        let speechStatus = await withCheckedContinuation { continuation in SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) } }
        guard speechStatus == .authorized else { error = .speechRecognitionDenied; throw AppError.speechRecognitionDenied }
        let microphoneGranted = await withCheckedContinuation { continuation in AVAudioApplication.requestRecordPermission { continuation.resume(returning: $0) } }
        guard microphoneGranted else { error = .microphoneDenied; throw AppError.microphoneDenied }
        do { try startRecordingEngine() } catch { self.error = .audioUnavailable; stop(); throw AppError.audioUnavailable }
    }
    func openSettings() { guard let url = URL(string: UIApplication.openSettingsURLString) else { return }; UIApplication.shared.open(url) }

    private func requestAuthorizationAndStart() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self else { return }
                guard status == .authorized else { self.error = .speechRecognitionDenied; return }
                AVAudioApplication.requestRecordPermission { granted in DispatchQueue.main.async { if granted { try? self.startRecordingEngine() } else { self.error = .microphoneDenied } } }
            }
        }
    }

    private func startRecordingEngine() throws {
        error = nil; transcript = ""; task?.cancel()
        let request = SFSpeechAudioBufferRecognitionRequest(); request.shouldReportPartialResults = true; self.request = request
        let input = audioEngine.inputNode
        task = recognizer?.recognitionTask(with: request) { [weak self] result, recognitionError in
            DispatchQueue.main.async { if let result { self?.transcript = result.bestTranscription.formattedString }; if recognitionError != nil || result?.isFinal == true { self?.stop() } }
        }
        let format = input.outputFormat(forBus: 0); input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in self?.request?.append(buffer) }
        try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement); try AVAudioSession.sharedInstance().setActive(true); audioEngine.prepare(); try audioEngine.start(); isRecording = true
    }

    func stop() { audioEngine.stop(); audioEngine.inputNode.removeTap(onBus: 0); request?.endAudio(); isRecording = false }
    deinit { task?.cancel() }
}
