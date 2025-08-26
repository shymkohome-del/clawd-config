User Management Canister

This Motoko canister provides simple user registration and OAuth login with principal mapping.

Endpoints:
- register(email: text, password: text, username: text) -> RegisterResult
- loginWithOAuth(provider: OAuthProvider, token: text) -> LoginResult
- getUserProfile(user: principal) -> opt User

Local dev quickstart (optional):
1. Install dfx and ic-repl.
2. dfx start --background
3. dfx deploy user_management
4. Optionally run ic-repl tests with your local setup.
