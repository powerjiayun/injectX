//
//  RootPasswordWindow.swift
//  injectX
//
//  Created by injectX on 2024/11/7.
//

import SwiftUI

struct PasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var showError = false
    
    let passwordManager = PasswordManager()
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            header
            passwordField
            buttons
        }
        .frame(width: 360)
        .background(Color(NSColor.windowBackgroundColor))
        .alert("Authentication Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The administrator password you entered is incorrect.")
        }
    }
    
    private var header: some View {
        VStack {
            Image(systemName: "lock.shield")
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Text("Administrator Access Required")
                .font(.system(size: 20, weight: .bold))
            
            Text("Please enter your administrator password to continue")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    private var passwordField: some View {
        HStack {
            Image(systemName: "key.fill")
                .foregroundColor(.secondary)
            SecureField("Administrator Password", text: $password)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var buttons: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Text("Cancel").frame(width: 80)
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button(action: handleSubmit) {
                Group {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 80, height: 16)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.open")
                            Text("Unlock")
                        }
                        .frame(width: 80)
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(password.isEmpty || isLoading)
            .opacity(password.isEmpty || isLoading ? 0.5 : 1)
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    private func handleSubmit() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onSubmit()
            _ = passwordManager.savePassword(password, forKey: "Admin")
            isLoading = false
            dismiss()
        }
    }
}
