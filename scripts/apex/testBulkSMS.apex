// Test script for Bulk SMS functionality
// This script will test the BulkSMSController methods

System.debug('=== Starting Bulk SMS Test ===');

try {
    // Test 1: Get some test Contact records
    List<Contact> testContacts = [SELECT Id, Name, Phone FROM Contact WHERE Phone != null LIMIT 3];
    System.debug('Found ' + testContacts.size() + ' contacts with phone numbers');
    
    if (testContacts.size() > 0) {
        // Extract Contact IDs
        List<Id> contactIds = new List<Id>();
        for (Contact c : testContacts) {
            contactIds.add(c.Id);
            System.debug('Contact: ' + c.Name + ' - Phone: ' + c.Phone);
        }
        
        // Test 2: Test the sendBulkSMS method
        System.debug('Testing sendBulkSMS method...');
        String result = BulkSMSController.sendBulkSMS(contactIds, 'Test SMS message from Apex script', '');
        System.debug('Result: ' + result);
        
        // Test 3: Check if SMS_Log__c records were created
        List<SMS_Log__c> logs = [SELECT Id, Total_Records__c, Sent_Count__c, Failed_Count__c, Template_Used__c FROM SMS_Log__c ORDER BY CreatedDate DESC LIMIT 5];
        System.debug('Found ' + logs.size() + ' SMS log records');
        for (SMS_Log__c log : logs) {
            System.debug('Log: Total Records: ' + log.Total_Records__c + ', Sent: ' + log.Sent_Count__c + ', Failed: ' + log.Failed_Count__c);
        }
        
        // Test 4: Check if SMS_History__c records were created (using correct field names)
        List<SMS_History__c> history = [SELECT Id, Contact__c, Message_Text__c, Status__c FROM SMS_History__c ORDER BY CreatedDate DESC LIMIT 5];
        System.debug('Found ' + history.size() + ' SMS history records');
        for (SMS_History__c h : history) {
            System.debug('History: Contact ' + h.Contact__c + ' - Status: ' + h.Status__c + ' - Message: ' + h.Message_Text__c);
        }
        
    } else {
        System.debug('No contacts with phone numbers found. Please add some test contacts with phone numbers.');
    }
    
} catch (Exception e) {
    System.debug('Error during testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Bulk SMS Test Complete ===');
