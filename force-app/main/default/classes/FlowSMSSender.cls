/**
 * @description Enhanced Flow SMS sender with full SMS functionality using input parameters
 * @author System Administrator  
 * @date 2025-07-28
 */
public with sharing class FlowSMSSender {
    
    // Static variables to receive Flow context values
    public static List<String> flowContactIds;
    public static String flowMessageText;
    public static String flowFromAddress;
    
    /**
     * @description Enhanced Flow-compatible method with full SMS sending capability
     * Uses a concatenated string parameter approach to receive Flow values
     */
    @InvocableMethod(label='Flow SMS Sender' description='Send SMS to multiple contacts from Flow with full functionality')
    public static List<String> flowSMSSender(List<String> contextData) {
        List<String> results = new List<String>();
        
        try {
            List<String> contactIds;
            String messageText;
            String fromAddress;
            
            // If context data provided, parse it
            if (contextData != null && !contextData.isEmpty() && String.isNotBlank(contextData[0])) {
                String[] parts = contextData[0].split('\\|\\|\\|');
                if (parts.size() >= 3) {
                    String contactIdsStr = parts[0];
                    // Remove trailing comma if present
                    if (contactIdsStr.endsWith(',')) {
                        contactIdsStr = contactIdsStr.substring(0, contactIdsStr.length() - 1);
                    }
                    contactIds = contactIdsStr.split(',');
                    messageText = parts[1];
                    fromAddress = parts[2];
                } else {
                    // Fallback to static variables
                    contactIds = flowContactIds;
                    messageText = flowMessageText;
                    fromAddress = flowFromAddress;
                }
            } else {
                // Use static variables if no context data
                contactIds = flowContactIds;
                messageText = flowMessageText;
                fromAddress = flowFromAddress;
            }
            
            // For testing: if no contact IDs provided, query some contacts
            if (contactIds == null || contactIds.isEmpty()) {
                List<Contact> testContacts = [SELECT Id FROM Contact WHERE (MobilePhone != null OR Phone != null) LIMIT 3];
                contactIds = new List<String>();
                for (Contact c : testContacts) {
                    contactIds.add(c.Id);
                }
            }
            
            if (contactIds == null || contactIds.isEmpty()) {
                results.add('ERROR: No contact IDs available for SMS sending');
                return results;
            }
            
            // Use defaults if values not provided
            if (String.isBlank(messageText)) {
                messageText = 'Test SMS from Enhanced Bulk SMS Flow';
            }
            if (String.isBlank(fromAddress)) {
                fromAddress = '+1234567890';
            }
            
            // Convert String IDs to proper Id type and query contacts
            List<Id> contactIdList = new List<Id>();
            for (String idStr : contactIds) {
                try {
                    if (String.isNotBlank(idStr.trim())) {
                        contactIdList.add((Id)idStr.trim());
                    }
                } catch (Exception e) {
                    System.debug('Invalid contact ID: ' + idStr + ', Error: ' + e.getMessage());
                }
            }
            
            if (contactIdList.isEmpty()) {
                results.add('ERROR: No valid contact IDs provided');
                return results;
            }
            
            // Query contacts to get phone numbers
            List<Contact> contacts = [
                SELECT Id, Name, MobilePhone, Phone, Email
                FROM Contact 
                WHERE Id IN :contactIdList 
                AND (MobilePhone != null OR Phone != null)
            ];
            
            if (contacts.isEmpty()) {
                results.add('ERROR: No contacts found with phone numbers for provided IDs');
                return results;
            }
            
            // Create SMS requests for GenesysSMSInvoker
            List<GenesysSMSInvoker.SMSRequest> smsRequests = new List<GenesysSMSInvoker.SMSRequest>();
            
            for (Contact contact : contacts) {
                GenesysSMSInvoker.SMSRequest smsRequest = new GenesysSMSInvoker.SMSRequest();
                smsRequest.phoneNumber = String.isNotBlank(contact.MobilePhone) ? contact.MobilePhone : contact.Phone;
                smsRequest.messageContent = messageText;
                smsRequest.fromAddress = fromAddress;
                smsRequest.contactId = contact.Id;
                
                smsRequests.add(smsRequest);
                System.debug('Created SMS request for: ' + contact.Name + ' (' + smsRequest.phoneNumber + ')');
            }
            
            // Send SMS using existing GenesysSMSInvoker
            System.debug('Sending SMS to ' + smsRequests.size() + ' contacts via GenesysSMSInvoker');
            GenesysSMSInvoker.sendSMSFromFlow(smsRequests);
            
            // Return success message
            String successMsg = 'SUCCESS: SMS queued for ' + contacts.size() + ' contacts. Message: "' + messageText + '" From: ' + fromAddress;
            results.add(successMsg);
            System.debug('FlowSMSSender Success: ' + successMsg);
            
        } catch (Exception e) {
            String errorMsg = 'ERROR: ' + e.getMessage();
            results.add(errorMsg);
            System.debug('FlowSMSSender error: ' + errorMsg);
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return results;
    }
}
