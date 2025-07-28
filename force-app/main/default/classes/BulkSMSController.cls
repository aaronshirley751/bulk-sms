/**
 * @description Aura-enabled controller for bulk SMS functionality
 * @author System Administrator
 * @date 2025-07-28
 */
public with sharing class BulkSMSController {
    /**
     * @description Sends bulk SMS messages to a list of Contacts (AuraEnabled for LWC)
     * @param recordIds List of Contact Ids to send SMS to
     * @param messageText SMS message content
     * @param fromAddress SMS sender address
     * @return String Status message indicating success or failure
     */
    @AuraEnabled
    public static String sendBulkSMSFromLWC(List<Id> recordIds, String messageText, String fromAddress) {
        return sendBulkSMS(recordIds, messageText, fromAddress);
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
            String finalMessage = req.message;
            
            // If template is specified, render it with merge fields
            if (String.isNotBlank(req.templateName)) {
                try {
                    finalMessage = renderTemplateForContacts(req.templateName, req.contactIds);
                } catch (Exception e) {
                    results.add('Error rendering template: ' + e.getMessage());
                    continue;
                }
            }
            
            // Create bulk SMS request
            BulkSMSRequest bulkRequest = new BulkSMSRequest();
            bulkRequest.recordIds = req.contactIds;
            bulkRequest.messageText = finalMessage;
            bulkRequest.fromAddress = req.fromAddress;
            bulkRequest.templateUsed = req.templateName;
            bulkRequest.campaignId = req.campaignId;
            
            String result = sendBulkSMS(bulkRequest);
            results.add(result);
        }
        
        return results;
    }
    
    /**
     * @description Enhanced sendBulkSMS method with template and campaign tracking
     * @param request BulkSMSRequest containing all SMS parameters
     * @return String Status message indicating success or failure
     */
    public static String sendBulkSMS(BulkSMSRequest request) {
        return processBulkSMSRequest(request);
    }
    
    /**
     * @description Convenience method for basic bulk SMS without template/campaign
     * @param recordIds List of Contact Ids to send SMS to
     * @param messageText SMS message content
     * @param fromAddress SMS sender address
     * @return String Status message indicating success or failure
     */
    public static String sendBulkSMS(List<Id> recordIds, String messageText, String fromAddress) {
        BulkSMSRequest request = new BulkSMSRequest();
        request.recordIds = recordIds;
        request.messageText = messageText;
        request.fromAddress = fromAddress;
        return processBulkSMSRequest(request);
    }
    
    /**
     * @description Processes bulk SMS request with reduced parameter complexity
     * @param request BulkSMSRequest containing all SMS parameters
     * @return String Status message indicating success or failure
     */
    private static String processBulkSMSRequest(BulkSMSRequest request) {
        // 1. Query Contacts by recordIds with security check
        List<Contact> contacts = [
            SELECT Id, Phone, hed__SMS_Opt_Out__c 
            FROM Contact 
            WHERE Id IN :request.recordIds
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
            req.messageContent = request.messageText;
            req.fromAddress    = request.fromAddress;
            req.contactId      = c.Id;
            requests.add(req);
            queued++;
        }

        // 3. Enqueue job if there are requests
        if (!requests.isEmpty()) {
            System.enqueueJob(new BulkSMSService(requests, request.templateUsed, request.campaignId));
        }

        // 4. Return status
        return 'Queued ' + queued + ' messages';
    }
    
    /**
     * @description Wrapper class for bulk SMS request parameters
     */
    public class BulkSMSRequest {
        public List<Id> recordIds;
        public String messageText;
        public String fromAddress;
        public String templateUsed;
        public Id campaignId;
    }
    
    /**
     * @description Renders template for multiple contacts (simplified for bulk sends)
     * @param templateName Template developer name
     * @param contactIds List of contact IDs
     * @return String Rendered template (uses first contact for merge fields)
     */
    private static String renderTemplateForContacts(String templateName, List<Id> contactIds) {
        if (contactIds.isEmpty()) {
            return '';
        }
        
        // For bulk sends, use the first contact's data for merge fields
        SMS_TemplateService.MergeContext ctx = new SMS_TemplateService.MergeContext();
        ctx.contactId = contactIds[0];
        
        return SMS_TemplateService.renderTemplate(templateName, ctx);
    }
    
    /**
     * @description Wrapper class for Flow input parameters
     */
    public class FlowRequest {
        @InvocableVariable(label='Contact IDs' description='List of Contact IDs to send SMS to' required=true)
        public List<Id> contactIds;
        
        @InvocableVariable(label='SMS Message' description='The SMS message content' required=false)
        public String message;
        
        @InvocableVariable(label='From Address' description='SMS sender address' required=false)
        public String fromAddress;
        
        @InvocableVariable(label='Template Name' description='SMS template developer name to use' required=false)
        public String templateName;
        
        @InvocableVariable(label='Campaign ID' description='Campaign ID for tracking' required=false)
        public Id campaignId;
    }
}
