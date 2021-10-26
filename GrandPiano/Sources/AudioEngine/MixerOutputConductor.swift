//
//  MixerOutputConductor.swift
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

class MixerOutputConductor: OutputConductor {

  // MARK: - Public Properties

  public private(set) var output: Mixer
  public              var volume: AUValue {
    set {
      output.volume = newValue
    }
    get {
      return output.volume
    }
  }


  // MARK: - Initialization

  required init() {
    output = Mixer([], name: "MixerOutputConductor")
  }


  // MARK: - OutputConductor

  func addInput<Input>(_ input: Input) throws where Input : InputConductor {
    let wasRunning = output.isStarted

    if wasRunning {
      stop()
    }
    output.addInput(input.input)

    if wasRunning {
      try start()
    }
  }


  // MARK: - Conductor

  func start() throws {
    output.start()
  }

  func stop() {
    output.stop()
  }
}
