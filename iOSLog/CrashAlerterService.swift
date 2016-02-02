//
//  CrashAlerterService.swift
//  CrashAlerter
//
//  Created by Sven Mischkewitz on 01/02/16.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//

import Foundation

private func stateToString(state: CrashAlerterService.State) -> String {
    switch state {
    case .ACTIVE: return "ACTIVE"
    case .ALARM: return "ALARM"
    case .IDLE: return "IDLE"
    case .SUSPENDED: return "SUSPENDED"
    case .LOCAL_ALARM_WAIT: return "LOCAL_ALARM_WAIT"
    default: return "state not specified"
    }
}

class CrashAlerterService {
    static let sharedInstance = CrashAlerterService()
    
    enum Threshold: Double {
        case SPEED_THRESHOLD = 0.8 // ~ 3km/h
        case CRITICAL_SPEED = 4.3 // ~ 15km/h
        case CRITICAL_ACCELERATION = 16.677 // ~ 1.7G
    }
    
    enum State {
        case SUSPENDED
        case IDLE
        case ACTIVE
        case LOCAL_ALARM_WAIT
        case LOCAL_ALARM_FALSE_POSITIVE
        case LOCAL_ALARM_SETOFF
        case ALARM
    }
    
    enum Event {
        case STOP
        case WAKEUP
        case CRITICAL_SPEED_EXEEDANCE
        case CRITICAL_SPEED_SHORTFALL
        case SPEED_UPDATE(Double) // reporting current speed in m/s
        case ACCELERATION_UPDATE(Double) // reporting acceleration in m/s^2
        case ALARM_DETECTED
        case CONFIRM_FALSE_ALARM
        case ALARM_TIMEOUT
        case ALARM_ACKNOWLEDGE
    }
    
    var state: State = .SUSPENDED
    
    //
    // STATE MACHINE
    //
    
    func handleEvent(event: Event) {
        if let (newState, action) = transition(state, event: event) {
            NSLog("State changed %@ -> %@", stateToString(state), stateToString(newState))
            state = newState
            action?()
        }
    }
    
    func transition(state: State, event: Event) -> (State, (() -> Void)?)? {
        switch event {
        case .STOP:
            return (.SUSPENDED, { self.stopService() })
        default: break
        }
        
        switch state {
        case .SUSPENDED:
            switch event {
            case .WAKEUP: return (.IDLE, { self.startService() })
            default: return nil
            }
        case .IDLE:
            switch event {
            case .SPEED_UPDATE(let speed):
                if exceedsCriticalSpeed(speed) {
                    return (.ACTIVE, nil)
                }
                return nil
            case .CRITICAL_SPEED_EXEEDANCE: return (.ACTIVE, nil)
            default: return nil
            }
        case .ACTIVE:
            switch event {
            case .SPEED_UPDATE(let speed): return (.ACTIVE, { self.updateMovement(speed) })
            case .ACCELERATION_UPDATE(let acc): return (.ACTIVE, { self.updateMovement(acceleration: acc) })
            case .ALARM_DETECTED: return (.LOCAL_ALARM_WAIT, { self.displayLocalAlarm() })
            case .CRITICAL_SPEED_SHORTFALL: return nil
            default: return nil
            }
        default: break
        }
        
        // no state change detected
        return nil
    }
    
    //
    // ACTIONS - events to control the service from outside
    //
    
    func activate() {
        NSLog("Active CA Service")
        handleEvent(.WAKEUP)
    }
    
    func deactivate() {
        NSLog("Deactive CA Service")
        handleEvent(.STOP)
    }
    
    func updateSpeedIfNeeded(speed: Double) {
        if state == .ACTIVE || state == .IDLE {
            handleEvent(.SPEED_UPDATE(speed))
        }
    }
    
    func updateAccelerationIfNeeded(acceleration: Double) {
        if state == .ACTIVE {
            handleEvent(.ACCELERATION_UPDATE(acceleration))
        }
    }
    
    //
    // DISPATCHES - actions to be performed when internal state changed
    //
    
    func startService() {
        
    }
    
    func stopService() {
        
    }
    
    // TODO: use ring buffers
    var speed: Double = 0.0
    var acceleration: Double = 0.0
    func updateMovement(speed: Double? = nil, acceleration: Double? = nil) {
        if let s = speed {
            self.speed = s
        }
        
        if let acc = acceleration {
            self.acceleration = acc
        }
        
        checkMovement()
    }
    
    /*
    * TODO: use ringbuffers & mean -> speed, max -> acc
    * This method is only called when speed exeeds critial speed threshold.
    */
    func checkMovement() {
        NSLog("Check Movement")
        
        if speed < Threshold.CRITICAL_SPEED.rawValue - Threshold.SPEED_THRESHOLD.rawValue {
            if acceleration > Threshold.CRITICAL_ACCELERATION.rawValue {
                handleEvent(.ALARM_DETECTED)
                return
            }
            
            handleEvent(.CRITICAL_SPEED_SHORTFALL)
        }
    }
    
    func displayLocalAlarm() {
        NSLog("Local Alarm")
        deactivate()
    }
    

    //
    // HELPERS
    //
    
    func exceedsCriticalSpeed(speed: Double) -> Bool {
        return speed > Threshold.CRITICAL_SPEED.rawValue + Threshold.SPEED_THRESHOLD.rawValue
    }
}