// Complete test for Enhanced Flow SMS functionality
System.debug('=== Testing Complete Enhanced Flow SMS Functionality ===');

try {
    // Test 1: Test FlowSMSHelper methods
    System.debug('--- Test 1: FlowSMSHelper Methods ---');
    
    // Get some test contact IDs
    List<Contact> testContacts = [SELECT Id, Name, MobilePhone FROM Contact WHERE MobilePhone != null LIMIT 2];
    if (!testContacts.isEmpty()) {
        List<String> contactIds = new List<String>();
        for (Contact c : testContacts) {
            contactIds.add(c.Id);
            System.debug('Test contact: ' + c.Name + ' - ' + c.MobilePhone);
        }
        
        // Test setting contact IDs
        List<List<String>> contactIdLists = new List<List<String>>();
        contactIdLists.add(contactIds);
        FlowSMSHelper.setContactIds(contactIdLists);
        
        // Test setting message text
        List<String> messageTexts = new List<String>();
        messageTexts.add('Enhanced Flow SMS Test Message');
        FlowSMSHelper.setMessageText(messageTexts);
        
        // Test setting from address
        List<String> fromAddresses = new List<String>();
        fromAddresses.add('+1234567890');
        FlowSMSHelper.setFromAddress(fromAddresses);
        
        System.debug('✅ FlowSMSHelper methods called successfully');
        
        // Test 2: Test FlowSMSSender with static variables set
        System.debug('--- Test 2: FlowSMSSender with Static Variables ---');
        
        List<String> results = FlowSMSSender.flowSMSSender();
        
        System.debug('Results from Enhanced FlowSMSSender:');
        for (String result : results) {
            System.debug('- ' + result);
        }
        
        if (!results.isEmpty() && results[0].startsWith('SUCCESS')) {
            System.debug('✅ Enhanced Flow SMS functionality test PASSED');
            System.debug('✅ SMS messages queued successfully via GenesysSMSInvoker');
        } else {
            System.debug('❌ Enhanced Flow SMS functionality test FAILED');
        }
        
    } else {
        System.debug('⚠️ No contacts with mobile phones found for testing');
    }
    
    // Test 3: Reset static variables and test fallback behavior
    System.debug('--- Test 3: Testing Fallback Behavior ---');
    FlowSMSSender.flowContactIds = null;
    FlowSMSSender.flowMessageText = null;
    FlowSMSSender.flowFromAddress = null;
    
    List<String> fallbackResults = FlowSMSSender.flowSMSSender();
    System.debug('Fallback test results:');
    for (String result : fallbackResults) {
        System.debug('- ' + result);
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing Enhanced Flow SMS: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Enhanced Flow SMS Test Complete ===');
