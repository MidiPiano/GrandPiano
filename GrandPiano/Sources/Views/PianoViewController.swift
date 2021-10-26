//
//  PianoViewController.swift
//  GrandPiano
//
//  Created by Thomas Bonk on 23.10.21.
//  Copyright 2021 Thomas Bonk <thomas@meandmymac.de>
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit
import AudioKit
import Logging
import PianoView

@objc class PianoViewController: NSViewController, VolumeHandler {

  // MARK: - Private Properties

  @IBOutlet internal var deviceSelector: NSComboBox!
  @IBOutlet internal var piano: PianoView!

  @objc dynamic internal var volume: Int = 50 {
    didSet {
      setVolume(volume)
    }
  }

  internal var log: Logger = {
    var logger = Logger(label: "PianoViewController")

    logger.logLevel = .trace

    return logger
  }()

  internal var inputConductor: MidiInputConductor!
  internal var outputConductor: MixerOutputConductor!
  internal var audioEngine: AudioEngineConductor!
  internal var endpointInfos: [EndpointInfo] = []


  // MARK: - NSViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    // TODO Error handling
    inputConductor = try? MidiInputConductor(keyboardHandler: piano, volumeHandler: self, midiSetupChangedHandler: self)
    outputConductor = MixerOutputConductor()
    try? outputConductor.addInput(inputConductor)
    audioEngine = try? AudioEngineConductor(output: outputConductor)
    try? inputConductor.start()
    try? outputConductor.start()
    try? audioEngine.start()
  }


  // MARK: - Private Methods

  func setVolume(_ volume: Int) {
    let vol = Float(volume) / 100.0

    NSSound.systemVolume = vol
    outputConductor?.volume = vol * 10.0
  }
}
