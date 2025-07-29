/**
 * @description Ultra-simple Flow-compatible SMS handler
 * @author System Administrator
 * @date 2025-07-28
 */
public with sharing class SimpleBulkSMS {
    
    /**
     * @description Simple Flow-compatible method with basic parameters
     */
    @InvocableMethod(label='Send Bulk SMS Simple' description='Simple bulk SMS for Flow')
    public static List<String> sendSMS(List<FlowInputs> inputs) {
        List<String> results = new List<String>();
        
        for (FlowInputs input : inputs) {
            try {
                // Convert String IDs to Id list
                List<Id> contactIds = new List<Id>();
                for (String idStr : input.contactIds) {
                    if (String.isNotBlank(idStr)) {
                        contactIds.add((Id)idStr);
                    }
                }
                
                // Call BulkSMSController
                String result = BulkSMSController.sendBulkSMS(contactIds, input.message, input.fromAddress);
                results.add(result);
                
            } catch (Exception e) {
                results.add('Error: ' + e.getMessage());
            }
        }
        
        return results;
    }
    
    // Top-level class for Flow compatibility
    public class FlowInputs {
        @InvocableVariable(label='Contact IDs' required=true)
        public List<String> contactIds;
        
        @InvocableVariable(label='Message Text' required=true)
        public String message;
        
        @InvocableVariable(label='From Address' required=true)
        public String fromAddress;
    }
}
