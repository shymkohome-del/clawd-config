import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Result "mo:base/Result";

persistent actor UserManagement {
    type User = {
        id: Principal;
        email: Text;
        username: Text;
        createdAt: Int;
    };

    type RegisterResult = Result.Result<User, Text>;
    
    private transient var users = HashMap.HashMap<Principal, User>(16, Principal.equal, Principal.hash);
    
    public shared({caller}) func register(email: Text, username: Text): async RegisterResult {
        let user: User = {
            id = caller;
            email = email;
            username = username;
            createdAt = Time.now();
        };
        users.put(caller, user);
        #ok(user)
    };
    
    public query func getUser(id: Principal): async ?User {
        users.get(id)
    };
    
    public query func healthCheck(): async Bool {
        true
    };
}
