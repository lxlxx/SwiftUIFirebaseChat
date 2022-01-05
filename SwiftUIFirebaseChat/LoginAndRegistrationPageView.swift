//
//  ContentView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 27/11/2021.
//
// What's with Constraints in SwiftUI?
// https://stackoverflow.com/questions/56452250/whats-with-constraints-in-swiftui/56471369
// Mutable Binding in SwiftUI Live Preview
// https://stackoverflow.com/questions/59246859/mutable-binding-in-swiftui-live-preview
// How to create a segmented control and read values from it
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-segmented-control-and-read-values-from-it
// SwiftUI - How do I change the background color of a View?
// https://stackoverflow.com/questions/56437036/swiftui-how-do-i-change-the-background-color-of-a-view


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct LoginAndRegistrationPageView: View {
    
    let screenSize = UIScreen.main.bounds
    
    @State var email = ""
    @State var password = ""
    @State var comfirmPassword = ""
    @State var name = ""
    @State var show = false
    
    @State var imagePicker = false
    @State var imageData: Data = .init(count: 0)
    
    
    
    
    @State var LoginOrRegistrationStatus = "Login"
    var LoginOrRegistration = ["Login", "Registration"]
    var LoginOrRegistrationStatusInBool: Bool {
        get {
            LoginOrRegistrationStatus == "Login"
        }
    }
    
    @State private var alertToShow: IdentifiableAlert?
    
    var body: some View {
        VStack(alignment: .leading){
            
            Group {
                VStack(alignment: .center) {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Button(action: {
                            self.imagePicker.toggle()
                        }, label: {
                            if self.imageData.count == 0 {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .frame(minWidth: 60,
                                           idealWidth: 90,
                                           maxWidth: 90,
                                           minHeight: 60,
                                           idealHeight: 90,
                                           maxHeight: 90,
                                           alignment: .center)
                                    .foregroundColor(.gray)
                            } else {
                                Image(uiImage: UIImage(data: self.imageData)!)
                                    .resizable()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white,lineWidth:4).shadow(radius: 10))

                            }
                        })
                        
                        Spacer()
                    }
                    Spacer().frame(height: 16)
                }
            }
            .frame(height: LoginOrRegistrationStatusInBool ? 0 : nil)
            .opacity(LoginOrRegistrationStatusInBool ? 0 : 1)
            
            
            
            Picker ("", selection: $LoginOrRegistrationStatus) {
                ForEach(LoginOrRegistration, id: \.self) {
                    Text($0)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            Text("Enter Your Email").font(.title).fontWeight(.regular).italic()
                
            
            TextField("Email", text: $email)
                .autocapitalization(UITextAutocapitalizationType.none)

            Text("Password").font(.title).fontWeight(.regular).italic()
            
            TextField("Password", text: $password)
                .autocapitalization(UITextAutocapitalizationType.none)
            
            Group {
                VStack(alignment: .leading) {
                    Text("Comfirm Password").font(.title).fontWeight(.regular)

                    TextField("Comfirm Password", text: $comfirmPassword)
                        .autocapitalization(UITextAutocapitalizationType.none)
                    
                    Text("Name").font(.title).fontWeight(.regular)

                    TextField("Name", text: $name)
                        .autocapitalization(UITextAutocapitalizationType.none)
                    
                    Spacer().frame(height: 16)
                }
            }
            .frame(height: LoginOrRegistrationStatusInBool ? 0 : nil)
            .opacity(LoginOrRegistrationStatusInBool ? 0 : 1)
            
            Button(action:{
                if self.imageData.count == 0 {
                    let image = UIImage(systemName: "person.crop.circle.badge.plus")
                    imageData = image!.jpegData(compressionQuality: 0.45)!
                }
                handleLoginRegister()
            }){
                Text(LoginOrRegistrationStatus).frame(width: screenSize.width - 30, height: 50)
            }.foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
            
//            NavigationLink(
//                destination: secondPage(show: $show),
//                isActive: $show) {
//            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
        }
        .padding(.all)
        .alert(item: $alertToShow) { alertToShow in
            alertToShow.alert()
        }
        .sheet(isPresented: self.$imagePicker, content: {
            ImagePicker(picker: self.$imagePicker, imageData: self.$imageData)
        })
//        .background(Color.blue)
    }
    
    private func handleLoginRegister() {
        if inputDataChecking() {
            if LoginOrRegistrationStatusInBool {
                handleLogin(){ self.show.toggle() }
            } else {
                handleRegister()
            }
        }
    }
    
    private func handleLogin(completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            if err != nil {
                print(err!)
                
                let msg = (err?.localizedDescription)!
                alertToShow = IdentifiableAlert (
                    title: "Error occur",
                    message: msg
                )
                return
            }
            UserDefaults.standard.set(true, forKey: GlobalString.userStatus)
            
            UserDefaults.standard.set(name, forKey: GlobalString.userName)
            
            NotificationCenter.default.post(name: Notification.Name(GlobalString.statusChange), object: nil)
            
//            checkUser { exists, user in
//                if exists {
//
//                }
//            }
            completion()
        }
    }
    
    private func handleRegister() {
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!)
                return
            }
            handleLogin() {
                createUser(email: self.email, name: self.name, about: "", imageData: self.imageData) { status in
                    if status {
                        self.show.toggle()
                    }
                }
            }
            
        }
        
    }
    
    private func inputDataChecking() -> Bool {
        if password != comfirmPassword && !LoginOrRegistrationStatusInBool{
            alertToShow = IdentifiableAlert (
                title: "Comfirm password not equal Password ",
                message: "Please try again"
            )
        }
        
        if password == "" {
            alertToShow = IdentifiableAlert (
                title: "Password can't be empty",
                message: "Please enter password"
            )
        }
        
        if name == "" && !LoginOrRegistrationStatusInBool{
            alertToShow = IdentifiableAlert (
                title: "Name can't be empty",
                message: "Please enter name"
            )
        }
        
        if email == "" {
            alertToShow = IdentifiableAlert (
                title: "Email can't be empty",
                message: "Please enter email"
            )
        }
        
        
        if alertToShow == nil {
            return true
        } else {
            return false
        }
    }
}

