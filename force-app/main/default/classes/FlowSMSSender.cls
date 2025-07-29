/**
 * @description Flow SMS sender with string-based parameter passing
 * @author System Administrator  
 * @date 2025-07-28
 * @version 2.0 - Refactored to eliminate static variable workarounds
 * 
 * USAGE FROM FLOW:
 * - Call flowSMSSender() with contextData parameter
 * - Format: "contactId1,contactId2,...|||message|||fromAddress"
 * - Uses triple pipe (|||) delimiters to separate parameters
 * - Returns List<String> with success/error messages
 */
public with sharing class FlowSMSSender {
    
    /**
     * @description Flow-compatible method for SMS sending using string-based parameter passing
     * @param contextData String containing formatted context string
     * @return List<String> Results with success/error messages
     * 
     * PARAMETER FORMAT:
     * contextData = "contactId1,contactId2,...|||messageText|||fromAddress"
     * 
     * EXAMPLE:
     * "003XX000004TMmx,003XX000004TMmy|||Hello from Salesforce!|||+1234567890"
     */
    @InvocableMethod(label='Flow SMS Sender' description='Send SMS to multiple contacts from Flow using string parameters')
    public static List<String> flowSMSSender(List<String> contextData) {
        List<String> results = new List<String>();
        
        try {
            // Validate input
            if (contextData == null || contextData.isEmpty() || String.isBlank(contextData[0])) {
                results.add('ERROR: No contextData provided. Required format: "contactIds|||message|||fromAddress"');
                return results;
            }
            
            // Parse contextData string
            String[] parts = contextData[0].split('\\|\\|\\|');
            if (parts.size() < 3) {
                results.add('ERROR: Invalid contextData format. Required: "contactIds|||message|||fromAddress"');
                return results;
            }
            
            String contactIdsStr = parts[0];
            String messageText = parts[1];
            String fromAddress = parts[2];
            
            // Process contact IDs
            List<String> contactIds = new List<String>();
            if (String.isNotBlank(contactIdsStr)) {
                // Remove trailing comma if present
                if (contactIdsStr.endsWith(',')) {
                    contactIdsStr = contactIdsStr.substring(0, contactIdsStr.length() - 1);
                }
                contactIds = contactIdsStr.split(',');
            }
            
            // Validate required parameters
            if (contactIds == null || contactIds.isEmpty()) {
                results.add('ERROR: No contact IDs provided in contextData');
                return results;
            }
            
            if (String.isBlank(messageText)) {
                results.add('ERROR: No message text provided in contextData');
                return results;
            }
            
            if (String.isBlank(fromAddress)) {
                results.add('ERROR: No from address provided in contextData');
                return results;
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
