// Check available phone fields on Contact object
System.debug('=== Contact Phone Fields Check ===');

try {
    // Get the Contact object descriptor
    Schema.SObjectType contactType = Contact.SObjectType;
    Schema.DescribeSObjectResult contactDescribe = contactType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = contactDescribe.fields.getMap();
    
    System.debug('Available phone-related fields on Contact:');
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.toLowerCase().contains('phone') || fieldName.toLowerCase().contains('mobile')) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            System.debug('Field: ' + fieldName + ' - Label: ' + fieldDescribe.getLabel());
        }
    }
    
    // Now check your specific contact
    String testContactId = '0033h00000KH54TAAT';
    
    // Query with basic phone fields first
    List<Contact> contacts = [SELECT Id, Name, Phone FROM Contact WHERE Id = :testContactId];
    
    if (contacts.size() > 0) {
        System.debug('Contact found: ' + contacts[0].Name);
        System.debug('Phone field value: ' + contacts[0].Phone);
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Field Check Complete ===');
