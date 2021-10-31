//
//  MidiTrainerView.swift
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

import Cocoa
import MusicTheory

class MidiTrainerView: NSView {

  // MARK: - Public Properties

  public var lanes: [Pitch:Double] = [:] {
    didSet {
      DispatchQueue.main.async {
        self.needsDisplay = true
      }
    }
  }


  // MARK: - Private Properties

  @IBOutlet private var noFileLabel: NSTextField!


  // MARK: - NSView
  
  override func draw(_ dirtyRect: NSRect) {
    self.lanes
      .filter { dirtyRect.contains(CGPoint(x: $0.value, y: 1.0)) }
      .forEach { (key: Pitch, value: Double) in
        let line = NSBezierPath()
        line.move(to: NSPoint(x: value, y: 0))
        line.line(to: NSPoint(x: value, y: self.frame.size.height))
        NSColor.darkGray.setStroke()
        line.lineWidth = 2
        line.stroke()
      }

    super.draw(dirtyRect)
  }
  
}
