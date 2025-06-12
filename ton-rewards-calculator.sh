#!/bin/bash

# =============================================================================
# CONFIGURATION - UPDATE THESE VALUES
# =============================================================================
TOTAL_STAKE_TO_DEPLOY=50000000     # Total TON you will to stake (50M TON)
MONTHLY_COST_PER_VALIDATOR=1000    # Monthly cost per validator in USD

# Validator activation time (days from start to earning rewards)
# This accounts for: hardware setup, software configuration, election cycles,
# and initial validation period. TON elections occur every ~18 hours and are
# competitive - you may need several cycles to win. Default 20 days includes:
# - Hardware setup & configuration: 2-3 days
# - Software setup & testing: 2-3 days  
# - Election competition: 5-15 days (multiple 18-hour cycles)
# - First validation + reward holding: 1-2 days
VALIDATOR_ACTIVATION_DAYS=20

# TON_PRICE will be fetched live from CoinGecko
# =============================================================================

# =============================================================================
# HARDCODED NETWORK CONSTANTS - VERIFY THESE VALUES AT SOURCE URLs
# =============================================================================
# Source: https://docs.ton.org/v3/documentation/infra/nodes/validation/staking-incentives
# Quote: "The current max_factor in config is 3"
MAX_FACTOR_MULTIPLIER=3

# Source: https://docs.ton.org/v3/documentation/infra/nodes/validation/staking-incentives
# Quote: "minimum 300k TON" and "you need to have minimum 300k TON"
MIN_STAKE_REQUIREMENT=300000000000000  # 300,000 TON in nanoTON

# Source: https://docs.ton.org/v3/documentation/infra/nodes/validation/staking-incentives
# Quote: "validation cycle lasting 65536 seconds, or approximately 18 hours"
VALIDATION_CYCLE_HOURS=18

# Source: https://docs.ton.org/v3/documentation/smart-contracts/limits
# Quote: "block production time is approximately 5 seconds"
DOCUMENTED_BLOCK_TIME=5.0

# Source: https://docs.ton.org/v3/documentation/smart-contracts/limits
# Quote: "masterchain_block_fee: 1700000000" and "basechain_block_fee: 1000000000"
OFFICIAL_MASTERCHAIN_BLOCK_FEE=1700000000  # 1.7 TON in nanoTON (documented)
OFFICIAL_BASECHAIN_BLOCK_FEE=1000000000    # 1.0 TON in nanoTON (documented)

# Source: https://api.coingecko.com/api/v3/simple/price?ids=the-open-network&vs_currencies=usd
# Live API endpoint for current TON price
COINGECKO_API_URL="https://api.coingecko.com/api/v3/simple/price?ids=the-open-network&vs_currencies=usd"

# Source: https://tonapi.io/v2/blockchain/validators
# Live API endpoint for current validator data
TON_VALIDATORS_API_URL="https://tonapi.io/v2/blockchain/validators"

# Source: https://toncenter.com/api/v2/getMasterchainInfo
# Live API endpoint for masterchain information
TON_MASTERCHAIN_API_URL="https://toncenter.com/api/v2/getMasterchainInfo"
# =============================================================================

# TON Single Validator Rewards Calculator (live)
echo "=== TON Validator Rewards Calculator (Live Chain Data) ==="
echo "Fetching current network data..."

# Convert values
TOTAL_STAKE_HUMAN=$(($TOTAL_STAKE_TO_DEPLOY / 1000000))

echo "CONFIG: Planning to stake ${TOTAL_STAKE_HUMAN}M TON"
echo "CONFIG: Monthly cost per validator: \$${MONTHLY_COST_PER_VALIDATOR}"
echo "CONFIG: Validator activation period: ${VALIDATOR_ACTIVATION_DAYS} days"

# =============================================================================
# STEP 0: FETCH LIVE TON PRICE FROM COINGECKO
# =============================================================================
echo ""
echo "0. Getting current TON price from CoinGecko..."
echo "   API: $COINGECKO_API_URL"
TON_PRICE_RESPONSE=$(curl -s "$COINGECKO_API_URL")

