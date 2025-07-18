// Test with contacts that have phone numbers
System.debug('=== Testing with Phone Numbers ===');

try {
    // Test 1: Find contacts with phone numbers
    List<Contact> contactsWithPhones = [SELECT Id, Name, Phone FROM Contact WHERE Phone != null LIMIT 3];
    System.debug('Found ' + contactsWithPhones.size() + ' contacts with phone numbers');
    
    if (contactsWithPhones.size() > 0) {
        for (Contact c : contactsWithPhones) {
            System.debug('Contact: ' + c.Name + ' - Phone: ' + c.Phone);
        }
        
        // Test 2: Call sendBulkSMS with contacts that have phone numbers
        List<Id> contactIds = new List<Id>();
        for (Contact c : contactsWithPhones) {
            contactIds.add(c.Id);
        }
        
        String result = BulkSMSController.sendBulkSMS(contactIds, 'Test message for contacts with phones', '');
        System.debug('sendBulkSMS result: ' + result);
        
        // Test 3: Check if records were created
        List<SMS_History__c> recentHistory = [SELECT Id, Contact__c, Message_Text__c, Status__c FROM SMS_History__c ORDER BY CreatedDate DESC LIMIT 5];
        System.debug('SMS History records created: ' + recentHistory.size());
        
    } else {
        System.debug('No contacts with phone numbers found. Creating test data...');
        
        // Create a test contact with a phone number
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '+1234567890'
        );
        insert testContact;
        
        System.debug('Created test contact: ' + testContact.Id);
        
        // Test with the new contact
        String result = BulkSMSController.sendBulkSMS(new List<Id>{testContact.Id}, 'Test message for new contact', '');
        System.debug('sendBulkSMS result: ' + result);
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Test Complete ===');
