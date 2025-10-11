# Lending-lite

A Salesforce unlocked package for loan application management with integrated credit risk assessment.

## Overview

This package provides core functionality for processing loan applications, including credit score evaluation and risk calculation. It uses platform events for asynchronous credit risk processing and integrates with external credit bureau services.

## Package Information

**Latest Version:** 0.3.0.1  
**Package ID:** 04tNS000000CU7BYAW  
**Namespace:** None (unlocked package)

## Installation

Install using Salesforce CLI:

```bash
sf package install --package 04tNS000000CU7BYAW --wait 10 --target-org YOUR_ORG_ALIAS
```

Or install via browser:
```
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tNS000000CU7BYAW
```

## Features

- Loan application management with custom objects
- REST API endpoints for credit score retrieval
- Platform event-based credit risk calculation
- Integration with external credit bureau services
- Service layer architecture with dependency injection
- Comprehensive test coverage (86%)

## Development

### Prerequisites

- Salesforce CLI
- Dev Hub enabled org
- Node.js 20+

### Setup

1. Clone the repository
2. Authenticate to your Dev Hub:
   ```bash
   sf org login web --set-default-dev-hub --alias DevHub
   ```

3. Create a scratch org:
   ```bash
   sf org create scratch --definition-file config/project-scratch-def.json --alias lending-scratch --set-default
   ```

4. Deploy the source:
   ```bash
   sf project deploy start
   ```

5. Run tests:
   ```bash
   sf apex run test --test-level RunLocalTests --code-coverage --result-format human
   ```

### Project Structure

```
force-app/main/default/
├── classes/
│   ├── external/         # External service integrations
│   ├── handlers/         # Trigger handlers
│   ├── services/         # Business logic layer
│   ├── webservices/      # REST API endpoints
│   └── tests/            # Test classes
├── objects/
│   ├── Loan_Application__c/
│   ├── Party__c/
│   └── Credit_Risk_Calculation_Request__e/
└── triggers/
```

## CI/CD

The project uses GitHub Actions for continuous integration and package releases.

### Workflows

**PR Validation** - Runs on pull requests to main branch:
- Creates temporary scratch org
- Deploys metadata
- Runs all tests with code coverage
- Posts results as PR comment

**Package Release** - Triggered on version bumps:
- Creates new package version
- Promotes to released status
- Creates GitHub release with installation instructions

### Contributing

1. Create a feature branch from main
2. Make your changes following the established patterns
3. Ensure all tests pass locally
4. Create a pull request
5. Wait for automated validation to complete

## Architecture

### Service Layer

Uses factory pattern for dependency injection, making the code testable and maintainable. See `ServiceFactory` class for implementation details.

### Testing Strategy

All test classes follow the AAA (Arrange, Act, Assert) pattern for clarity and consistency. Mock implementations are used for external dependencies.

## License

This is a demo project for educational purposes.

## Resources

- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

