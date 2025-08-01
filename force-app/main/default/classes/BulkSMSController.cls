/**
 * @description Aura-enabled controller for bulk SMS functionality
 * @author System Administrator
 * @date 2025-07-29
 * @version 3.0 - Cleaned up deprecated Flow patterns and inner classes
 *
 * FLOW INTEGRATION GUIDELINES:
 * - For Flow integration, use FlowSMSSender.flowSMSSender() with pipe-delimited contextData parameter
 * - Context Data Format: "contactId1,contactId2,...|||UseTemplate?TemplateName:MessageText|||fromAddress"
 * - Template Format: "contact1,contact2|||true?Welcome_Template:|||+1234567890"
 * - Custom Format: "contact1,contact2|||false?:Your custom message|||+1234567890"
 * - This controller provides LWC integration and utility methods for SMS processing
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
     * ARCHITECTURE NOTES:
     * - FlowRequest inner class was removed due to Salesforce Flow constraints with custom types
     * - sendBulkSMSFromFlow() method was removed as it cannot be reliably called from Flow
     * - For Flow integration, use FlowSMSSender.flowSMSSender() with string-based contextData
     * - This approach ensures compatibility with Flow variable type restrictions
     */
}
