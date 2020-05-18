//
//  KeyState.swift
//  ibepo
//
//  Created by Steve Gigou on 2020-05-07.
//  Copyright © 2020 Novesoft. All rights reserved.
//

// MARK: - KeyState

/// Represents the keyboard state at any moment.
final class KeyState {
  
  weak var delegate: KeyboardActionProtocol?
  
  /// Currently displayed key set.
  private var keySet: KeySet!
  /// Gesture recognizer for keys
  private var gestureRecognizer: KeyGestureRecognizer!
  /// Current state of the shift key
  private var shiftKeyState: Key.State = .off
  /// Current state of the alt key
  private var altKeyState: Key.State = .off
  
  
  // MARK: Configuration
  
  func configure(keySet: KeySet, view: KeypadView) {
    self.keySet = keySet
    gestureRecognizer = KeyGestureRecognizer(delegate: self)
    view.addGestureRecognizer(gestureRecognizer)
  }
  
  
  // MARK: Modifiers
  
  /**
   Operations to perform after a letter was tapped.
   */
  private func letterWasTapped() {
    if shiftKeyState == .on {
      tapShift()
    }
    if altKeyState == .on {
      tapAlt()
    }
  }
  
  private func tapShift() {
    shiftKeyState.toggle()
    Logger.debug("Shift key is now \(shiftKeyState).")
    delegate?.shiftStateChanged(newState: shiftKeyState)
  }
  
  private func tapAlt() {
    altKeyState.toggle()
    Logger.debug("Alt key is now \(altKeyState).")
    delegate?.altStateChanged(newState: altKeyState)
  }
  
  
  // MARK: Delegate communication
  
  private func tapLetter(at keyCoordinate: KeyCoordinate) {
    let key = keySet.key(at: keyCoordinate)
    delegate?.insert(text: key.set.letter(forShiftState: shiftKeyState, andAltState: altKeyState))
    letterWasTapped()
  }
  
  private func tapReturn() {
    delegate?.insert(text: "\n")
  }
  
  private func tapSpace() {
    delegate?.insert(text: " ")
  }
  
  private func tapDelete() {
    delegate?.deleteBackward()
  }
  
}


// MARK: - KeyGestureRecognizerDelegate

extension KeyState: KeyGestureRecognizerDelegate {
  
  func touchUp(at keypadCoordinate: KeypadCoordinate) {
    switch keypadCoordinate.row {
    case 0, 1: // First two rows only contain letters.
      let keyCoordinate = KeyCoordinate(row: keypadCoordinate.row, col: keypadCoordinate.col / 2)
      tapLetter(at: keyCoordinate)
    case 2: // Shift, letters and Delete keys.
      switch keypadCoordinate.col {
      case 0...2: // Shift
        tapShift()
      case 19...21: // Delete
        tapDelete()
      default: // Letter keys
        let keyCoordinate = KeyCoordinate(row: keypadCoordinate.row, col: (keypadCoordinate.col - 3) / 2)
        tapLetter(at: keyCoordinate)
      }
    case 3:
      switch keypadCoordinate.col {
      case 0...5:
        if KeyboardSettings.shared.needsInputModeSwitchKey {
          if keypadCoordinate.col <= 2 {
            tapAlt()
          } else {
            delegate?.nextKeyboard()
          }
        } else {
          tapAlt()
        }
      case 6...15:
        tapSpace()
      case 16...22:
        tapReturn()
      default:
        Logger.error("Unknown keypadCoordinate col: \(keypadCoordinate)")
      }
    default:
      Logger.error("Unknown keypadCoordinate row: \(keypadCoordinate)")
    }
  }
  
}