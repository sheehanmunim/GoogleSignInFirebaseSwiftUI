//
//  InitialView.swift
//  GoogleSignInFirebaseSwiftUI
//
//  Created by Sheehan Munim on 6/9/24.
//

import SwiftUI
import Firebase

struct InitialView: View {
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    
    
    var body: some View {
        VStack{
            if userLoggedIn{
                ContentView()
            } else {
                LoginView()
            }
            
            
        }.onAppear{
            
            Auth.auth().addStateDidChangeListener{auth, user in
            
                if (user != nil) {
                    
                    userLoggedIn = true
                } else{
                    userLoggedIn = false
                }
            }
        }
    }
}

