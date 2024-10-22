//
//  BiometricAuth.swift
//  RWGK
//
//  Created by Yiğit Kerem Oktay on 22/10/2024.
//


import LocalAuthentication

public class BiometricAuth {
    static public func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        // Check whether authentication is possible
        if context.canEvaluatePolicy(
          .deviceOwnerAuthentication, error: &error
        ) {
            do {
                // Return the result of the authentication
                return try await context
                  .evaluatePolicy(
                    .deviceOwnerAuthentication, 
                    localizedReason: "Authentication Required."
                  )
            } catch {
		        // Handle your error here
                print("Unhandled biometric auth err: \(error.localizedDescription ?? "Unknown")")
                return false
            }
        } else {
            // No Password or Biometrics to auth -> return true
            return true
        }
    }
    
    // in BiometricAuth {}
    static public func executeIfSuccessfulAuth(
      _ onSuccessClosure: () -> Void,
      otherwise onFailedClosure: (() -> Void)? = nil
    ) async {
      guard await authenticate() else {
          if let onFailedClosure {
              onFailedClosure()
          }
          return
      }
      onSuccessClosure()
    }

}
