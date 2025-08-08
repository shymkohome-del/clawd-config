# **Deployment Architecture**

## **Deployment Strategy**

**Frontend Deployment:**
- **Platform:** App Store (iOS) + Google Play Store (Android)
- **Build Command:** `flutter build apk` and `flutter build ios`
- **Output Directory:** `build/app/outputs/flutter-apk/app-release.apk`
- **CDN/Edge:** App store distribution networks

**Backend Deployment:**
- **Platform:** Internet Computer Mainnet
- **Build Command:** `dfx deploy --network ic`
- **Deployment Method:** Direct canister deployment via DFX

**Deployment Workflow:**
```bash