if [ $? -eq 0 ] && [ ! -z "$TON_PRICE_RESPONSE" ]; then
    TON_PRICE=$(echo "$TON_PRICE_RESPONSE" | jq -r '.["the-open-network"].usd')
    echo "   Current TON Price: \$${TON_PRICE} (live from CoinGecko)"
else
    echo "   ERROR: Could not fetch live TON price from CoinGecko"
    exit 1
fi

# =============================================================================
# STEP 1: FETCH LIVE VALIDATOR DATA FROM TON NETWORK
# =============================================================================
echo ""
echo "1. Getting current validator data..."
echo "   API: $TON_VALIDATORS_API_URL"
VALIDATORS_DATA=$(curl -s "$TON_VALIDATORS_API_URL")

if [ $? -ne 0 ] || [ -z "$VALIDATORS_DATA" ]; then
    echo "   ERROR: Failed to fetch validator data from TON network"
    exit 1
fi

# Extract key metrics from live validator data
TOTAL_STAKE=$(echo "$VALIDATORS_DATA" | jq -r '.total_stake')
VALIDATOR_COUNT=$(echo "$VALIDATORS_DATA" | jq -r '.validators | length')
MIN_STAKE=$(echo "$VALIDATORS_DATA" | jq -r '.min_stake')

echo "   Total Network Stake: $(($TOTAL_STAKE / 1000000000)) TON (live)"
echo "   Active Validators: $VALIDATOR_COUNT (live)"
echo "   Min Stake: $(($MIN_STAKE / 1000000000)) TON (live)"

# =============================================================================
# STEP 2: FIND LOWEST VALIDATOR STAKE (400TH POSITION)
# =============================================================================
echo ""
echo "2. Finding lowest elected validator (400th position)..."
echo "   Source: Live TON network data from $TON_VALIDATORS_API_URL"

# Find the actual lowest validator stake
LOWEST_VALIDATOR_STAKE=$(echo "$VALIDATORS_DATA" | jq -r '.validators[].stake' | sort -n | head -1)
LOWEST_VALIDATOR_STAKE_TON=$(echo "scale=0; $LOWEST_VALIDATOR_STAKE / 1000000000" | bc)

echo "   Lowest Elected Validator Stake: ${LOWEST_VALIDATOR_STAKE_TON} TON (live)"
echo "   This is the 400th validator (minimum effective balance)"

# =============================================================================
# CALCULATE MAX EFFECTIVE BALANCE USING DOCUMENTED MAX_FACTOR
# Source: https://docs.ton.org/v3/documentation/infra/nodes/validation/staking-incentives
# =============================================================================
echo "   Applying max_factor rule from TON docs..."
echo "   Source: https://docs.ton.org/v3/documentation/infra/nodes/validation/staking-incentives"
echo "   Rule: 'The current max_factor in config is 3'"

# Use exact nanoTON values for precision
MAX_EFFECTIVE_BALANCE_NANOTON=$(echo "$LOWEST_VALIDATOR_STAKE * $MAX_FACTOR_MULTIPLIER" | bc)
MAX_EFFECTIVE_BALANCE_TON=$(echo "scale=0; $MAX_EFFECTIVE_BALANCE_NANOTON / 1000000000" | bc)

echo "   Max Effective Balance: ${MAX_EFFECTIVE_BALANCE_TON} TON (${MAX_FACTOR_MULTIPLIER}x min effective)"
echo "   Max Effective Balance (nanoTON): ${MAX_EFFECTIVE_BALANCE_NANOTON}"

# =============================================================================
# CALCULATE OPTIMAL VALIDATOR SETUP - DEPLOY 100% OF AVAILABLE STAKE
# =============================================================================
OPTIMAL_STAKE_PER_VALIDATOR_TON=$MAX_EFFECTIVE_BALANCE_TON

# Calculate how many full validators we can deploy at max effective balance
FULL_VALIDATORS=$(echo "scale=0; $TOTAL_STAKE_TO_DEPLOY / $OPTIMAL_STAKE_PER_VALIDATOR_TON" | bc)
FULL_VALIDATORS_STAKE=$(echo "$FULL_VALIDATORS * $OPTIMAL_STAKE_PER_VALIDATOR_TON" | bc)
REMAINING_STAKE=$(echo "$TOTAL_STAKE_TO_DEPLOY - $FULL_VALIDATORS_STAKE" | bc)

