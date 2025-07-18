// Alternative: Search by partial phone number
// Replace 'YOUR_PHONE_PATTERN' with part of your phone number

System.debug('=== Phone Number Search Test ===');

try {
    // STEP 1: Replace with part of your phone number (last 4 digits work well)
    String phonePattern = '%YOUR_PHONE_PATTERN%'; // Replace with something like '%1234%'
    
    // STEP 2: Search for contacts with your phone pattern
    List<Contact> matchingContacts = [SELECT Id, Name, Phone 
                                     FROM Contact 
                                     WHERE Phone LIKE :phonePattern 
                                     LIMIT 5];
    
    System.debug('Found ' + matchingContacts.size() + ' contacts matching phone pattern');
    
    for (Contact c : matchingContacts) {
        System.debug('Contact: ' + c.Name + ' - Phone: ' + c.Phone);
    }
    
    // STEP 3: If you see your contact in the results above, uncomment and modify below:
    /*
    if (matchingContacts.size() > 0) {
        Contact yourContact = matchingContacts[0]; // Adjust index if needed
        System.debug('Testing with: ' + yourContact.Name);
        
        String result = BulkSMSController.sendBulkSMS(
            new List<Id>{yourContact.Id}, 
            'TEST - Phone pattern search test', 
            ''
        );
        System.debug('Result: ' + result);
    }
    */
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}

System.debug('=== Phone Search Complete ===');
