/**
 * @description Aura-enabled controller for bulk SMS functionality
 * @author System Administrator
 * @date 2025-07-28
 */
public with sharing class BulkSMSController {
    /**
     * @description Sends bulk SMS messages to a list of Contacts
     * @param recordIds List of Contact Ids to send SMS to
     * @param messageText SMS message content
     * @param fromAddress SMS sender address
     * @return String Status message indicating success or failure
     */
    @AuraEnabled
    public static String sendBulkSMS(List<Id> recordIds, String messageText, String fromAddress) {
        // 1. Query Contacts by recordIds with security check
        List<Contact> contacts = [
            SELECT Id, Phone, hed__SMS_Opt_Out__c 
            FROM Contact 
            WHERE Id IN :recordIds
            WITH USER_MODE
        ];
        List<GenesysSMSInvoker.SMSRequest> requests = new List<GenesysSMSInvoker.SMSRequest>();
        Integer queued = 0;

        // 2. Filter out null/opted-out and build requests
        for (Contact c : contacts) {
            if (String.isBlank(c.Phone) || c.hed__SMS_Opt_Out__c) {
                continue;
            }
            GenesysSMSInvoker.SMSRequest req = new GenesysSMSInvoker.SMSRequest();
            req.phoneNumber    = c.Phone;
            req.messageContent = messageText;
            req.fromAddress    = fromAddress;
            req.contactId      = c.Id;
            requests.add(req);
            queued++;
        }

        // 3. Enqueue job if there are requests
        if (!requests.isEmpty()) {
            System.enqueueJob(new BulkSMSService(requests));
        }

        // 4. Return status
        return 'Queued ' + queued + ' messages';
    }
    
    /**
     * @description Returns picklist options for active SMS templates
     * @return List<Map<String,String>> List of template options with label and value
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getTemplateOptions() {
        List<Map<String,String>> options = new List<Map<String,String>>();
        // Custom metadata queries don't require security enforcement as they're always accessible
        // PMD suppression: Custom metadata is secure by design and accessible to all users
        List<SMS_Template__mdt> templates = [ //NOPMD ApexCRUDViolation
            SELECT MasterLabel, DeveloperName
            FROM SMS_Template__mdt
            WHERE IsActive__c = true
            ORDER BY MasterLabel
        ];
        for (SMS_Template__mdt tmpl : templates) {
            options.add(new Map<String,String>{
                'label' => tmpl.MasterLabel,
                'value' => tmpl.DeveloperName
            });
        }
        return options;
    }
    
    /**
     * @description Invocable method for Flow integration to send bulk SMS
     * @param requests List of FlowRequest objects containing SMS details
     * @return List<String> List of status messages for each request
     */
    @InvocableMethod(label='Send Bulk SMS' description='Sends SMS to multiple contacts')
    public static List<String> sendBulkSMSFromFlow(List<FlowRequest> requests) {
        List<String> results = new List<String>();
        
        for (FlowRequest req : requests) {
            String result = sendBulkSMS(req.contactIds, req.message, req.fromAddress);
            results.add(result);
        }
        
        return results;
    }
    
    /**
     * @description Wrapper class for Flow input parameters
     */
    public class FlowRequest {
        @InvocableVariable(label='Contact IDs' description='List of Contact IDs to send SMS to' required=true)
        public List<Id> contactIds;
        
        @InvocableVariable(label='SMS Message' description='The SMS message content' required=true)
        public String message;
        
        @InvocableVariable(label='From Address' description='SMS sender address' required=false)
        public String fromAddress;
    }
}
