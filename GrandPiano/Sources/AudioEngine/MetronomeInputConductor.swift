//
//  MetronomeInputConductor.swift
//  GrandPiano
//
//  Created by Thomas Bonk on 26.10.21.
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
import AudioKitEX

struct MetronomeData {
  var isPlaying = false
  var tempo: BPM = 120
  var timeSignatureTop: Int = 4
  var downbeatNoteNumber = MIDINoteNumber(76)
  var downbeatNoteVelocity = 127.0
  var beatNoteNumber = MIDINoteNumber(77)
  var beatNoteVelocity = 127.0
  var currentBeat = 0
}

class MetronomeInputConductor: InputConductor {

  // MARK: - Public Properties

  public var data = MetronomeData() {
    didSet {
      data.isPlaying ? sequencer.play() : sequencer.stop()
      sequencer.tempo = data.tempo
      updateSequencer()
    }
  }

  public var volume: Int = 50 {
    didSet {
      input.volume = Float(volume) / 100.0
    }
  }

  public private(set) var input: AppleSampler
  public private(set) var isStarted: Bool = false


  // MARK: - Private Properties
  private var sequencer = Sequencer()


  // MARK: - Initialization

  init() throws {
    input = AppleSampler()
    try input.loadSoundFont("Metronom", preset: 115, bank: 0)
    input.volume = 0.5
    sequencer = Sequencer()

    _ = sequencer.addTrack(for: input)

    updateSequencer()
    stop()
  }

  func updateSequencer() {
    let track = sequencer.tracks.first!

    track.length = Double(data.timeSignatureTop)

    track.clear()
    track.sequence.add(noteNumber: data.downbeatNoteNumber, velocity: MIDIVelocity(Int(data.downbeatNoteVelocity)), position: 0.0, duration: 0.4)
    let vel = MIDIVelocity(Int(data.beatNoteVelocity))
    for beat in 1 ..< data.timeSignatureTop {
      track.sequence.add(noteNumber: data.beatNoteNumber, velocity: vel, position: Double(beat), duration: 0.1)
    }
  }


  // MARK: - InputConductor

  func start() throws {
    input.start()
    sequencer.playFromStart()
    isStarted = true
  }

  func stop() {
    input.stop()
    sequencer.stop()
    isStarted = false
  }
}
