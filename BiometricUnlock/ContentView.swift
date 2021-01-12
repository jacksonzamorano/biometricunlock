import SwiftUI
import LocalAuthentication

struct ContentView: View {
    
    @State private var noAuth:Bool = false
    @State private var authFailed:Bool = false
    @State private var authError:Bool = false

    
    @State private var authenticated:Bool = false
    
    @State private var unlock_applewatch = true
    @State private var unlock_touchid = true
    
    
    var body: some View {
        VStack {
            if authenticated {
                AuthenticatedView()
            }
            
            Button(authenticated ? "Sign Out" : "Authenticate") {
                auth()
            }.disabled(unlock_applewatch == false && unlock_touchid == false).animation(.easeInOut)
            
            if !authenticated {
                VStack {
                    Text("Authentication Options:").fontWeight(.semibold)
                    HStack {
                        Toggle("Apple Watch", isOn: $unlock_applewatch)
                        Toggle("Touch ID", isOn: $unlock_touchid)
                    }
                }.transition(.move(edge: .bottom)).animation(.default).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            }
            WidthView()
            
            AlertView(title: "No Authentication", description: "Authentication won't work because your machine doesn't have any of the options you selected.", show: $noAuth)
            AlertView(title: "Authentication Error", description: "Something went wrong when trying to authenticate you.", show: $authError)
            AlertView(title: "Authentication Failed", description: "Authentication failed or it was canceled.", show: $authFailed)
            
        }.navigationTitle("Authenticator").padding(EdgeInsets(top: 40, leading: 30, bottom: 30, trailing: 30))
    }
    
    
    
    func auth() {
        if !authenticated {
            
            var policy:LAPolicy = .deviceOwnerAuthentication
            if unlock_touchid && unlock_applewatch {
                policy = .deviceOwnerAuthenticationWithBiometricsOrWatch
            } else if unlock_touchid {
                policy = .deviceOwnerAuthenticationWithBiometrics
            } else if unlock_applewatch {
                policy = .deviceOwnerAuthenticationWithWatch
            }
            
            let context = LAContext()
            context.localizedCancelTitle = "Cancel"
            var error:NSError?
            if context.canEvaluatePolicy(policy, error: &error) {
                context.evaluatePolicy(policy, localizedReason: "Sign in.") { (worked, error2) in
                    if error == nil {
                        if worked {
                            self.authenticated = true
                        } else {
                            self.authFailed = true
                        }
                    } else {
                        self.authError = true
                    }
                }
            } else {
                noAuth = true
            }
        } else {
            authenticated = false
        }
    }
}

struct WidthView: View {
    var body: some View {
        Rectangle().frame(width: 250, height: 1, alignment: .center).foregroundColor(Color.clear)
    }
}

struct AlertView: View {
    
    var alert_title: String
    var alert_desc: String
    
    var present: Binding<Bool>
    
    init(title: String, description: String, show: Binding<Bool>) {
        self.alert_title = title
        self.alert_desc = description
        self.present = show
    }
    
    var body: some View {
        VStack {
            
        }.alert(isPresented: present) {
            Alert(title: Text(alert_title), message: Text(alert_desc), dismissButton: .default(Text("OK")))
        }
    }
}

struct AuthenticatedView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 50))
            Text("Signed in!").fontWeight(.semibold).font(.system(size: 30))
            
        }.transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))).animation(.easeIn).padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
