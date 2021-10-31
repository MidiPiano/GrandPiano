//
//  AppDelegate.swift
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

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  // MARK: - Class Properties

  static var shared: AppDelegate {
    return NSApplication.shared.delegate! as! AppDelegate
  }


  // MARK: - Properties

  var window: NSWindow? {
    return NSApplication.shared.keyWindow
  }


  // MARK: - NSApplicationDelegate
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

