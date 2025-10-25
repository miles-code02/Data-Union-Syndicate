# DataUnion Syndicate

A decentralized platform for pooling and monetizing personal or sensor data for AI training.

## Overview

DataUnion Syndicate enables users to collectively contribute data and share in the revenue generated from AI training datasets. Smart contracts automate verification, enforce privacy, and distribute proceeds proportionally.

## Features

- **Member Management**: Users can join the data union
- **Data Contribution**: Submit data contributions with cryptographic hashes
- **Verification System**: Contract owner verifies legitimate contributions
- **Revenue Distribution**: Automated earnings distribution to contributors
- **Transparent Tracking**: All contributions and earnings recorded on-chain

## Contract Functions

### Public Functions

- `join-union`: Register as a union member
- `submit-contribution`: Submit a data contribution with hash
- `verify-contribution`: Verify a contribution (owner only)
- `add-revenue`: Add revenue to distribution pool (owner only)
- `claim-earnings`: Claim earned revenue from contributions

### Read-Only Functions

- `get-member-info`: Retrieve member statistics
- `get-contribution`: Get contribution details
- `get-total-members`: View total union members
- `get-revenue-pool`: Check available revenue pool

## Getting Started
```bash
clarinet contract new data-union
clarinet check
clarinet test
```

## Testing

Run the test suite:
```bash
clarinet test
```