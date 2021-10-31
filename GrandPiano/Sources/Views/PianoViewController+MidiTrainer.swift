//
//  PianoViewController+MidiTrainer.swift
//  GrandPiano
//
//  Created by Thomas Bonk on 30.10.21.
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

import Foundation
import MusicTheory

extension PianoViewController {

  // MARK: - MidiTrainer

  internal func initializeMidiTrainer() {
    initializeLanes()
  }

  internal func initializeLanes() {
    midiTrainerView.lanes = piano.pianoKeys.reduce(into: [Pitch:Double]()) {
      $0[$1.note] = Double($1.frame.origin.x + $1.frame.width / 2)
    }
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    DispatchQueue.main.async {
      self.initializeLanes()
    }
  }

}
