//
//  ContentView.swift
//  playground-for-apple
//
//  Created by Damodar Lohani on 26/09/2021.
//

import SwiftUI
import Appwrite
import CodeScanner

struct PlaygroundView: View {
    @ObservedObject var viewModel: PlaygroundViewModel
    
    @State private var isPresentingScanner = false
    @State private var scannedCode: String?
    @State private var imageToUpload = UIImage()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Group {
                        if (viewModel.isSignedIn){
                            Button("Sign out") {
                                Task {
                                    try await viewModel.deleteSession()
                                }
                            }
                            .padding()
                            .frame(width: 250)
                            .background(.red)
                            Button("Scan QR") {
                                    isPresentingScanner = true
                            }
                            .padding()
                            .frame(width: 250)
                            .background(.blue)
                        } else {
                            Button("Login with MSFT") {
                                Task {
                                    try await viewModel.socialLogin(provider: "microsoft")
                                }
                            }
                            .padding()
                            .frame(width: 250)
                            .background(.yellow)
                        }
                    }
                    
                }
                .foregroundColor(.white)
                .alert(isPresented: $viewModel.isShowingDialog) {
                    Alert(
                        title: Text("Alert"),
                        message: Text(viewModel.dialogText),
                        dismissButton: .cancel {
                            viewModel.isShowingDialog = false
                        }
                    )
                }
                .sheet(isPresented: $isPresentingScanner) {
                            CodeScannerView(codeTypes: [.qr]) { response in
                                if case let .success(result) = response {
                                    scannedCode = result.string
                                    Task {
                                        try await viewModel.createDoc(code: scannedCode!)
                                    }
                                    isPresentingScanner = false
                                }
                            }.modifier(SenstivieViewModifier())
                        }
            }
            .navigationTitle("Gatekeeper")
            .registerOAuthHandler()
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView(viewModel: PlaygroundViewModel())
    }
}