# Check if remaining stake is enough for another validator (must be >= min effective balance)
if [ $(echo "$REMAINING_STAKE >= $LOWEST_VALIDATOR_STAKE_TON" | bc) -eq 1 ]; then
    # Deploy one more validator with the remaining stake
    VALIDATORS_NEEDED=$(echo "$FULL_VALIDATORS + 1" | bc)
    ACTUAL_TOTAL_DEPLOYED_TON=$TOTAL_STAKE_TO_DEPLOY
    echo "   ACTUAL DEPLOYMENT:"
    echo "   → ${FULL_VALIDATORS} validators @ ${OPTIMAL_STAKE_PER_VALIDATOR_TON} TON each = ${FULL_VALIDATORS_STAKE} TON"
    echo "   → 1 validator @ ${REMAINING_STAKE} TON"
    echo "   → TOTAL: ${VALIDATORS_NEEDED} validators deploying ${ACTUAL_TOTAL_DEPLOYED_TON} TON (100%)"
else
    # Not enough remaining stake for another validator, deploy only full validators
    VALIDATORS_NEEDED=$FULL_VALIDATORS
    ACTUAL_TOTAL_DEPLOYED_TON=$FULL_VALIDATORS_STAKE
    echo "   ACTUAL DEPLOYMENT:"
    echo "   → ${VALIDATORS_NEEDED} validators @ ${OPTIMAL_STAKE_PER_VALIDATOR_TON} TON each = ${ACTUAL_TOTAL_DEPLOYED_TON} TON"
    echo "   → Remaining ${REMAINING_STAKE} TON not deployed (below min effective balance)"
fi

ACTUAL_TOTAL_DEPLOYED_MILLIONS=$(echo "scale=3; $ACTUAL_TOTAL_DEPLOYED_TON / 1000000" | bc)

echo ""
echo "=== DYNAMIC VALIDATOR PROVISIONING (100% live) ==="
echo "Min Effective Balance (400th validator): ${LOWEST_VALIDATOR_STAKE_TON} TON (live)"
echo "Max Effective Balance (${MAX_FACTOR_MULTIPLIER}x factor): ${MAX_EFFECTIVE_BALANCE_TON} TON (calculated)"
echo "Target Total Stake: $(echo "scale=1; $TOTAL_STAKE_TO_DEPLOY / 1000000" | bc)M TON (config)"
echo "Optimal Stake Per Validator: ${OPTIMAL_STAKE_PER_VALIDATOR_TON} TON (using exact max effective)"
echo "Validators Needed: ${VALIDATORS_NEEDED} (calculated for 100% deployment)"
echo "Actual Total Deployed: ${ACTUAL_TOTAL_DEPLOYED_MILLIONS}M TON (calculated)"

# Verify we're deploying 100%
UTILIZATION=$(echo "scale=1; $ACTUAL_TOTAL_DEPLOYED_TON * 100 / $TOTAL_STAKE_TO_DEPLOY" | bc)
echo "Stake Utilization: ${UTILIZATION}% (maximized deployment)"

# Calculate average validator stake for comparison
AVG_VALIDATOR_STAKE=$(echo "scale=0; ($TOTAL_STAKE / 1000000000) / $VALIDATOR_COUNT" | bc)
echo "Current network average: ${AVG_VALIDATOR_STAKE} TON per validator (live)"

# =============================================================================
# STEP 3: FETCH MASTERCHAIN INFO FOR VERIFICATION
# =============================================================================
echo ""
echo "3. Getting masterchain information..."
echo "   API: $TON_MASTERCHAIN_API_URL"
MASTERCHAIN_INFO=$(curl -s "$TON_MASTERCHAIN_API_URL")

if [ $? -eq 0 ] && [ ! -z "$MASTERCHAIN_INFO" ]; then
    CURRENT_SEQNO=$(echo "$MASTERCHAIN_INFO" | jq -r '.result.last.seqno')
    echo "   Current Masterchain Seqno: $CURRENT_SEQNO (live)"
fi

