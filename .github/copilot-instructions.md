# Copilot Instructions for Bulk SMS Salesforce Application

## Architecture Overview

This is a **Salesforce Force.com** application for bulk SMS messaging via **Genesys Cloud API**. The system uses a **3-layer architecture**:

1. **UI Layer**: Lightning Web Components (LWC) + Salesforce Flows for user interaction
2. **Service Layer**: Apex controllers (`BulkSMSController`, `FlowSMSSender`, `FlowBulkSMS`) for business logic  
3. **Integration Layer**: `GenesysSMSInvoker` for external API calls via Named Credentials

**Key Design Decision**: Flow integration uses **string concatenation** instead of custom objects due to Salesforce Flow limitations with complex types. Context data format: `"contactIds|||useTemplate?templateName:messageText|||fromAddress"`

## Critical Workflows

### Development & Testing
```bash
# Code quality scanning (v5.x configuration)
sf scanner run --target "force-app" --engine "pmd" --format "table"

# Deploy to scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias bulksms-scratch
sf project deploy start --target-org bulksms-scratch

# Test in Anonymous Apex (use scripts/apex/*.apex files)
sf apex run --file scripts/apex/deploymentVerification.apex --target-org bulksms-scratch
```

### Flow Testing Pattern
Use `scripts/apex/testEnhancedFlow.apex` to test Flow integration:
- Creates test Contact with phone
- Builds context string in pipe-delimited format  
- Invokes `FlowSMSSender.sendSMSFromFlow()` directly

## Project-Specific Conventions

### Security & Compliance
- **All classes use `with sharing`** - no exceptions
- **Custom metadata queries suppress PMD warnings** with `//NOPMD ApexCRUDViolation` (custom metadata is secure by design)
- **User context in tests**: Always use `System.runAs()` in test classes for proper security context
- **CRUD/FLS compliance**: Use `WITH USER_MODE` in SOQL queries for data security
- **DML operations**: Use `insert as user` and validate `Schema.sObjectType.ObjectName.isCreateable()` before DML

### Error Handling Pattern
```apex
try {
    // Check CRUD permissions before database operations
    if (!Schema.sObjectType.ObjectName.isCreateable()) {
        System.debug(LoggingLevel.ERROR, 'User lacks create permission for ObjectName');
        return;
    }
    
    // Business logic with proper logging levels
    System.debug(LoggingLevel.INFO, 'Success message');
} catch (Exception e) {
    String errorMsg = 'ERROR: ' + e.getMessage();
    System.debug(LoggingLevel.ERROR, 'Component error: ' + errorMsg);
    // Always return user-friendly error messages
}
```

### Flow Integration Standards
- **String parameters only** - avoid custom Apex types in `@InvocableMethod`
- **Pipe-delimited format**: `"data1|||data2|||data3"` for complex parameters
- **Template vs Custom logic**: Use ternary format `"useTemplate?templateName:customMessage"`

## Key Integration Points

### External Dependencies
- **Genesys Cloud SMS API**: Configured via `callout:GenesysSMS` Named Credential
- **Custom Metadata**: `SMS_Template__mdt` for message templates, `Genesys_SMS_Configuration__mdt` for API settings
- **Custom Objects**: `SMS_History__c` (tracking), `SMS_Log__c` (auditing)

### Cross-Component Communication
- **LWC → Controller**: `BulkSMSController.sendBulkSMSFromLWC()` for component integration
- **Flow → Service**: `FlowSMSSender.sendSMSFromFlow()` with string context data
- **Service → API**: `GenesysSMSInvoker.sendSMSFuture()` for async external calls

### Data Flow Pattern
1. UI collects Contact IDs + message/template choice
2. Context string built: `"contactId1,contactId2|||false?:Custom message|||+15551234567"`
3. `FlowSMSSender` parses context → validates → calls `GenesysSMSInvoker`
4. `GenesysSMSInvoker` makes HTTP callout → logs to `SMS_History__c`

## Essential Files for Understanding

- **`FlowSMSSender.cls`**: Core Flow integration with string parsing logic
- **`GenesysSMSInvoker.cls`**: External API integration pattern with Named Credentials
- **`force-app/main/default/flows/Bulk_SMS_Screen_Flow.flow-meta.xml`**: User interface flow with template selection
- **`scripts/apex/deploymentVerification.apex`**: Deployment testing template
- **`code-analyzer.yml`**: PMD configuration (Flow engine disabled for performance)

## Testing Approach

- **Unit Tests**: Focus on `System.runAs()` for security context, mock external callouts
- **Integration Tests**: Use anonymous Apex scripts in `scripts/apex/` directory
- **Flow Tests**: Use `testEnhancedFlow.apex` pattern for end-to-end validation
- **Deployment Verification**: Run `deploymentVerification.apex` after each deployment

When modifying this codebase, maintain the string-based Flow integration pattern and always test with realistic Contact data having phone numbers.
