import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginError = ""
    @State private var isLoggedIn = false
    @State private var vm = AuthenticationView()
    @Environment(\.colorScheme) var colorScheme // 다크모드 확인
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Button(action: { login() }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                // Google 로그인 버튼
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light)) {
                    vm.signInWithGoogle()
                }
                .frame(height: 50)
                .cornerRadius(10)
                .padding(.top, 20)
                .background(colorScheme == .dark ? Color.black : Color.white) // 다크모드 체크
                .foregroundColor(colorScheme == .dark ? .white : .black) // 다크모드에서 흰색 글자, 흰색 배경

                // Apple 로그인 버튼 추가
                SignInWithAppleButton(.signIn, onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                }, onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            handleAppleIDCredential(credential: appleIDCredential)
                        }
                    case .failure(let error):
                        print("Apple 로그인 실패: \(error.localizedDescription)")
                    }
                })
                .frame(height: 50)
                .cornerRadius(10)
                .padding(.top, 20)
                .background(colorScheme == .dark ? Color.black : Color.white) // 다크모드 체크
                .foregroundColor(colorScheme == .dark ? .white : .black) // 다크모드에서 흰색 글자, 흰색 배경

                if !loginError.isEmpty {
                    Text(loginError)
                        .foregroundColor(.red)
                        .padding()
                }
                
                NavigationLink(value: isLoggedIn) {
                    EmptyView()
                }
                .navigationDestination(isPresented: $isLoggedIn) {
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
    
    func handleAppleIDCredential(credential: ASAuthorizationAppleIDCredential) {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            print("Apple ID Token을 얻을 수 없습니다.")
            return
        }
        
        let nonce = randomNonceString()
        let sha256Nonce = sha256(nonce)
        let firebaseCredential = OAuthProvider.credential(providerID: .apple, idToken: tokenString, rawNonce: sha256Nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
            if let error = error {
                print("Firebase 로그인 실패: \(error.localizedDescription)")
            } else {
                print("Firebase Apple 로그인 성공")
            }
        }
    }

    func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

#Preview {
    LoginView()
}

