// Verify that the Bulk_SMS_Flow can be executed programmatically
// This simulates what happens when the flow is triggered from the UI

System.debug('=== Bulk SMS Flow Integration Test ===');

// Test 1: Verify the flow exists and can be found
List<Flow> bulkSMSFlows = [SELECT Id, ApiName, Label, Status FROM Flow WHERE ApiName = 'Bulk_SMS_Flow' AND Status = 'Active'];
if (!bulkSMSFlows.isEmpty()) {
    System.debug('✓ Bulk_SMS_Flow found: ' + bulkSMSFlows[0].Label + ' (Status: ' + bulkSMSFlows[0].Status + ')');
} else {
    System.debug('✗ Bulk_SMS_Flow not found or not active');
}

// Test 2: Find a test contact with phone number
List<Contact> testContacts = [SELECT Id, Name, Phone FROM Contact WHERE Phone != null LIMIT 1];
if (testContacts.isEmpty()) {
    System.debug('✗ No contacts with phone numbers found for testing');
} else {
    Contact testContact = testContacts[0];
    System.debug('✓ Test contact found: ' + testContact.Name + ' (' + testContact.Phone + ')');
    
    // Test 3: Verify that our FlowSMSSender method can handle the context string format
    String testMessage = 'Integration test message from flow verification';
    String testFromAddress = '+15551234567';
    String contextString = testContact.Id + '|||' + testMessage + '|||' + testFromAddress;
    
    System.debug('Testing context string format: ' + contextString);
    
    try {
        List<String> contextList = new List<String>{contextString};
        List<String> result = FlowSMSSender.flowSMSSender(contextList);
        System.debug('✓ FlowSMSSender method executed successfully');
        System.debug('Result: ' + result[0]);
        
        // Check if SMS was queued successfully
        if (result[0].contains('SUCCESS')) {
            System.debug('✓ SMS was successfully queued through the flow method');
        } else {
            System.debug('⚠ SMS queueing had issues: ' + result[0]);
        }
        
    } catch (Exception e) {
        System.debug('✗ Error executing FlowSMSSender: ' + e.getMessage());
    }
}

System.debug('=== Flow Integration Test Complete ===');
