# Bulk SMS End-to-End Testing Plan

## Pre-Testing Setup
1. **Verify Test Data**: Ensure you have Contacts with valid phone numbers
2. **Check SMS Templates**: Verify SMS Templates are available
3. **Verify Configuration**: Check Genesys SMS Configuration custom metadata

## Test Scenarios

### Test 1: Find Test Contacts
**Objective**: Identify contacts suitable for testing
**Script**: scripts/apex/findContact.apex
**Expected**: List of contacts with phone numbers

### Test 2: Verify Phone Numbers
**Objective**: Ensure contacts have valid phone numbers
**Script**: scripts/apex/checkPhoneFields.apex
**Expected**: Contacts with properly formatted phone numbers

### Test 3: Check SMS Templates
**Objective**: Verify SMS Templates are configured
**Script**: scripts/apex/checkTemplate.apex
**Expected**: Active SMS templates available

### Test 4: Quick Action from Contact Record
**Manual Test**:
1. Navigate to a Contact record in Lightning Experience
2. Look for "Bulk SMS" Quick Action in the actions menu
3. Click the action and verify Flow opens
4. Select a template and enter message
5. Submit and verify SMS is queued

### Test 5: Mass Action from Contact List View
**Manual Test**:
1. Navigate to Contacts tab
2. Select "All Contacts" or custom list view
3. Select multiple contacts (2-3 for testing)
4. Click "Bulk SMS" button in list view actions
5. Verify Flow opens with selected contact IDs
6. Select template and send test message

### Test 6: Flow Template Selection
**Manual Test**:
1. Start Bulk SMS Flow (either method)
2. Verify template dropdown shows available templates
3. Select a template and verify message populates
4. Modify message if needed
5. Submit and verify processing

### Test 7: Backend SMS Processing
**Apex Script**: scripts/apex/testBulkSMS.apex
**Expected**: 
- SMS records created in SMS_History__c
- Proper status tracking
- Error handling for invalid numbers

### Test 8: Enhanced Flow Functionality
**Apex Script**: scripts/apex/testEnhancedFlow.apex
**Expected**:
- Flow processes contact IDs correctly
- Template selection works
- Message customization functions

## Post-Test Verification
1. Check SMS_History__c records
2. Verify no errors in debug logs
3. Confirm proper status updates
4. Test error handling scenarios

## Rollback Plan
If issues are found:
1. Document specific failures
2. Check debug logs for errors
3. Restore LWC components if needed: `move force-app\main\default\lwc_backup force-app\main\default\lwc`
4. Revert any problematic metadata changes
