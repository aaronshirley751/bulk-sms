// Quick diagnostic script to check system configuration
// This will help us understand what might be preventing the button from showing

System.debug('=== System Diagnostic for Bulk SMS ===');

// Check if the BulkSMSController class exists and is accessible
try {
    Type controllerType = Type.forName('BulkSMSController');
    System.debug('BulkSMSController class found: ' + (controllerType != null));
} catch (Exception e) {
    System.debug('Error accessing BulkSMSController: ' + e.getMessage());
}

// Check if custom objects exist
try {
    Schema.SObjectType smsLogType = Schema.getGlobalDescribe().get('SMS_Log__c');
    System.debug('SMS_Log__c object exists: ' + (smsLogType != null));
    
    Schema.SObjectType smsHistoryType = Schema.getGlobalDescribe().get('SMS_History__c');
    System.debug('SMS_History__c object exists: ' + (smsHistoryType != null));
    
    Schema.SObjectType smsTemplateType = Schema.getGlobalDescribe().get('SMS_Template__mdt');
    System.debug('SMS_Template__mdt object exists: ' + (smsTemplateType != null));
} catch (Exception e) {
    System.debug('Error checking custom objects: ' + e.getMessage());
}

// Check user permissions
User currentUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
System.debug('Current user: ' + currentUser.Name + ' (' + currentUser.Profile.Name + ')');
System.debug('Can modify all data: ' + FeatureManagement.checkPermission('ModifyAllData'));

// Check if we have any existing WebLinks on Contact
Schema.SObjectType contactType = Contact.sObjectType;
System.debug('Contact object accessible: ' + (contactType != null));

System.debug('=== Diagnostic Complete ===');
