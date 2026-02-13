import Foundation
import Security

protocol KeychainStoring {
    func copyMatching(_ query: CFDictionary, result: UnsafeMutablePointer<AnyObject?>?) -> OSStatus
    func update(_ query: CFDictionary, attributes: CFDictionary) -> OSStatus
    func add(_ query: CFDictionary) -> OSStatus
}

struct SystemKeychainStore: KeychainStoring {
    func copyMatching(_ query: CFDictionary, result: UnsafeMutablePointer<AnyObject?>?) -> OSStatus {
        SecItemCopyMatching(query, result)
    }

    func update(_ query: CFDictionary, attributes: CFDictionary) -> OSStatus {
        SecItemUpdate(query, attributes)
    }

    func add(_ query: CFDictionary) -> OSStatus {
        SecItemAdd(query, nil)
    }
}
