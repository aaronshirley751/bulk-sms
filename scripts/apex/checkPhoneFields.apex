// Check what phone fields your contact has
System.debug('=== Phone Field Investigation ===');

try {
    String testContactId = '0033h00000KH54TAAT';
    
    // Query all phone-related fields
    List<Contact> testContacts = [SELECT Id, Name, Phone, MobilePhone, Mobile_E_164__c, hed__SMS_Opt_Out__c 
                                 FROM Contact 
                                 WHERE Id = :testContactId];
    
    if (testContacts.size() > 0) {
        Contact testContact = testContacts[0];
        System.debug('Contact: ' + testContact.Name);
        System.debug('Phone: ' + testContact.Phone);
        System.debug('MobilePhone: ' + testContact.MobilePhone);
        System.debug('Mobile_E_164__c: ' + testContact.Mobile_E_164__c);
        System.debug('hed__SMS_Opt_Out__c: ' + testContact.hed__SMS_Opt_Out__c);
        
        // Check which field has the phone number
        System.debug('--- Field Analysis ---');
        System.debug('Phone field populated: ' + (testContact.Phone != null));
        System.debug('MobilePhone field populated: ' + (testContact.MobilePhone != null));
        System.debug('Mobile_E_164__c field populated: ' + (testContact.Mobile_E_164__c != null));
        System.debug('SMS Opt Out: ' + (testContact.hed__SMS_Opt_Out__c == true));
        
    } else {
        System.debug('Contact not found');
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Investigation Complete ===');
