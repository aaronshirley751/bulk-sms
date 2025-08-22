// Test the updated FlowSMSSender method
System.debug('Testing flowSMSSender method...');

// Test the method directly first
List<String> testContext = new List<String>{'contact123|||Test message from updated method|||+15559876543'};
try {
    List<String> result = FlowSMSSender.flowSMSSender(testContext);
    System.debug('flowSMSSender method result: ' + result);
} catch (Exception e) {
    System.debug('Error calling flowSMSSender: ' + e.getMessage());
}

// Test with a real contact if available
List<Contact> testContacts = [SELECT Id FROM Contact WHERE Phone != null LIMIT 1];
if (!testContacts.isEmpty()) {
    String realContactId = testContacts[0].Id;
    List<String> realContext = new List<String>{realContactId + '|||Test message with real contact|||+15559876543'};
    
    try {
        List<String> realResult = FlowSMSSender.flowSMSSender(realContext);
        System.debug('Real contact test result: ' + realResult);
    } catch (Exception e) {
        System.debug('Error with real contact: ' + e.getMessage());
    }
} else {
    System.debug('No contacts with phone numbers found for testing');
}
