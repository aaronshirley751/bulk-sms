// Test enhanced flow with template
System.debug('Enhanced Flow Template Integration Test');

// Find contact with phone
List<Contact> contacts = [SELECT Id, Name, Phone FROM Contact WHERE Phone != null LIMIT 1];
if (contacts.isEmpty()) {
    System.debug('No contacts with phone numbers found');
} else {
    Contact testContact = contacts[0];
    System.debug('Using contact: ' + testContact.Name + ' (' + testContact.Phone + ')');
    
    // Test 1: Custom message (false? path)
    String customContext = testContact.Id + '|||false?:Enhanced flow custom message test|||+15551234567';
    System.debug('Custom message context: ' + customContext);
    
    try {
        List<String> result1 = FlowSMSSender.flowSMSSender(new List<String>{customContext});
        System.debug('Custom message result: ' + result1[0]);
    } catch (Exception e) {
        System.debug('Custom message error: ' + e.getMessage());
    }
    
    // Test 2: Template message (true? path)
    String templateContext = testContact.Id + '|||true?Welcome_New_Lead:Template message content|||+15551234567';
    System.debug('Template context: ' + templateContext);
    
    try {
        List<String> result2 = FlowSMSSender.flowSMSSender(new List<String>{templateContext});
        System.debug('Template message result: ' + result2[0]);
    } catch (Exception e) {
        System.debug('Template message error: ' + e.getMessage());
    }
}

System.debug('Enhanced flow test complete');
