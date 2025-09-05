import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Int64 "mo:base/Int64";
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

  public shared ({ caller }) func updateUserProfile(updates : Types.UserUpdate) : async Types.Result {
    switch (users.get(caller)) {
      case (?u) {
        var updated = u;
        switch (updates.username) {
          case (?name) {
            if (!isValidUsername(name)) return #err("invalid_username");
            updated := { updated with username = name };
          };
          case null {};
        };
        switch (updates.profileImage) {
          case (?img) { updated := { updated with profileImage = ?img }; };
          case null {};
        };
        users.put(caller, updated);
        Debug.print("profile updated for " # Principal.toText(caller));
        #ok()
      };
      case null { #err("not_found") };
    }
  };

  public shared ({ caller }) func updateReputation(user : Principal, change : Int) : async Types.Result {
    if (caller != user) return #err("unauthorized");
    switch (users.get(user)) {
      case (?u) {
        let current = Int64.fromNat64(u.reputation);
        let updated = current + Int64.fromInt(change);
        if (updated < 0) return #err("invalid_change");
        let newRep = Nat64.fromInt64(updated);
        let updatedUser : Types.User = { u with reputation = newRep };
        users.put(user, updatedUser);
        Debug.print("reputation updated for " # Principal.toText(user));
        #ok()
      };
      case null { #err("not_found") };
    }
  };
}
