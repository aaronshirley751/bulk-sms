// Simple test script for Bulk SMS functionality
System.debug('=== Simple Bulk SMS Test ===');

try {
    // Test 1: Check if BulkSMSController is accessible
    System.debug('Testing BulkSMSController accessibility...');
    
    // Test 2: Get one test Contact record
    List<Contact> testContacts = [SELECT Id, Name, Phone FROM Contact LIMIT 1];
    System.debug('Found ' + testContacts.size() + ' contacts');
    
    if (testContacts.size() > 0) {
        Contact testContact = testContacts[0];
        System.debug('Test Contact: ' + testContact.Name + ' - Phone: ' + testContact.Phone);
        
        // Test 3: Call the sendBulkSMS method with a single contact
        List<Id> contactIds = new List<Id>{testContact.Id};
        String result = BulkSMSController.sendBulkSMS(contactIds, 'Simple test message', '');
        System.debug('sendBulkSMS result: ' + result);
        
        System.debug('Test completed successfully!');
    } else {
        System.debug('No contacts found in the system.');
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Simple Test Complete ===');
