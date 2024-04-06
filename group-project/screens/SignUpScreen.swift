import UIKit

// Created by David
// These Imports are used for Firebase - Firestore Database
import FirebaseFirestore

class SignUpScreen: UIViewController, UITextFieldDelegate {
    
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Created by David
    // This function is used to make the keyboard disappear when we tap the "return" key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // Created by David
    // This function is used to fetch all documents from any table
    func fetchDocuments(tableName: String) async throws -> [String: Any] {
        let collection = Firestore.firestore().collection(tableName)
        let querySnapshot = try await collection.getDocuments()
        var data = [String: Any]()
        for document in querySnapshot.documents {
            data[document.documentID] = document.data()
        }
        return data
    }

    
    
    
    /**
     Created by David
     
     Function triggered when the sign-up button is tapped.
     
     - Parameters:
        - sender: The object that triggered the action.
     
     - Returns: This function does not return any value.
     
     - Important:
        Before calling this function, ensure that the `username` and `password` outlets are properly connected to the respective text fields in the storyboard.
     
        Additionally, make sure that the Firestore database is properly configured and accessible.
     
     - Usage:
        1. Connect the `signUp` function to the tap event of the sign-up button in your storyboard.
        2. Ensure that the `username` and `password` outlets are properly connected to the respective text fields in your storyboard or code.
        3. Call this function when the user taps the sign-up button to add a new account to the Firestore database.
     */
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBAction func signUp(sender: Any) {
        // ensuring both text field are not empty
        guard let usernameText = username.text, !usernameText.isEmpty,
              let passwordText = password.text, !passwordText.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter both username and password", preferredStyle: .alert)
            let closeAlertAction = UIAlertAction(title: "Close", style: .cancel)
            alert.addAction(closeAlertAction)
            self.present(alert, animated: true)
            print("Username and password cannot be empty")
            return
        }
        
        Task {
            do {
                let documents = try await fetchDocuments(tableName: "Profiles")
                print(documents)
                
                // Check if the username already exists
                if documents.values.contains(where: { ($0 as? [String: Any])?["Username"] as? String == usernameText }) {
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Username already exists", preferredStyle: .alert)
                        let closeAlertAction = UIAlertAction(title: "Close", style: .cancel)
                        alert.addAction(closeAlertAction)
                        self.present(alert, animated: true)
                    }
                
                // start adding new account into db
                } else {
                    let collection = Firestore.firestore().collection("Profiles")
                    
                    collection.addDocument(
                        data: ["Username": usernameText,
                               "password": passwordText,
                               "AvailableCampuses": nil,
                               "HomeCampus": nil,
                               "HomeCampusCoordinates": nil]
                    ) {
                        
                        error in
                        
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            let alert = UIAlertController(title: "Successful", message: "Please log in!", preferredStyle: .alert)
                            let closeAlertAction = UIAlertAction(title: "Close", style: .cancel)
                            alert.addAction(closeAlertAction)
                            self.present(alert, animated: true)
                            print("Document added successfully!")
                        }
                    }
                }

            } catch {
                print("Error fetching documents: \(error)")
            }
        }
        
        
    }

}
