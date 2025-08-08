# **Unified Project Structure**

## **Monorepo Structure**

```
crypto_marketplace/
├── apps/                       # Application packages
│   ├── mobile/                 # Flutter mobile app
│   │   ├── lib/
│   │   ├── assets/
│   │   ├── android/
│   │   ├── ios/
│   │   └── pubspec.yaml
│   └── web/                    # Optional web dashboard
│       ├── src/
│       ├── public/
│       └── package.json
├── canisters/                  # ICP canisters
│   ├── marketplace/
│   │   ├── src/
│   │   ├── test/
│   │   └── dfx.json
│   ├── user_management/
│   │   ├── src/
│   │   ├── test/
│   │   └── dfx.json
│   ├── atomic_swap/
│   │   ├── src/
│   │   ├── test/
│   │   └── dfx.json
│   ├── price_oracle/
│   │   ├── src/
│   │   ├── test/
│   │   └── dfx.json
│   └── messaging/
│       ├── src/
│       ├── test/
│       └── dfx.json
├── packages/                   # Shared packages
│   ├── shared/                 # Shared types and utilities
│   │   ├── src/
│   │   │   ├── types/          # TypeScript interfaces
│   │   │   ├── constants/      # Shared constants
│   │   │   └── utils/          # Shared utilities
│   │   └── package.json
│   ├── ui/                     # Shared UI components
│   │   ├── src/
│   │   └── package.json
│   └── config/                 # Shared configuration
│       ├── eslint/
│       ├── typescript/
│       └── jest/
├── infrastructure/             # IaC definitions
│   └── dfx.json               # DFX configuration
├── scripts/                    # Build and deployment scripts
│   ├── build.sh
│   ├── deploy.sh
│   └── test.sh
├── docs/                       # Documentation
│   ├── prd.md
│   ├── project_brief.md
│   └── architecture.md
├── .env.example                # Environment template
├── package.json                # Root package.json
├── nx.json                     # Nx workspace configuration
├── dfx.json                    # DFX configuration
└── README.md
```
