// BulkSMSController: Aura-enabled controller for bulk SMS
public with sharing class BulkSMSController {
    /**
     * Sends bulk SMS messages to a list of Contacts.
     * @param recordIds   List of Contact Ids
     * @param messageText SMS message content
     * @param fromAddress SMS sender address
     * @return Status message
     */
    @AuraEnabled
    public static String sendBulkSMS(List<Id> recordIds, String messageText, String fromAddress) {
        // 1. Query Contacts by recordIds
        List<Contact> contacts = [
            SELECT Id, Phone, hed__SMS_Opt_Out__c 
            FROM Contact 
            WHERE Id IN :recordIds
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
     * Returns picklist options for active SMS templates.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getTemplateOptions() {
        List<Map<String,String>> options = new List<Map<String,String>>();
        List<SMS_Template__mdt> templates = [
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
     * Invocable method for Flow integration
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
     * Wrapper class for Flow input parameters
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