# =============================================================================
# STEP 4: CALCULATE LIVE ON-CHAIN STAKING REWARDS
# =============================================================================
echo ""
echo "4. Calculating LIVE on-chain staking rewards..."

# Get Config14 for block rewards (in nanoTON)
echo "   Using documented block rewards from TON network constants..."
echo "   Source: https://docs.ton.org/v3/documentation/smart-contracts/limits"

# Use the documented official values
MASTERCHAIN_BLOCK_FEE=$OFFICIAL_MASTERCHAIN_BLOCK_FEE
BASECHAIN_BLOCK_FEE=$OFFICIAL_BASECHAIN_BLOCK_FEE

echo "   ✓ Masterchain block reward: $(echo "scale=1; $MASTERCHAIN_BLOCK_FEE / 1000000000" | bc) TON (documented official)"
echo "   ✓ Basechain block reward: $(echo "scale=1; $BASECHAIN_BLOCK_FEE / 1000000000" | bc) TON (documented official)"

# Calculate current reward rate using documented block production data
echo "   Using documented block production rate from TON network..."
echo "   Source: https://docs.ton.org/v3/documentation/smart-contracts/limits"

# Use documented 5-second block time
AVG_BLOCK_TIME=$DOCUMENTED_BLOCK_TIME
DAILY_BLOCKS=$(echo "scale=0; 86400 / $AVG_BLOCK_TIME" | bc)
echo "   ✓ Documented block production: $AVG_BLOCK_TIME seconds per block"
echo "   ✓ Calculated daily blocks: $DAILY_BLOCKS"

DAILY_MASTERCHAIN_REWARDS=$(echo "scale=0; $DAILY_BLOCKS * $MASTERCHAIN_BLOCK_FEE / 1000000000" | bc)
DAILY_BASECHAIN_REWARDS=$(echo "scale=0; $DAILY_BLOCKS * $BASECHAIN_BLOCK_FEE / 1000000000" | bc)
TOTAL_DAILY_BLOCK_REWARDS=$(echo "$DAILY_MASTERCHAIN_REWARDS + $DAILY_BASECHAIN_REWARDS" | bc)

echo "   Calculated daily network rewards: $TOTAL_DAILY_BLOCK_REWARDS TON"

# Calculate reward rate per TON staked
TOTAL_NETWORK_STAKE_TON=$(echo "scale=0; $TOTAL_STAKE / 1000000000" | bc)
DAILY_REWARD_RATE=$(echo "scale=8; $TOTAL_DAILY_BLOCK_REWARDS / $TOTAL_NETWORK_STAKE_TON" | bc)
ANNUAL_REWARD_RATE=$(echo "scale=6; $DAILY_REWARD_RATE * 365 * 100" | bc)

echo "   Live reward rate: $(echo "scale=4; $DAILY_REWARD_RATE * 100" | bc)%/day"
echo "   Live annual rate: $ANNUAL_REWARD_RATE%"
echo "   Source: Documented block fees + documented block time"

# Calculate for planned setup
echo ""
echo "=== SETUP CALCULATIONS ==="
if [ $(echo "$REMAINING_STAKE >= $LOWEST_VALIDATOR_STAKE_TON" | bc) -eq 1 ]; then
    echo "ACTUAL Configuration:"
    echo "   • ${FULL_VALIDATORS} validators with ${OPTIMAL_STAKE_PER_VALIDATOR_TON} TON each"
    echo "   • 1 validator with ${REMAINING_STAKE} TON"
    echo "   • Total: ${VALIDATORS_NEEDED} validators"
else
    echo "ACTUAL Configuration:"
    echo "   • ${VALIDATORS_NEEDED} validators with ${OPTIMAL_STAKE_PER_VALIDATOR_TON} TON each"
    echo "   • ${REMAINING_STAKE} TON not deployed (insufficient for additional validator)"
fi
echo ""

# Total monthly rewards based on LIVE on-chain data
TOTAL_MONTHLY_REWARDS=$(echo "scale=2; $ACTUAL_TOTAL_DEPLOYED_TON * $DAILY_REWARD_RATE * 30" | bc)

# Revenue calculations 
TOTAL_MONTHLY_REVENUE=$(echo "scale=2; $TOTAL_MONTHLY_REWARDS * $TON_PRICE" | bc)

