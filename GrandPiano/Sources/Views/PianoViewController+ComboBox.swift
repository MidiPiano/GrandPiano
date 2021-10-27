//
//  PianoViewController+ComboBox.swift
//  GrandPiano
//
//  Created by Thomas Bonk on 24.10.21.
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
import AVFoundation
import MusicTheory

extension PianoViewController: NSComboBoxDataSource, NSComboBoxDelegate, MidiSetupChangedHandler {

  // MARK: - NSComboBoxDataSource

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue value: String) -> Int {
    guard comboBox == deviceSelector else {
      return NSNotFound
    }

    return endpointInfos.firstIndex { inputInfo in inputInfo.displayName == value } ?? NSNotFound
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    guard comboBox == deviceSelector else {
      return nil
    }

    return endpointInfos[index].displayName
  }

  func numberOfItems(in comboBox: NSComboBox) -> Int {
    guard comboBox == deviceSelector else {
      return 0
    }

    return endpointInfos.count
  }


  // MARK: - NSComboBoxDelegate

  func comboBoxSelectionDidChange(_ notification: Notification) {
    guard deviceSelector.indexOfSelectedItem != -1 else {
      inputConductor.midiEndpoint = nil
      return
    }

    inputConductor.midiEndpoint = endpointInfos[deviceSelector.indexOfSelectedItem]
  }


  // MARK: - MidiSetupChangedHandler

  func midiSetupChanged(endpointInfos: [EndpointInfo]) {
    self.endpointInfos = endpointInfos
    self.deviceSelector.reloadData()

    if endpointInfos.first(where: { info in
      inputConductor.midiEndpoint != nil && info.midiUniqueID == inputConductor.midiEndpoint!.midiUniqueID
    }) == nil {
      deviceSelector.deselectItem(at: 0)
    }

    if endpointInfos.count > 0 {
      DispatchQueue.main.async {
        self.deviceSelector.selectItem(at: 0)
        self.deviceSelector.objectValue = self.endpointInfos[0].displayName
      }
    }
  }
}
