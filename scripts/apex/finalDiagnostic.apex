// Final diagnostic - check exactly what the controller sees
System.debug('=== Final Diagnostic ===');

try {
    String testContactId = '0033h00000KH54TAAT';
    
    // Query the contact with all possible phone fields
    List<Contact> contacts = [SELECT Id, Name, Phone, MobilePhone, hed__SMS_Opt_Out__c 
                             FROM Contact 
                             WHERE Id = :testContactId];
    
    if (contacts.size() > 0) {
        Contact c = contacts[0];
        System.debug('Contact: ' + c.Name);
        System.debug('Phone: ' + c.Phone);
        System.debug('MobilePhone: ' + c.MobilePhone);
        System.debug('hed__SMS_Opt_Out__c: ' + c.hed__SMS_Opt_Out__c);
        
        // Test the exact logic from BulkSMSController
        System.debug('--- Controller Logic Test ---');
        
        // Test with Phone field (current assumption)
        if (String.isBlank(c.Phone) || c.hed__SMS_Opt_Out__c) {
            System.debug('PHONE field would be FILTERED OUT');
            System.debug('Phone blank: ' + String.isBlank(c.Phone));
            System.debug('SMS Opt Out: ' + c.hed__SMS_Opt_Out__c);
        } else {
            System.debug('PHONE field would be QUEUED');
        }
        
        // Test with MobilePhone field
        if (String.isBlank(c.MobilePhone) || c.hed__SMS_Opt_Out__c) {
            System.debug('MOBILEPHONE field would be FILTERED OUT');
            System.debug('MobilePhone blank: ' + String.isBlank(c.MobilePhone));
            System.debug('SMS Opt Out: ' + c.hed__SMS_Opt_Out__c);
        } else {
            System.debug('MOBILEPHONE field would be QUEUED');
        }
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}

System.debug('=== Diagnostic Complete ===');
