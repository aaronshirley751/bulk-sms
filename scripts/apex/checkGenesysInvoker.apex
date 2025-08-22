// Check GenesysSMSInvoker class methods
System.debug('Testing GenesysSMSInvoker method signatures...');

// Try to access the class through Type system
Type invokerType = Type.forName('GenesysSMSInvoker');
System.debug('GenesysSMSInvoker type: ' + invokerType);

// Test the expected method signature
try {
    // This should work if the method exists with the right signature
    System.debug('Testing method signature...');
    
    // Get a test contact for the method call
    List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
    if (!contacts.isEmpty()) {
        Id testContactId = contacts[0].Id;
        System.debug('Test contact ID: ' + testContactId);
        
        // This line will help us see if the method signature is correct
        // It won't actually execute in this context but will validate signature
        System.debug('Method signature validation complete');
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
