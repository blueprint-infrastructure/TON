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
[LIVE NETWORK DATA]
   • Total Network Stake: 409992993 TON
   • Active Validators: 400
   • 400th Validator Stake: 694559 TON
   • Network Average Stake: 1024982 TON per validator
   • Current TON Price: $3.29

[CURRENT OPTIMAL CONFIGURATION]
   • Target Stake: 50M TON
   • Max Effective Balance: 2083677 TON per validator
   • Validators Required: 24
   • Stake Per Validator: 2083677 TON
   • Actual Stake Deployed: 50.000M TON
   • Stake Utilization: 100.0%
   • Validator Size vs Network Average: 203.2% of network average size

[FINANCIAL ANALYSIS]
   • Monthly Rewards: 170685.00000000 TON
   • Monthly Revenue: $561553.65000000
   • Monthly Operating Costs: $24000
   • Activation Period Costs: $16000.00 (20 days @ $800.00/day)
   • Net Monthly Profit: $537553.65000000
   • Monthly ROI: 2239.8%/month
   • Annual Profit: $6450643.80000000
   • Annual ROI: 26877.6%

[PROFITABILITY ASSESSMENT]
   • Break-even Stake: 2107655 TON
   • Break-even Validators: 2 validators minimum
   • Profit Margin: 95.7% (Net/Revenue)
   • Activation Period: 20 days setup (costs $16000.00)
   • Activation Cost Recovery: .8 days of operation
   • Capital Efficiency: 100.0% of available stake deployed
   • Status: HIGHLY PROFITABLE

[KEY RECOMMENDATIONS]
   • Deploy 23 validators with 2083677 TON each (max effective)
   • Deploy 1 validator with 2075429 TON (remainder)
   • Total deployment: 24 validators using 50.000M TON
   • Setup timeline: 20 days to activate (budget $16000.00)
   • Monthly hardware budget: $24000 ($1000 per validator)
   • Expected monthly profit: $537553.65000000 (after activation)
   • Total stake earning 4.15333500% APY on 50.000M TON
   • Validators will be 203.2% of network average size
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
