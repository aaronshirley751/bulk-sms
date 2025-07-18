// Safe test script - specify exact Contact ID to test with
// IMPORTANT: Replace 'YOUR_CONTACT_ID' with your actual contact ID before running

System.debug('=== Safe Bulk SMS Test ===');

try {
    // STEP 1: Using your specified Contact ID
    String testContactId = '0033h00000KH54TAAT';
    
    // STEP 2: Query the specific contact to verify it's yours
    List<Contact> testContacts = [SELECT Id, Name, Phone FROM Contact WHERE Id = :testContactId];
    
    if (testContacts.size() > 0) {
        Contact testContact = testContacts[0];
        System.debug('Testing with Contact: ' + testContact.Name + ' - Phone: ' + testContact.Phone);
        
        // STEP 3: Confirm this is the right contact before proceeding
        if (testContact.Phone != null) {
            System.debug('Phone number found - proceeding with test...');
            
            // STEP 4: Test the sendBulkSMS method
            List<Id> contactIds = new List<Id>{testContact.Id};
            String result = BulkSMSController.sendBulkSMS(contactIds, 'TEST MESSAGE - Safe bulk SMS test', '');
            System.debug('sendBulkSMS result: ' + result);
            
            // STEP 5: Check if SMS_History record was created
            List<SMS_History__c> history = [SELECT Id, Contact__c, Message_Text__c, Status__c 
                                          FROM SMS_History__c 
                                          WHERE Contact__c = :testContact.Id 
                                          ORDER BY CreatedDate DESC LIMIT 1];
            
            if (history.size() > 0) {
                System.debug('SMS History created - Status: ' + history[0].Status__c);
            } else {
                System.debug('No SMS History record found');
            }
            
        } else {
            System.debug('ERROR: Contact has no phone number');
        }
        
    } else {
        System.debug('ERROR: Contact not found with ID: ' + testContactId);
        System.debug('Please replace YOUR_CONTACT_ID with your actual contact ID');
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Safe Test Complete ===');
