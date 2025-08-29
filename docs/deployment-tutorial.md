# ICP Mainnet Deployment Tutorial

## Deploy Individual Canisters
```bash
cd /Users/vitalijsimko/workspace/projects/other/crypto_market/crypto_market

# Deploy user management canister
dfx deploy user_management --network ic

# Deploy marketplace canister  
dfx deploy marketplace --network ic

# Deploy atomic swap canister
dfx deploy atomic_swap --network ic

# Deploy price oracle canister
dfx deploy price_oracle --network ic
```

## Deploy All Canisters
```bash
# Deploy all at once
dfx deploy --network ic
```

## Verify Deployment
```bash
# Check canister status
dfx canister --network ic status user_management
dfx canister --network ic status marketplace
dfx canister --network ic status atomic_swap
dfx canister --network ic status price_oracle

# Get canister IDs for frontend configuration
dfx canister --network ic id user_management
dfx canister --network ic id marketplace
dfx canister --network ic id atomic_swap
dfx canister --network ic id price_oracle
```

## Cost Management

### Monitor Cycles Usage
```bash
# Check remaining cycles in each canister
dfx canister --network ic status user_management
dfx canister --network ic status marketplace
dfx canister --network ic status atomic_swap  
dfx canister --network ic status price_oracle
```

### Top up Canisters
```bash
# Top up a specific canister with cycles
dfx cycles top-up AMOUNT CANISTER_ID --network ic

# Example: Add 1T cycles to user_management
dfx cycles top-up 1000000000000 $(dfx canister --network ic id user_management) --network ic
```

### Set up Automatic Top-up
```bash
# Configure auto top-up when cycles drop below threshold
dfx canister --network ic update-settings user_management --freezing-threshold 2592000
```

## Production Configuration Updates

After successful deployment, update your environment configuration with production canister IDs:

### 1. Get Production Canister IDs
```bash
echo "User Management: $(dfx canister --network ic id user_management)"
echo "Marketplace: $(dfx canister --network ic id marketplace)" 
echo "Atomic Swap: $(dfx canister --network ic id atomic_swap)"
echo "Price Oracle: $(dfx canister --network ic id price_oracle)"
```

### 2. Update Environment Configuration
Update `crypto_market/lib/core/config/environment_config.dart`:

```dart
class CanisterConfig {
  static const _mainnetCanisterIds = {
    'user_management': 'YOUR_PRODUCTION_USER_MGMT_ID',
    'marketplace': 'YOUR_PRODUCTION_MARKETPLACE_ID', 
    'atomic_swap': 'YOUR_PRODUCTION_ATOMIC_SWAP_ID',
    'price_oracle': 'YOUR_PRODUCTION_PRICE_ORACLE_ID',
  };
  
  // ... rest of configuration
}
```

## Troubleshooting

### Common Issues

1. **"Insufficient cycles" error**
   ```bash
   dfx cycles convert --amount 1.0 --network ic
   ```

2. **"No wallet configured" error**
   ```bash
   dfx identity --network ic set-wallet YOUR_WALLET_ID
   ```

3. **"Authentication failed" error**
   ```bash
   dfx identity whoami
   dfx identity use production
   ```

4. **Canister creation fails**
   - Check cycles balance: `dfx cycles balance --network ic`
   - Ensure wallet has sufficient ICP: `dfx wallet --network ic balance`

### Security Best Practices

1. **Never share your Internet Identity recovery phrase**
2. **Use separate identities for different environments:**
   ```bash
   dfx identity new production
   dfx identity new development  
   dfx identity new staging
   ```

3. **Regular backup of canister state:**
   ```bash
   dfx canister --network ic call user_management backup
   ```

4. **Monitor cycles usage and set up alerts**

### Cost Optimization

1. **Batch operations when possible**
2. **Use query calls (free) vs update calls (cost cycles)**
3. **Implement proper caching in your canisters**
4. **Regular cleanup of unused data**

## Next Steps

After successful deployment:

1. ✅ Update frontend configuration with production canister IDs
2. ✅ Test all functionality against live canisters  
3. ✅ Set up monitoring and alerting
4. ✅ Configure backup and recovery procedures
5. ✅ Implement proper error handling for production edge cases

## Resource Links

- [ICP Developer Docs](https://internetcomputer.org/docs/current/developer-docs/)
- [Cycles and Storage Costs](https://internetcomputer.org/docs/current/developer-docs/gas-cost)
- [DFX CLI Reference](https://internetcomputer.org/docs/current/references/cli-reference/dfx-parent)
- [Internet Identity](https://identity.ic0.app/)
- [Network Nervous System (NNS)](https://nns.ic0.app/)

## Estimated Costs

| Operation | Cycles Cost | ICP Equivalent (approx) |
|-----------|-------------|-------------------------|
| Create canister | 100B cycles | ~0.1 ICP |
| 1GB storage/month | 127K cycles/GB | ~0.0001 ICP |
| 1M instructions | 600K cycles | ~0.0006 ICP |
| HTTP request | 400K + 1K/byte | Variable |

**Monthly estimate for your app: 1-3 ICP depending on usage**
