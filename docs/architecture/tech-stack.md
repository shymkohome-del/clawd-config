# **Tech Stack**

This is the DEFINITIVE technology selection for the entire project. All development must use these exact versions.

## **Technology Stack Table**

| Category | Technology | Version | Purpose | Rationale |
|----------|------------|---------|---------|-----------|
| Frontend Language | Dart | 3.4+ | Mobile app development | Type-safe, compiled, excellent performance |
| Frontend Framework | Flutter | 3.22+ | Cross-platform mobile apps | Single codebase for iOS/Android, hot reload |
| UI Component Library | Material Design | Built-in | Native UI components | Consistent platform-native look and feel |
| State Management | flutter_bloc | 8.x | State management | Widely adopted, Cubit/Bloc patterns, great tooling |
| Smart Contract Language | Motoko | Latest | ICP smart contracts | Native language for ICP, strong typing |
| Smart Contract Toolkit | DFX SDK | Latest | ICP development and deployment | Official ICP development toolkit |
| Authentication | Hybrid Auth (in-canister) | Custom | Traditional + OAuth + ICP principal mapping | Lower barrier to entry while maintaining on-chain authorization |
| API Style | ICP Candid | Latest | Type-safe canister interfaces | Automatic type generation, language-agnostic |
| Database | ICP Canister Storage | Built-in | On-chain data persistence | True decentralization, built-in persistence |
| Cache | ICP Canister Memory | Built-in | In-memory caching | Fast access to frequently used data |
| File Storage | IPFS | Protocol | Large file storage | Decentralized, content-addressed storage |
| Cross-Chain | ICP Integration | Built-in | Multi-cryptocurrency support | ICP-first; expand per PRD stage gates |
| Frontend Testing | Flutter Test | Built-in | Unit and widget tests | Integrated testing framework |
| Smart Contract Testing | Motoko Test | Built-in | Canister unit tests | Native testing for Motoko |
| E2E Testing | Flutter Driver | Latest | End-to-end testing | Real device simulation |
| Build Tool | Flutter CLI | Latest | Frontend builds | Official Flutter build system |
| Build Tool | DFX | Latest | Canister builds | Official ICP build system |
| Bundler | Flutter AOT | Latest | App compilation | Ahead-of-time compilation for performance |
| IaC Tool | DFX | Latest | Canister deployment | Native ICP deployment management |
| CI/CD | GitHub Actions | Latest | Automated builds and deployment | GitHub integration, free for public repos |
| Monitoring | ICP Dashboard | Built-in | Canister performance monitoring | Native ICP monitoring tools |
| Logging | ICP Canister Logs | Built-in | On-chain logging | Immutable, transparent audit trail |
| CSS Framework | Material Theme | Built-in | App styling | Consistent Material Design 3 |