func checkUser(completion: @escaping (Bool, String) -> Void) {
    let db = Firestore.firestore()
    
    db.collection("users").getDocuments { snap, err in
        if err != nil {
            print(err!.localizedDescription)
            return
        }
        
        snap!.documents.forEach { doc in
            if doc.documentID == Auth.auth().currentUser?.uid {
                completion(true, doc.get("name") as? String ?? "")
            }
        }
    }
    
    completion(false, "")
}

func createUser(email: String, name: String, about: String, imageData: Data, completion: @escaping(Bool)-> Void ) {
    
    let storage = Storage.storage().reference()
    
    let uid = Auth.auth().currentUser?.uid
    
    storage.child("profilepics").child(uid!).putData(imageData, metadata: nil) { _, error in
        if error != nil {
            print((error?.localizedDescription)!)
            return
        }
        
        storage.child("profilepics").child(uid!).downloadURL { url, err in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            let ref = Database.database().reference()
            let usersRef = ref.child("users").child(uid!)
            
            let value = ["email": email, "name": name, "about": about, "pic": "\(url!)"] as [String : Any]
            
            usersRef.updateChildValues(value, withCompletionBlock: { (updateChildValuesErr, ref) in
                
                if updateChildValuesErr != nil {
                    print(updateChildValuesErr!)
                    return
                }
                
                
            })
            
            
//            db.collection("users").document(uid!).setData(["name":name,
//                                                          "about":about,
//                                                          "pic":"\(url!)",
//                                                          "uid":uid!])
//            { (err) in
//                if err != nil {
//                    print((err?.localizedDescription)!)
//                    return
//                }
//            }
            
            completion(true)
        }
    }
}

struct secondPage: View {
    
    @Binding var show: Bool
    
    let uid = Auth.auth().currentUser?.uid
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { _ in
                VStack(alignment: .center) {
                    Spacer().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    Text("2st page").font(.largeTitle).fontWeight(.heavy).padding()
                    Text(uid ?? "").font(.largeTitle).fontWeight(.heavy).padding()
                }
                
                Button(action:{
                    self.show.toggle()
                }){
                    Image(systemName: "chevron.left").font(.title)
                }.foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                .padding()
            }
            
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    
    struct BindingHolder: View {
        @State var show = true
        var body: some View {
            LoginAndRegistrationPageView()
            LoginAndRegistrationPageView(LoginOrRegistrationStatus: "Registration")
            secondPage(show: $show)
        }
    }
    
    static var previews: some View {
        BindingHolder()
    }
}


struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
    
    init(id: String, alert: @escaping () -> Alert ) {
        self.id = id
        self.alert = alert
    }
    
    init(id: String, title: String, message: String) {
        self.id = id
        alert = { Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))}
    }
    
    init(title: String, message: String) {
        self.id = title + message
        alert = { Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))}
    }
}