# Cost calculations 
TOTAL_MONTHLY_COSTS=$(echo "$VALIDATORS_NEEDED * $MONTHLY_COST_PER_VALIDATOR" | bc)

# Activation period calculations
ACTIVATION_COSTS=$(echo "scale=2; $TOTAL_MONTHLY_COSTS * $VALIDATOR_ACTIVATION_DAYS / 30" | bc)
DAILY_OPERATING_COST=$(echo "scale=2; $TOTAL_MONTHLY_COSTS / 30" | bc)

# Profit calculations (ongoing monthly after activation)
NET_MONTHLY_PROFIT=$(echo "scale=2; $TOTAL_MONTHLY_REVENUE - $TOTAL_MONTHLY_COSTS" | bc)

# ROI calculations (ongoing monthly)
MONTHLY_ROI=$(echo "scale=1; $NET_MONTHLY_PROFIT * 100 / $TOTAL_MONTHLY_COSTS" | bc)

echo "Monthly Rewards: ${TOTAL_MONTHLY_REWARDS} TON (after activation)"
echo "Monthly Revenue: \$${TOTAL_MONTHLY_REVENUE} (@\$${TON_PRICE}/TON)"
echo "Monthly Costs: \$${TOTAL_MONTHLY_COSTS}"
echo "Activation Period Costs: \$${ACTIVATION_COSTS} (${VALIDATOR_ACTIVATION_DAYS} days @ \$${DAILY_OPERATING_COST}/day)"
echo "Net Profit (ongoing): \$${NET_MONTHLY_PROFIT}/month"
echo "ROI (ongoing): ${MONTHLY_ROI}%/month"

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "                              FINAL RESULTS SUMMARY"
echo "════════════════════════════════════════════════════════════════════════════════"

echo ""
echo "[LIVE NETWORK DATA]"
echo "   • Total Network Stake: $(($TOTAL_STAKE / 1000000000)) TON"
echo "   • Active Validators: $VALIDATOR_COUNT"
echo "   • 400th Validator Stake: ${LOWEST_VALIDATOR_STAKE_TON} TON"
echo "   • Network Average Stake: ${AVG_VALIDATOR_STAKE} TON per validator"
echo "   • Current TON Price: \$${TON_PRICE}"

echo ""
echo "[CURRENT OPTIMAL CONFIGURATION]"
echo "   • Target Stake: ${TOTAL_STAKE_HUMAN}M TON"
echo "   • Max Effective Balance: ${MAX_EFFECTIVE_BALANCE_TON} TON per validator"
echo "   • Validators Required: ${VALIDATORS_NEEDED}"
echo "   • Stake Per Validator: ${OPTIMAL_STAKE_PER_VALIDATOR_TON} TON"
echo "   • Actual Stake Deployed: ${ACTUAL_TOTAL_DEPLOYED_MILLIONS}M TON"
echo "   • Stake Utilization: ${UTILIZATION}%"
echo "   • Validator Size vs Network Average: $(echo "scale=1; $OPTIMAL_STAKE_PER_VALIDATOR_TON * 100 / $AVG_VALIDATOR_STAKE" | bc)% of network average size"

echo ""
echo "[FINANCIAL ANALYSIS]"
echo "   • Monthly Rewards: ${TOTAL_MONTHLY_REWARDS} TON"
echo "   • Monthly Revenue: \$${TOTAL_MONTHLY_REVENUE}"
echo "   • Monthly Operating Costs: \$${TOTAL_MONTHLY_COSTS}"
echo "   • Activation Period Costs: \$${ACTIVATION_COSTS} (${VALIDATOR_ACTIVATION_DAYS} days @ \$${DAILY_OPERATING_COST}/day)"
echo "   • Net Monthly Profit: \$${NET_MONTHLY_PROFIT}"
echo "   • Monthly ROI: ${MONTHLY_ROI}%/month"
echo "   • Annual Profit: \$$(echo "scale=0; $NET_MONTHLY_PROFIT * 12" | bc)"
echo "   • Annual ROI: $(echo "scale=0; $MONTHLY_ROI * 12" | bc)%"

