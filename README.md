# ImpactDAO

A decentralized autonomous organization (DAO) for managing impact-driven projects on the Stacks blockchain.

## Features
- Membership management with governance tokens
- Project proposal and voting system with input validation
- Fund allocation and distribution
- Impact reporting and tracking

## Getting Started
1. Clone the repository
2. Install dependencies with `clarinet install`
3. Run tests with `clarinet test`

## Contract Functions
### Membership
- join-dao: Join the DAO by purchasing governance tokens
- leave-dao: Leave the DAO and burn governance tokens

### Governance
- submit-proposal: Submit a new project proposal (requires valid title, description, and amount)
- vote: Vote on active proposals (restricted to token holders)
- execute-proposal: Execute approved proposals

### Treasury
- deposit: Deposit funds to the DAO treasury
- withdraw: Withdraw funds (requires proposal approval)

### Impact Tracking
- report-impact: Submit impact metrics for funded projects
- get-impact-metrics: Retrieve impact data for projects

## Input Validation
The contract now includes validation for proposal submissions:
- Title must not be empty
- Description must not be empty
- Amount must be greater than 0
- Only active proposals can receive votes
