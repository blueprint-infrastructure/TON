# TON Validator Rewards Calculator

A comprehensive bash script for calculating TON blockchain validator rewards and profitability using live network data.

## Overview

The TON Validator Rewards Calculator is a real-time analysis tool that helps potential validators make informed decisions about staking on the TON blockchain. It fetches live network data, calculates optimal validator configurations, and provides detailed financial projections for validator operations.

## Key Features

### Live Network Data Integration
- **Real-time TON price** from CoinGecko API
- **Current validator statistics** from TON network APIs
- **Live blockchain metrics** including total stake, validator count, and minimum stakes
- **Dynamic configuration** based on current network conditions

### Comprehensive Analysis
- **Optimal validator setup** calculations for maximum stake utilization
- **Financial projections** including revenue, costs, and profitability
- **Break-even analysis** and ROI calculations
- **Activation cost modeling** with realistic timeline estimates

### Smart Stake Allocation
- **Max effective balance** calculations using TON's 3x factor rule
- **100% stake utilization** strategy for optimal capital efficiency
- **Multi-validator deployment** planning with remainder optimization
- **Competitive positioning** analysis against network averages

## Configuration Parameters

### User-Configurable Values

```bash
# Primary configuration (edit these values)
TOTAL_STAKE_TO_DEPLOY=50000000     # Total TON to stake (50M TON)
MONTHLY_COST_PER_VALIDATOR=1000    # Monthly operating cost per validator (USD)
VALIDATOR_ACTIVATION_DAYS=20       # Days from setup to earning rewards
```

### Network Constants (Verified from Official Sources)

The script uses documented TON network parameters with source verification:

- **Max Factor Multiplier**: 3x (from TON documentation)
- **Minimum Stake Requirement**: 300,000 TON
- **Validation Cycle**: 18 hours (~65,536 seconds)
- **Block Production Time**: 5 seconds (documented)
- **Block Rewards**: 1.7 TON (masterchain), 1.0 TON (basechain)

## Data Sources

### Live APIs
- **CoinGecko**: Real-time TON price data
- **TON Network**: Current validator statistics and network metrics
- **TON Center**: Masterchain information and blockchain data

