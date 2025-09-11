import Principal "mo:base/Principal";

module {
  public type User = {
    id : Principal;
    email : Text;
    username : Text;
    authProvider : Text;
    reputation : Nat64;
    createdAt : Nat64;
    lastLogin : ?Nat64;
    isActive : Bool;
    kycVerified : Bool;
    profileImage : ?Text;
  };

  public type RegisterResult = { #ok : User; #err : Text };

  public type OAuthProvider = { #google; #apple; #github; #facebook };

  public type LoginResult = { #ok : User; #err : Text };
}
