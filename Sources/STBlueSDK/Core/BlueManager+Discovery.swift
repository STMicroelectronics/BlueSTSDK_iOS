//
//  BlueManager+Discovery.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth

public extension BlueManager {
    func discoveryStart() {
        discoveryStart(-1)
    }

    func discoveryStart(_ timeout: Int, delay: Int = 0) {

        delegates.forEach { delegate in
            notificationQueue.async { [weak self] in
                guard let self = self else { return }
                guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
                weakDelegate.manager(self, didRemoveDiscovered: self.discoveredNodes)
            }
        }

        nodeServices.removeAll { !$0.node.isConnected }
        discoveryStart(timeout, delay: delay, advertiseFilters: BlueManager.defaultAdvertiseFilter)
    }

    /**
     *  Start a discovery process that will scan for a new node. The discovery will
     * stop after {@code timeoutMs} milliseconds
     *
     *  @param timeoutMs milliseconds to wait before stop the scanning
     */
    func discoveryStart(_ timeout: Int, delay: Int = 0, advertiseFilters: [AdvertiseFilter]) {

        guard centralManager.state == .poweredOn && isDiscovering == false else {
            notificationQueue.asyncAfter(deadline: .now() + BlueManager.retryStartScanningDelay) {
                self.discoveryStart(timeout, delay: delay, advertiseFilters: advertiseFilters)
            }
            return
        }

        if let delayWorkItem = delayWorkItem {
            delayWorkItem.cancel()
        }

        if delay > 0 {
            let delaySeconds = TimeInterval(delay) / 1000.0

            delayWorkItem = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.discoveryStart(timeout, advertiseFilters: advertiseFilters)
            }

            if let delayWorkItem = delayWorkItem,
               delaySeconds > 0 {
                self.notificationQueue.asyncAfter(deadline: .now() + delaySeconds,
                                                  execute: delayWorkItem)
            }

        } else {
            self.discoveryStart(timeout, advertiseFilters: advertiseFilters)
        }
    }

    func discoveryStop() {

        defer {
            delegates.forEach { delegate in
                notificationQueue.async { [weak self] in
                    guard let self = self else { return }
                    guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
                    weakDelegate.manager(self, discoveringStatus: self.isDiscovering)
                }
            }
        }

        guard centralManager.state == .poweredOn else { return }
        guard isDiscovering == true else { return }

        centralManager.stopScan()
        timeoutWorkItem?.cancel()
        delayWorkItem?.cancel()
        isDiscovering = false
    }

    func resetDiscovery() {
        resetDiscovery(true)
    }

    func resetDiscovery(_ disconnectAll: Bool) {
        if disconnectAll {
            discoveredNodes.forEach { node in
                if node.isConnected {
                    // TODO: DISCONNECT PERIPHERAL
                }
            }
        }
        //remove all disconnected node
//        nodeServices.removeAll { !$0.node.isConnected }
        nodeServices.removeAll()
    }
}

private extension BlueManager {
    func discoveryStart(_ timeout: Int, advertiseFilters: [AdvertiseFilter]) {

        let scanOptions: [String: Any] = [ CBCentralManagerScanOptionAllowDuplicatesKey: true ]
        self.advertiseFilters = advertiseFilters
        centralManager.scanForPeripherals(withServices: nil, options: scanOptions)
        isDiscovering = true

        delegates.forEach { delegate in
            notificationQueue.async { [weak self] in
                guard let self = self else { return }
                guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
                weakDelegate.manager(self, discoveringStatus: self.isDiscovering)
            }
        }

        if let timeoutWorkItem = timeoutWorkItem {
            timeoutWorkItem.cancel()
        }

        let timeoutSeconds = TimeInterval(timeout) / 1000.0

        timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.discoveryStop()
        }

        if let timeoutWorkItem = timeoutWorkItem,
           timeoutSeconds > 0 {
            self.notificationQueue.asyncAfter(deadline: .now() + timeoutSeconds,
                                              execute: timeoutWorkItem)
        }
    }
}
