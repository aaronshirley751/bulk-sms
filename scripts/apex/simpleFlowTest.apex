// Simple test of enhanced flow functionality
System.debug('Enhanced Flow Template Test');

// Check for SMS templates
try {
    List<SMS_Template__mdt> templates = [SELECT DeveloperName, Label, Body__c FROM SMS_Template__mdt WHERE IsActive__c = true LIMIT 3];
    System.debug('Found ' + templates.size() + ' active templates');
    for (SMS_Template__mdt t : templates) {
        System.debug('Template: ' + t.Label + ' - ' + t.DeveloperName);
    }
} catch (Exception e) {
    System.debug('Template query error: ' + e.getMessage());
}

// Test the new context string format
List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 1];
if (!contacts.isEmpty()) {
    String testContext = contacts[0].Id + '|||false?:Test enhanced flow message|||+15551234567';
    System.debug('Test context: ' + testContext);
    
    try {
        List<String> result = FlowSMSSender.flowSMSSender(new List<String>{testContext});
        System.debug('Result: ' + result[0]);
    } catch (Exception e) {
        System.debug('FlowSMSSender error: ' + e.getMessage());
    }
}
