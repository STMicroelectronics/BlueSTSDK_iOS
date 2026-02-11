//
//  BlueVoiceViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CorePlot
import STBlueSDK
import STCore

class BlueVoiceViewController: BaseNodeViewController {
    
    let stackView = UIStackView()
    let beamformingSwitch = UISwitch()
    let beamformingLabel = UILabel()
    
    private var audioFeature: Feature?
    private var controlFeature: Feature?
    private var beamFormingFeature: Feature?
    
    private var audioPlayer: AudioPlayer?
    
    private var audioPlotView: CPTGraphHostingView = CPTGraphHostingView(frame: .zero)
    private var audioPlotDataSource: AudioPlotDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioFeature = bestAudioFeature()
        controlFeature = bestAudioControlFeature()
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(audioPlotView)
        stackView.addArrangedSubview(UIView(frame: .zero))
        
        view.addSubview(stackView)
        
        beamformingSwitch.addTarget(self, action: #selector(BlueVoiceViewController.beamformingSwitchStateDidChange(_:)), for: .valueChanged)
        beamformingLabel.text = "Beamforming"
        
        stackView.addArrangedSubview(beamformingLabel)
        stackView.addArrangedSubview(beamformingSwitch)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            //stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            audioPlotView.heightAnchor.constraint(equalToConstant: 200.0)
        ])
    }
    
    @objc func beamformingSwitchStateDidChange(_ sender:UISwitch){
        if (sender.isOn == true){
            if let feature = self.node.characteristics.first(with: BeamFormingFeature.self) {
                beamFormingFeature = feature
                BlueManager.shared.enableNotifications(for: node, feature: feature)
        
                guard let beamFormingFeature = self.beamFormingFeature else { return }
                
                let command = BeamFormingCommand.enable(enabled: true)
                
                BlueManager.shared.sendCommand(FeatureCommand(type: command, data: command.payload),
                                               to: self.node,
                                               feature: beamFormingFeature)
                
                Logger.debug(text: command.description)
                
                let command2 = BeamFormingCommand.setDirection(direction: .right)
                
                BlueManager.shared.sendCommand(FeatureCommand(type: command2, data: command2.payload),
                                               to: self.node,
                                               feature: beamFormingFeature)
                
                Logger.debug(text: command2.description)

                let command3 = BeamFormingCommand.setBeamType(beamType: .strong)

                BlueManager.shared.sendCommand(FeatureCommand(type: command3, data: command3.payload),
                                               to: self.node,
                                               feature: beamFormingFeature)

                Logger.debug(text: command3.description)
            }
        }
        else{
            if let feature = self.node.characteristics.first(with: BeamFormingFeature.self) {
                beamFormingFeature = feature
                BlueManager.shared.disableNotifications(for: node, feature: feature)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let audioFeature = audioFeature,
              let controlFeature = controlFeature else { return }
        
        BlueManager.shared.disableNotifications(for: node, feature: audioFeature)
        BlueManager.shared.disableNotifications(for: node, feature: controlFeature)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        audioPlotDataSource = AudioPlotDataSource(view: audioPlotView,
                                                  reDrawAfterSample: 3)
        
        guard let audioFeature = audioFeature as? AudioDataFeature,
              let controlFeature = controlFeature else { return }
        
        BlueManager.shared.enableNotifications(for: node, feature: controlFeature)
        BlueManager.shared.enableNotifications(for: node, feature: audioFeature)
        
        self.audioPlayer = AudioPlayer(audioFeature.codecManager)
    }
    
    override func deinitController() {

    }
    
    public func hasDarkTheme() -> Bool {
        if #available(iOS 13, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
    
    override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
    
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            if let audioFeature = feature as? AudioDataFeature,
               let sample = sample as? FeatureSample<ADPCMAudioData>,
               let data = sample.data?.audio,
               let audioPlayer = self.audioPlayer,
               feature.type.uuid == audioFeature.type.uuid {
                Logger.debug(text: feature.description(with: sample))
                
                audioPlayer.playSample(sample: data)
                
                self.updateAudioPlot(data)
            } else {
                if let audioFeature = self.audioFeature as? AudioDataFeature,
                   let controlFeature = self.controlFeature,
                   let sample = sample,
                   feature.type.uuid == controlFeature.type.uuid {
                    Logger.debug(text: feature.description(with: sample))
                    
                    audioFeature.codecManager.updateParameters(from: sample)
                }
            }
        }
    }
}

private extension BlueVoiceViewController {
    func bestAudioFeature() -> Feature? {
        
        if let feature = self.node.characteristics.first(with: OpusAudioFeature.self) {
            return feature
        }
        
        return self.node.characteristics.first(with: ADPCMAudioFeature.self)
    }
    
    func bestAudioControlFeature() -> Feature? {
        
        if let feature = self.node.characteristics.first(with: OpusAudioConfFeature.self) {
            return feature
        }
        
        return self.node.characteristics.first(with: ADPCMAudioSyncFeature.self)
    }
    
    func updateAudioPlot(_ sample: Data) {
        
        let value = sample.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> Int16? in
            return ptr.bindMemory(to: Int16.self).first
        }
        
        if let value = value {
            audioPlotDataSource.appendToPlot(value)
        }
    
    }
    
}