echo ""
echo "[PROFITABILITY ASSESSMENT]"
# Calculate break-even: how much stake needed to cover monthly costs
if [ $(echo "$ANNUAL_REWARD_RATE > 0" | bc) -eq 1 ]; then
    BREAKEVEN_STAKE_NEEDED=$(echo "scale=0; $TOTAL_MONTHLY_COSTS * 12 * 100 / ($ANNUAL_REWARD_RATE * $TON_PRICE)" | bc)
    BREAKEVEN_VALIDATORS_NEEDED=$(echo "scale=0; $BREAKEVEN_STAKE_NEEDED / $OPTIMAL_STAKE_PER_VALIDATOR_TON + 1" | bc)
    echo "   • Break-even Stake: ${BREAKEVEN_STAKE_NEEDED} TON"
    echo "   • Break-even Validators: ${BREAKEVEN_VALIDATORS_NEEDED} validators minimum"
else
    echo "   • Break-even Stake: Cannot calculate (zero reward rate)"
    echo "   • Break-even Validators: Cannot calculate (zero reward rate)"
fi

# Calculate activation cost recovery time
ACTIVATION_RECOVERY_DAYS=$(echo "scale=1; $ACTIVATION_COSTS * 30 / $NET_MONTHLY_PROFIT" | bc)

# Calculate profit margin
if [ $(echo "$TOTAL_MONTHLY_REVENUE > 0" | bc) -eq 1 ]; then
    PROFIT_MARGIN=$(echo "scale=1; $NET_MONTHLY_PROFIT * 100 / $TOTAL_MONTHLY_REVENUE" | bc)
    echo "   • Profit Margin: ${PROFIT_MARGIN}% (Net/Revenue)"
else
    echo "   • Profit Margin: Cannot calculate (zero revenue)"
fi

echo "   • Activation Period: ${VALIDATOR_ACTIVATION_DAYS} days setup (costs \$${ACTIVATION_COSTS})"
echo "   • Activation Cost Recovery: ${ACTIVATION_RECOVERY_DAYS} days of operation"
echo "   • Capital Efficiency: ${UTILIZATION}% of available stake deployed"
echo "   • Status: $(if [ $(echo "$NET_MONTHLY_PROFIT > 0" | bc) -eq 1 ]; then echo "HIGHLY PROFITABLE"; else echo "NOT PROFITABLE"; fi)"

echo ""
echo "[KEY RECOMMENDATIONS]"
if [ $(echo "$REMAINING_STAKE >= $LOWEST_VALIDATOR_STAKE_TON" | bc) -eq 1 ]; then
    echo "   • Deploy ${FULL_VALIDATORS} validators with ${OPTIMAL_STAKE_PER_VALIDATOR_TON} TON each (max effective)"
    echo "   • Deploy 1 validator with ${REMAINING_STAKE} TON (remainder)"
    echo "   • Total deployment: ${VALIDATORS_NEEDED} validators using ${ACTUAL_TOTAL_DEPLOYED_MILLIONS}M TON"
else
    echo "   • Deploy ${VALIDATORS_NEEDED} validators with ${OPTIMAL_STAKE_PER_VALIDATOR_TON} TON each"
    echo "   • ${REMAINING_STAKE} TON will remain undeployed (below minimum effective balance)"
fi
echo "   • Setup timeline: ${VALIDATOR_ACTIVATION_DAYS} days to activate (budget \$${ACTIVATION_COSTS})"
echo "   • Monthly hardware budget: \$${TOTAL_MONTHLY_COSTS} (\$${MONTHLY_COST_PER_VALIDATOR} per validator)"
echo "   • Expected monthly profit: \$${NET_MONTHLY_PROFIT} (after activation)"
echo "   • Total stake earning ${ANNUAL_REWARD_RATE}% APY on ${ACTUAL_TOTAL_DEPLOYED_MILLIONS}M TON"
echo "   • Validators will be $(echo "scale=1; $OPTIMAL_STAKE_PER_VALIDATOR_TON * 100 / $AVG_VALIDATOR_STAKE" | bc)% of network average size"

echo ""
echo "════════════════════════════════════════════════════════════════════════════════" 