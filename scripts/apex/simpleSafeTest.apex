// Simple test without SMS_History queries
System.debug('=== Simple Safe Test ===');

try {
    // Test your specific contact
    String testContactId = '0033h00000KH54TAAT';
    
    // Query the contact
    List<Contact> testContacts = [SELECT Id, Name, Phone FROM Contact WHERE Id = :testContactId];
    
    if (testContacts.size() > 0) {
        Contact testContact = testContacts[0];
        System.debug('Testing with Contact: ' + testContact.Name + ' - Phone: ' + testContact.Phone);
        
        if (testContact.Phone != null) {
            System.debug('Phone number found - calling sendBulkSMS...');
            
            // Test the sendBulkSMS method
            List<Id> contactIds = new List<Id>{testContact.Id};
            String result = BulkSMSController.sendBulkSMS(contactIds, 'TEST MESSAGE - Simple safe test', '');
            System.debug('sendBulkSMS result: ' + result);
            
            System.debug('Test completed successfully!');
            
        } else {
            System.debug('ERROR: Contact has no phone number');
        }
        
    } else {
        System.debug('ERROR: Contact not found with ID: ' + testContactId);
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Simple Safe Test Complete ===');
