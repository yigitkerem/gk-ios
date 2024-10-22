//
//  SenstivieViewModifier.swift
//  RWGK
//
//  Created by Yiğit Kerem Oktay on 22/10/2024.
//
 
import SwiftUI

struct SenstivieViewModifier: ViewModifier {

    @State private var hideView: Bool = true
    @Environment(\.scenePhase) var scenePhase

    // biometrics changes scenePhase to inactive. we need to address that when tracking changes in scenePhase
    @State private var performingBiometricsRightNow: Bool = false

    func tryToUnlock() {
        Task {
            performingBiometricsRightNow = true
            await BiometricAuth.executeIfSuccessfulAuth {
                withAnimation {
                    hideView = false
                }
            }
            // We add this delay because when we perform a biometric auth operation, the
            // state of the view changes to "not active". Even after it's completed, the view still
            // takes around 2 secs to become "active" again.
            if #available(iOS 16.0, *) {
                try? await Task.sleep(for: .seconds(2.5))
            } else {
                // Fallback on earlier versions
            }
            performingBiometricsRightNow = false

        }
    }

    func body(content: Content) -> some View {
        content
          .frame(maxWidth: .infinity, 
                  maxHeight: .infinity)
          .overlay {
              if hideView {
                  VStack {
                      Image(systemName: "lock.fill")
                          .foregroundStyle(Color.secondary)
                          .font(
                            .system(
                              size: 75, 
                              weight: .semibold
                            )
                          )
                          .padding(.bottom, 10)

                      Text("Identify yourself")
                          .font(.largeTitle)
                          .bold()

                      Text("You have to reverify your biometrics to unlock the door.")
                          .font(.callout)
                          .multilineTextAlignment(.center)
                          .foregroundStyle(.secondary)

                      Button(
                          action: {
                              tryToUnlock()
                          },
                          label: {
                              Text("Start Face ID")
                          }
                      )
                      .padding(.top)

                  }
                  .frame(maxWidth: .infinity, 
                          maxHeight: .infinity)
                  .background(.thickMaterial)
                  .ignoresSafeArea()
              }
          }
          .task(id: scenePhase) {
              if performingBiometricsRightNow { return }
              withAnimation {
                  if scenePhase == .active && hideView {
                      tryToUnlock()
                  } else {
                      hideView = true
                  }
              }
          }
          .onDisappear {
              // we want to lock the view every time its not visible
              hideView = true
          }
    }
}
