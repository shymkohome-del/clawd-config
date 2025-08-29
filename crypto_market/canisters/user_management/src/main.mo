import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Types "./types";

actor UserManagement {
  stable var usersEntries : [(Principal, Types.User)] = [];
  stable var emailToPrincipalEntries : [(Text, Principal)] = [];

  let users = HashMap.HashMap<Principal, Types.User>(16, Principal.equal, Principal.hash);
  let emailToPrincipal = HashMap.HashMap<Text, Principal>(16, Text.equal, Text.hash);

  system func preupgrade() {
    usersEntries := Iter.toArray(users.entries());
    emailToPrincipalEntries := Iter.toArray(emailToPrincipal.entries());
  };

  system func postupgrade() {
    users.clear();
    for ((p, u) in usersEntries.vals()) { users.put(p, u); };
    emailToPrincipal.clear();
    for ((e, p) in emailToPrincipalEntries.vals()) { emailToPrincipal.put(e, p); };
    usersEntries := [];
    emailToPrincipalEntries := [];
  };

  private func nowMillis() : Nat64 {
    let nanos = Time.now();
    // convert to millis
    Nat64.fromNat(Nat.div(nanos, 1_000_000));
  };

  private func isValidEmail(email : Text) : Bool {
    // Minimal sanity check: one '@' and a dot after it
    switch (Text.split(email, #char '@')) {
      case (iter) {
        let parts = Iter.toArray(iter);
        if (parts.size() != 2) return false;
        let domain = parts[1];
        return Text.contains(domain, #char '.');
      };
    }
  };

  private func isValidUsername(name : Text) : Bool {
    let len = Text.size(name);
    len >= 3 and len <= 32;
  };

  public shared ({ caller }) func register(email : Text, password : Text, username : Text) : async Types.RegisterResult {
    // Basic input validation
    if (not isValidEmail(email)) return #err("invalid_email");
    if (Text.size(password) < 8) return #err("weak_password");
    if (not isValidUsername(username)) return #err("invalid_username");

    // Enforce 1 account per email
    switch (emailToPrincipal.get(email)) {
      case (?existing) {
        return #err("email_in_use");
      };
      case null {};
    };

    let p = caller;
    // Map principal to user; prevent duplicate for same principal
    switch (users.get(p)) {
      case (?_) { return #err("principal_exists"); };
      case null {};
    };

    let user : Types.User = {
      id = p;
      email = email;
      username = username;
      authProvider = "email";
      reputation = 0;
      createdAt = nowMillis();
      lastLogin = null;
      isActive = true;
      kycVerified = false;
      profileImage = null;
    };
    users.put(p, user);
    emailToPrincipal.put(email, p);
    #ok(user)
  };

  public shared ({ caller }) func loginWithOAuth(provider : Types.OAuthProvider, token : Text) : async Types.LoginResult {
    // Token non-empty check
    if (Text.size(token) < 8) return #err("invalid_token");

    let providerName : Text = switch (provider) {
      case (#google) "google";
      case (#apple) "apple";
      case (#github) "github";
      case (#facebook) "facebook";
    };

    let p = caller;
    switch (users.get(p)) {
      case (?u) {
        // update lastLogin
        let updated : Types.User = {
          id = u.id;
          email = u.email;
          username = u.username;
          authProvider = providerName;
          reputation = u.reputation;
          createdAt = u.createdAt;
          lastLogin = ?nowMillis();
          isActive = u.isActive;
          kycVerified = u.kycVerified;
          profileImage = u.profileImage;
        };
        users.put(p, updated);
        return #ok(updated);
      };
      case null {
        // Create a lightweight user without email if new social login
        let user : Types.User = {
          id = p;
          email = ""; // unknown until linked
          username = "user_" # Text.fromNat(Nat64.toNat(nowMillis()));
          authProvider = providerName;
          reputation = 0;
          createdAt = nowMillis();
          lastLogin = ?nowMillis();
          isActive = true;
          kycVerified = false;
          profileImage = null;
        };
        users.put(p, user);
        return #ok(user);
      };
    }
  };

  public query func getUserProfile(user : Principal) : async ?Types.User {
    users.get(user)
  };
}
