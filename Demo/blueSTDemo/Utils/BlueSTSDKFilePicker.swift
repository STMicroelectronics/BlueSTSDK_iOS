//
//  BlueSTSDKFilePicker.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreServices

public enum BlueSTSDKFileType: String {
    case json
    case bin
    case folder

    var fileUtType: UTType {
        switch self {
        case .json:
            return UTType.json
        case .bin:
            return UTType.data
        case .folder:
            return UTType.folder
        }
    }

    var fileTypes: [String] {
        return [String(describing: fileUtType)]
    }
}

public typealias BlueSTSDKFileCallback = (URL?) -> Void

public class BlueSTSDKFilePicker: NSObject {
    public static let shared = BlueSTSDKFilePicker()

    var completion: (BlueSTSDKFileCallback)?

    public override init() {

    }

}

extension UIViewController {
    func blueSTSDKtopPresentedViewController() -> UIViewController? {
        if let controller = presentedViewController {
            return controller.blueSTSDKtopPresentedViewController()
        }

        return self
    }
}

public extension BlueSTSDKFilePicker {
    func pickFile(with types: [BlueSTSDKFileType], completion: BlueSTSDKFileCallback?) {

        self.completion = completion

        let controller = UIDocumentPickerViewController(forOpeningContentTypes: types.map { $0.fileUtType })
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.blue], for: .normal)

        controller.allowsMultipleSelection = false
        controller.delegate = self

        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootVC = window.rootViewController?.blueSTSDKtopPresentedViewController() {
            rootVC.present(controller, animated: true, completion: nil)
        }
//        UIApplication.shared.windows.first?
//            .rootViewController?
//            .blueSTSDKtopPresentedViewController()?
//            .present(controller, animated: true, completion: nil)
    }
}

extension BlueSTSDKFilePicker: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self, let completion = self.completion else { return }
            completion(urls.first)
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self, let completion = self.completion else { return }
            completion(nil)
        }
    }
}
