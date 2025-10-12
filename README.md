# Lending Lite

![Test Coverage](https://img.shields.io/badge/Apex_Coverage-%E2%89%A585%25-brightgreen)

## Overview
Lending Lite is a Salesforce-based lending application designed to demonstrate production-grade software engineering practices within the Salesforce platform. The project is built with a strong emphasis on clean architecture, modular design, and CI/CD automation.

## Architecture
The system follows a **layered architecture** aligned with Salesforce best practices:

```
+--------------------------+
|        Lightning UI      |  ← LWC (loanAppWorkbench)
+------------+-------------+
             ↓
+------------+-------------+
|   Apex Controller Layer  |  ← LoanApplicationController
+------------+-------------+
             ↓
+------------+-------------+
|     Trigger Layer        |  ← LoanApplicationTrigger
+------------+-------------+
             ↓
+------------+-------------+
|   Handler Layer          |  ← LoanSubmitHandler
+------------+-------------+
             ↓
+------------+-------------+
|   Service Layer           |  ← LoanApplicationService, ServiceFactory
+------------+-------------+
             ↓
+------------+-------------+
| Integration/Async Layer   |
|  (REST, Platform Events,  |
|   Queueables, External    |
|   Credit Bureau API)      |
+--------------------------+
```

### Data Flow Summary
- **Trigger → Handler → Service:** Loan submission events are processed through a decoupled chain promoting reusability and testability.
- **REST Layer:** Exposes the `CreditScoreRest` API for external integrations.
- **Platform Events:** Publishes `Credit_Risk_Calculation_Request__e` for async communication.
- **Queueable Jobs:** Handles background processing and external service calls.

## Key Features
- **Unlocked Package Structure** for modular deployment.
- **Trigger-Handler-Service Pattern** for maintainability.
- **Dependency Injection via `ServiceFactory`** and `@TestVisible` annotations.
- **Automated Testing & CI/CD** via GitHub Actions.
- **Pre-commit Hooks (Husky + Prettier)** for code quality enforcement.
- **Lightning Web Component (LWC)** for loan application UI.

## Test Strategy
Unit tests are implemented for all major classes, leveraging a central `TestDataFactory` for consistency. The project maintains **≥85% Apex coverage** across the namespace.

## CI/CD Pipeline
The repository includes GitHub Actions workflows for:
- Pull Request validation (linting, test execution)
- Automated packaging and deployment
- Version tagging for releases

## Extensibility
The solution is designed for easy evolution:
- New features or UI elements can be added without impacting core logic.
- Service interfaces promote scalability and testability.
- Platform Events and Queueables ensure asynchronous extensibility.

## Getting Started
1. Clone the repository.
2. Authorize your Salesforce org with the Salesforce CLI.
3. Deploy the package using `sfdx force:source:deploy` or package install link.
4. Run tests: `sfdx force:apex:test:run -c -r human -w 10`.

## License
MIT License

