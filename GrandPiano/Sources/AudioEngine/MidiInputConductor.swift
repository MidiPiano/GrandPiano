//
//  MidiInputConductor.swift
//  GrandPiano
//
//  Created by Thomas Bonk on 25.10.21.
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

import AudioKit
import AVFoundation
import Logging
import MusicTheory

protocol KeyboardHandler {
  func selectNote(note: Pitch, velocity: MIDIVelocity)
  func deselectNote(note: Pitch, velocity: MIDIVelocity)
}

protocol VolumeHandler {
  var volume: Int { get set }
}

protocol MidiSetupChangedHandler {
  func midiSetupChanged(endpointInfos: [EndpointInfo])
}

class MidiInputConductor: InputConductor, MIDIListener {

  // MARK: - Public Properties

  public private(set) var input: MIDISampler
  public              var midiEndpoint: EndpointInfo? = nil {
    willSet {
      if let endpoint = midiEndpoint {
        midi.closeInput(uid: endpoint.midiUniqueID)
      }
    }
    didSet {
      if let endpoint = midiEndpoint {
        midi.openInput(uid: endpoint.midiUniqueID)
      }
    }
  }


  // MARK: - Private Typealiases

  private typealias MIDIControlHandler = (MIDIByte, MIDIChannel) -> ()


  // MARK: - Private Properties

  private  var log: Logger = {
    var logger = Logger(label: "MidiInputConductor")

    logger.logLevel = .trace

    return logger
  }()
  private  var midi = MIDI()
  private  var keyboardHandler: KeyboardHandler
  internal var volumeHandler: VolumeHandler
  private  var midiSetupChangedHandler: MidiSetupChangedHandler
  private  var midiControl: [MIDIControl:MIDIControlHandler]!


  // MARK: - Initialization

  init(
            keyboardHandler: KeyboardHandler,
              volumeHandler: VolumeHandler,
    midiSetupChangedHandler: MidiSetupChangedHandler) throws {

    self.keyboardHandler = keyboardHandler
    self.volumeHandler = volumeHandler
    self.midiSetupChangedHandler = midiSetupChangedHandler
    
    input = MIDISampler(name: "Piano")
    try input.loadSoundFont("Piano", preset: 0, bank: 0)

    midiControl = [
      .mainVolume: setVolumeFromMidi(value:channel:)
    ]

      midi.addListener(self)
  }


  // MARK: - Conductor

  func start() throws {
    input.start()
  }

  func stop() {
    input.stop()
  }


  // MARK: - MIDIListener

  func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
    log.debug("receivedMIDINoteOn(noteNumber: \(noteNumber), velocity: \(velocity), channel: \(channel), portID: \(String(describing: portID)), timeStamp: \(String(describing: portID)))")

    guard midiEndpoint?.midiUniqueID == portID else {
      return
    }

    input.play(noteNumber: noteNumber, velocity: velocity, channel: channel)

    DispatchQueue.main.async {
      self.keyboardHandler.selectNote(note: Pitch(midiNote: Int(noteNumber)), velocity: velocity)
    }
  }

  func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
    log.debug("receivedMIDINoteOff(noteNumber: \(noteNumber), velocity: \(velocity), channel: \(channel), portID: \(String(describing: portID)), timeStamp: \(String(describing: timeStamp)))")

    guard midiEndpoint?.midiUniqueID == portID else {
      return
    }

    input.stop(noteNumber: noteNumber, channel: channel)

    DispatchQueue.main.async {
      self.keyboardHandler.deselectNote(note: Pitch(midiNote: Int(noteNumber)), velocity: velocity)
    }
  }

  func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
    log.debug("receivedMIDIController(_ controller: \(controller), value: \(value), channel: \(channel), portID: \(String(describing: portID)), timeStamp: \(String(describing: timeStamp))")

    guard midiEndpoint?.midiUniqueID == portID else {
      return
    }

    guard let control = self.midiControl[MIDIControl(rawValue: controller)!] else {
      return
    }

    control(value, channel)
  }

  func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
    log.debug("receivedMIDIAftertouch(noteNumber: \(noteNumber), pressure: \(pressure), channel: \(channel), portID: \(String(describing: portID)), timeStamp: \(String(describing: timeStamp)))")
  }

  func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
    log.debug("receivedMIDIAftertouch(_ pressure: \(pressure), channel: \(channel), portID: \(String(describing: portID)), timeStamp: \(String(describing: portID)))")
  }

  func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
    log.debug("receivedMIDIPitchWheel(_ pitchWheelValue: \(pitchWheelValue), channel: \(channel), portID: \(String(describing: portID)), timeStamp: \(String(describing: timeStamp)))")

    guard midiEndpoint?.midiUniqueID == portID else {
      return
    }

    input.setPitchbend(amount: pitchWheelValue, channel: channel)
  }

  func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
    log.debug("receivedMIDIProgramChange(_ program: \(program), channel: \(channel), portID: \(String(describing: portID)), timeStamp: \(String(describing: timeStamp)))")
  }

  func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
    log.debug("receivedMIDISystemCommand(_ data: \(data), portID: \(String(describing: portID)), timeStamp: \(String(describing: timeStamp)))")
  }

  func receivedMIDISetupChange() {
    log.debug("receivedMIDISetupChange()")

    DispatchQueue.main.async {
      self.midiSetupChangedHandler.midiSetupChanged(endpointInfos: self.midi.inputInfos)
    }
  }

  func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
    log.debug("receivedMIDIPropertyChange(propertyChangeInfo: \(propertyChangeInfo))")
  }

  func receivedMIDINotification(notification: MIDINotification) {
    log.debug("receivedMIDINotification(notification: \(notification))")
  }
}
