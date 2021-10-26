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
import STKAudioKit

struct MetronomeData {
  var isPlaying = false
  var tempo: BPM = 120
  var timeSignatureTop: Int = 4
  var downbeatNoteNumber = MIDINoteNumber(ShakerType.bigRocks.rawValue)
  var beatNoteNumber = MIDINoteNumber(ShakerType.littleRocks.rawValue)
  var beatNoteVelocity = 100.0
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

  public private(set) var input: Shaker


  // MARK: - Private Properties
  private var sequencer = Sequencer()


  // MARK: - Initialization

  init() {
    input = Shaker()
    sequencer = Sequencer()

    _ = sequencer.addTrack(for: input)

    updateSequencer()
  }

  func updateSequencer() {
    let track = sequencer.tracks.first!

    track.length = Double(data.timeSignatureTop)

    track.clear()
    track.sequence.add(noteNumber: data.downbeatNoteNumber, position: 0.0, duration: 0.4)
    let vel = MIDIVelocity(Int(data.beatNoteVelocity))
    for beat in 1 ..< data.timeSignatureTop {
      track.sequence.add(noteNumber: data.beatNoteNumber, velocity: vel, position: Double(beat), duration: 0.1)
    }

    /*track = sequencer.tracks[1]
    track.length = Double(data.timeSignatureTop)
    track.clear()
    for beat in 0 ..< data.timeSignatureTop {
      track.sequence.add(noteNumber: MIDINoteNumber(beat), position: Double(beat), duration: 0.1)
    }
     */
  }


  // MARK: - InputConductor

  func start() throws {
    input.start()
    sequencer.playFromStart()
  }

  func stop() {
    input.stop()
    sequencer.stop()
  }
}