### Documentation Sources
- [TON Staking Incentives](https://docs.ton.org/v3/documentation/infra/nodes/validation/staking-incentives)
- [TON Smart Contract Limits](https://docs.ton.org/v3/documentation/smart-contracts/limits)
- [TON Infrastructure Docs](https://docs.ton.org/v3/documentation/infra/nodes/validation/)

## Usage

### Prerequisites
- `curl` for API requests
- `jq` for JSON processing
- `bc` for calculations
- Internet connection for live data

### Running the Calculator

```bash
chmod +x ton-rewards-calculator.sh
./ton-rewards-calculator.sh
```

### Example Output

```
=== TON Validator Rewards Calculator (Live Chain Data) ===
Fetching current network data...
CONFIG: Planning to stake 50M TON
CONFIG: Monthly cost per validator: $1000
CONFIG: Validator activation period: 20 days

0. Getting current TON price from CoinGecko...
   API: https://api.coingecko.com/api/v3/simple/price?ids=the-open-network&vs_currencies=usd
   Current TON Price: $3.23 (live from CoinGecko)

1. Getting current validator data...
   API: https://tonapi.io/v2/blockchain/validators
   Total Network Stake: 395470026 TON (live)
   Active Validators: 400 (live)
   Min Stake: 300000 TON (live)

2. Finding lowest elected validator (400th position)...
   Source: Live TON network data from https://tonapi.io/v2/blockchain/validators
   Lowest Elected Validator Stake: 630140 TON (live)
   This is the 400th validator (minimum effective balance)
   Applying max_factor rule from TON docs...
   Source: https://docs.ton.org/v3/documentation/infra/nodes/validation/staking-incentives
   Rule: 'The current max_factor in config is 3'
   Max Effective Balance: 1890420 TON (3x min effective)
   Max Effective Balance (nanoTON): 1890420261314169
   ACTUAL DEPLOYMENT:
   → 26 validators @ 1890420 TON each = 49150920 TON
   → 1 validator @ 849080 TON
   → TOTAL: 27 validators deploying 50000000 TON (100%)

=== DYNAMIC VALIDATOR PROVISIONING (100% live) ===
Min Effective Balance (400th validator): 630140 TON (live)
Max Effective Balance (3x factor): 1890420 TON (calculated)
Target Total Stake: 50.0M TON (config)
Optimal Stake Per Validator: 1890420 TON (using exact max effective)
Validators Needed: 27 (calculated for 100% deployment)
Actual Total Deployed: 50.000M TON (calculated)
Stake Utilization: 100.0% (maximized deployment)
Current network average: 988675 TON per validator (live)

3. Getting masterchain information...
   API: https://toncenter.com/api/v2/getMasterchainInfo
   Current Masterchain Seqno: 48759276 (live)

4. Calculating LIVE on-chain staking rewards...
   Using documented block rewards from TON network constants...
   Source: https://docs.ton.org/v3/documentation/smart-contracts/limits
   ✓ Masterchain block reward: 1.7 TON (documented official)
   ✓ Basechain block reward: 1.0 TON (documented official)
   Using documented block production rate from TON network...
   Source: https://docs.ton.org/v3/documentation/smart-contracts/limits
   ✓ Documented block production: 5.0 seconds per block
   ✓ Calculated daily blocks: 17280
   Calculated daily network rewards: 46656 TON
   Daily reward rate: .01179700%/day
   Annual reward rate: 4.30590500%
   Source: Documented block fees + documented block time

=== SETUP CALCULATIONS ===
ACTUAL Configuration:
   • 26 validators with 1890420 TON each
   • 1 validator with 849080 TON
   • Total: 27 validators

Monthly Rewards: 176955.00000000 TON (after activation)
Monthly Revenue: $571564.65000000 (@$3.23/TON)
Monthly Costs: $27000
Activation Period Costs: $18000.00 (20 days @ $900.00/day)
Net Profit (ongoing): $544564.65000000/month
ROI (ongoing): 2016.9%/month

════════════════════════════════════════════════════════════════════════════════
                              FINAL RESULTS SUMMARY
════════════════════════════════════════════════════════════════════════════════

[LIVE NETWORK DATA]
   • Total Network Stake: 395470026 TON
   • Active Validators: 400
   • 400th Validator Stake: 630140 TON
   • Network Average Stake: 988675 TON per validator
   • Current TON Price: $3.23

[CURRENT OPTIMAL CONFIGURATION]
   • Target Stake: 50M TON
   • Max Effective Balance: 1890420 TON per validator
   • Validators Required: 27
   • Stake Per Validator: 1890420 TON
   • Actual Stake Deployed: 50.000M TON
   • Stake Utilization: 100.0%
   • Validator Size vs Network Average: 191.2% of network average size

[FINANCIAL ANALYSIS - TOTAL OPERATION]
   • Monthly Rewards: 176955.00000000 TON
   • Monthly Revenue: $571564.65000000
   • Monthly Operating Costs: $27000
   • Activation Period Costs: $18000.00 (20 days @ $900.00/day)
   • Net Monthly Profit: $544564.65000000
   • Monthly ROI: 2016.9%/month
   • Annual Profit: $6534775.80000000
   • Annual ROI: 24202.8%

[FINANCIAL ANALYSIS - PER SINGLE VALIDATOR]
   • Monthly Rewards per Validator: 6553.888 TON
   • Monthly Revenue per Validator: $21169.06
   • Monthly Cost per Validator: $1000
   • Activation Cost per Validator: $666.66 (20 days)
   • Net Monthly Profit per Validator: $20169.06
   • Monthly ROI per Validator: 2016.9%/month
   • Annual Profit per Validator: $242028.72
   • Annual ROI per Validator: 24202.8%

[PROFITABILITY ASSESSMENT]
   • Break-even Stake: 2329582 TON
   • Break-even Validators: 2 validators minimum
   • Profit Margin: 95.2% (Net/Revenue)
   • Activation Period: 20 days setup (costs $18000.00)
   • Activation Cost Recovery: .9 days of operation
   • Capital Efficiency: 100.0% of available stake deployed
   • Status: HIGHLY PROFITABLE

[KEY RECOMMENDATIONS]
   • Deploy 26 validators with 1890420 TON each (max effective)
   • Deploy 1 validator with 849080 TON (remainder)
   • Total deployment: 27 validators using 50.000M TON
   • Setup timeline: 20 days to activate (budget $18000.00)
   • Monthly hardware budget: $27000 ($1000 per validator)
   • Expected monthly profit: $544564.65000000 total ($20169.06 per validator)
   • Each validator earns 4.30590500% APY with 2016.9%/month ROI
   • Total stake earning 4.30590500% APY on 50.000M TON
   • Validators will be 191.2% of network average size
   • Individual validator payback: .9 days to recover activation costs

════════════════════════════════════════════════════════════════════════════════
```

## Output Sections

### 1. Configuration Summary
- Displays user-configured parameters
- Shows current TON price and market conditions

### 2. Live Network Data
- Current total network stake
- Number of active validators
- Minimum and average validator stakes

### 3. Optimal Configuration Analysis
- Max effective balance calculations
- Validator count optimization
- Stake utilization strategy

### 4. Financial Projections
- Monthly rewards in TON and USD
- Operating costs and profit margins
- Activation period cost modeling
- ROI and break-even analysis

### 5. Strategic Recommendations
- Optimal validator deployment strategy
- Timeline and budget requirements
- Competitive positioning insights
- Profitability assessment

## Key Calculations

### Max Effective Balance
```
Max Effective = Min Effective × 3 (TON's max_factor rule)
```

### Optimal Validator Count
```
Validators = floor(Total Stake ÷ Max Effective) + remainder validator
```

### Monthly Rewards
```
Monthly Rewards = Deployed Stake × Daily Rate × 30 days
```

### Profitability
```
Net Profit = (Rewards × TON Price) - Operating Costs
ROI = Net Profit ÷ Operating Costs × 100%
```

## Important Considerations

### Risk Factors
- **Market volatility**: TON price fluctuations affect revenue
- **Network changes**: Validator requirements may change
- **Competition**: Election success not guaranteed
- **Technical risks**: Hardware failures and slashing conditions

### Activation Timeline
The default 20-day activation period includes:
- Hardware setup and configuration: 2-3 days
- Software setup and testing: 2-3 days
- Election competition: 5-15 days (multiple 18-hour cycles)
- First validation period: 1-2 days

### Optimization Tips
- **Monitor network conditions** regularly for stake adjustments
- **Scale gradually** to minimize activation costs
- **Maintain competitive stakes** for consistent election success
- **Budget for activation period** without rewards

## Technical Details

### Script Architecture
- Modular design with clear separation of concerns
- Error handling for API failures
- Precise nanoTON calculations for accuracy
- Comprehensive logging and verification

### Data Validation
- API response verification
- Cross-reference with multiple sources
- Real-time network state validation
- Historical accuracy checks

## Support and Maintenance

### Regular Updates Needed
- Monitor TON network parameter changes
- Update API endpoints if they change
- Verify calculation accuracy against actual rewards
- Adjust activation timeline based on experience

### Troubleshooting
- Ensure stable internet connection for API calls
- Verify `jq` and `bc` are installed
- Check API endpoints are accessible
- Validate JSON response formats

## License

This tool is provided for educational and planning purposes. Always verify calculations independently and consult with financial advisors before making significant investment decisions.

---

**Disclaimer**: Cryptocurrency staking involves significant risks. This calculator provides estimates based on current network conditions, which may change. Past performance does not guarantee future results.
