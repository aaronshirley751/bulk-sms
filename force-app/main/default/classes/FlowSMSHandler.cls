/**
 * @description Simple Flow-compatible SMS handler for bulk SMS functionality
 * @author System Administrator
 * @date 2025-07-28
 */
public with sharing class FlowSMSHandler {
    
    /**
     * @description Simple invocable method for Flow integration
     */
    @InvocableMethod(label='Send Bulk SMS' description='Sends SMS to multiple contacts from Flow')
    public static void sendBulkSMS(List<SMSRequest> requests) {
        for (SMSRequest request : requests) {
            try {
                // Convert String IDs to proper Id list
                List<Id> contactIdList = new List<Id>();
                for (String contactId : request.contactIds) {
                    if (String.isNotBlank(contactId)) {
                        contactIdList.add((Id)contactId);
                    }
                }
                
                // Call the existing BulkSMSController logic
                BulkSMSController.sendBulkSMS(contactIdList, request.message, request.fromAddress);
                
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'FlowSMSHandler error: ' + e.getMessage());
                // Let the error bubble up to Flow for handling
                throw e;
            }
        }
    }
    
    /**
     * @description Request wrapper for Flow input
     */
    public class SMSRequest {
        @InvocableVariable(label='Contact IDs' required=true)
        public List<String> contactIds;
        
        @InvocableVariable(label='Message' required=true)
        public String message;
        
        @InvocableVariable(label='From Address' required=true)
        public String fromAddress;
    }
}
