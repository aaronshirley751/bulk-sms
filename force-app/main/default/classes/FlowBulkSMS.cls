/**
 * @description Enhanced Flow-compatible bulk SMS handler using proven approach
 * @author System Administrator
 * @date 2025-07-28
 */
public with sharing class FlowBulkSMS {
    
    /**
     * @description Flow input wrapper using top-level class for better compatibility
     */
    public class SMSRequest {
        @InvocableVariable(label='Contact IDs' description='List of Contact IDs to send SMS to' required=true)
        public List<String> contactIds;
        
        @InvocableVariable(label='Message Text' description='SMS message content' required=true)
        public String messageText;
        
        @InvocableVariable(label='From Phone Number' description='SMS sender phone number' required=true)
        public String fromAddress;
    }
    
    /**
     * @description Flow-callable method to send bulk SMS
     * @param requests List of SMS requests from Flow
     */
    @InvocableMethod(label='Send Bulk SMS Enhanced' description='Enhanced bulk SMS sending for Flow integration')
    public static List<String> sendBulkSMS(List<SMSRequest> requests) {
        List<String> results = new List<String>();
        
        try {
            if (requests == null || requests.isEmpty()) {
                results.add('ERROR: No SMS requests provided');
                return results;
            }
            
            SMSRequest request = requests[0]; // Take first request
            
            // Validate inputs
            if (request.contactIds == null || request.contactIds.isEmpty()) {
                results.add('ERROR: No contact IDs provided');
                return results;
            }
            
            if (String.isBlank(request.messageText)) {
                results.add('ERROR: Message text is required');
                return results;
            }
            
            if (String.isBlank(request.fromAddress)) {
                results.add('ERROR: From address is required');
                return results;
            }
            
            // Convert String IDs to Id list for BulkSMSController
            List<Id> contactIds = new List<Id>();
            for (String idStr : request.contactIds) {
                try {
                    contactIds.add((Id)idStr);
                } catch (Exception e) {
                    System.debug('Invalid contact ID: ' + idStr);
                }
            }
            
            if (contactIds.isEmpty()) {
                results.add('ERROR: No valid contact IDs provided');
                return results;
            }
            
            // Use existing BulkSMSController for actual SMS sending
            String result = BulkSMSController.sendBulkSMS(contactIds, request.messageText, request.fromAddress);
            results.add(result);
            
        } catch (Exception e) {
            results.add('ERROR: ' + e.getMessage());
            System.debug('FlowBulkSMS error: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return results;
    }
}
