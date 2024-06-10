//
//  LoginView.swift
//  GoogleSignInFirebaseSwiftUI
//
//  Created by Sheehan Munim on 6/9/24.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginError = ""
    @State private var isLoggedIn = false
    @State private var vm = AuthenticationView()
    
    var body: some View {
        NavigationStack{
            VStack{
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Button(action:{login()
                }){
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light)){
                    
                    
                    vm.signInWithGoogle()
                }
                if !loginError.isEmpty{
                    Text(loginError)
                        .foregroundColor(.red)
                        .padding()
                }
                
                NavigationLink(value: isLoggedIn){
                    EmptyView()
                }
                .navigationDestination(isPresented: $isLoggedIn){
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                }
                
                
            }
            .padding()
            
            
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
        
            if let error = error {
                loginError = error.localizedDescription
            }
            
            isLoggedIn = true
        }
    }
}

#Preview {
    LoginView()
}
