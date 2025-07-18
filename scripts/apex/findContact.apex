// Find your contact without sending any SMS
// This is completely safe - just queries data

System.debug('=== Find Your Contact (Safe Query) ===');

try {
    // Method 1: Search by your name
    List<Contact> contactsByName = [SELECT Id, Name, Phone, Email 
                                   FROM Contact 
                                   WHERE Name LIKE '%YOUR_NAME%'  // Replace with your name
                                   LIMIT 5];
    
    System.debug('Contacts found by name:');
    for (Contact c : contactsByName) {
        System.debug('ID: ' + c.Id + ' - Name: ' + c.Name + ' - Phone: ' + c.Phone);
    }
    
    System.debug('---');
    
    // Method 2: Search by email domain
    List<Contact> contactsByEmail = [SELECT Id, Name, Phone, Email 
                                    FROM Contact 
                                    WHERE Email LIKE '%@YOUR_DOMAIN%'  // Replace with your email domain
                                    LIMIT 5];
    
    System.debug('Contacts found by email domain:');
    for (Contact c : contactsByEmail) {
        System.debug('ID: ' + c.Id + ' - Name: ' + c.Name + ' - Phone: ' + c.Phone + ' - Email: ' + c.Email);
    }
    
    System.debug('---');
    System.debug('COPY ONE OF THE IDs ABOVE TO USE IN THE SAFE TEST SCRIPT');
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}

System.debug('=== Query Complete ===');
