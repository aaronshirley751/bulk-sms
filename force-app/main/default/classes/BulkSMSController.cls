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
     * Invocable method for Flow integration.
     * 
     * This method serves as the entry point for Salesforce Flows to trigger bulk SMS operations.
     * It processes a list of FlowRequest objects containing the necessary parameters for sending
     * bulk SMS messages to multiple contacts.
     * 
     * @param requests List<FlowRequest> List of Flow requests containing SMS parameters
     * @return List<String> List of result messages indicating success/failure for each request
     */
    @InvocableMethod(label='Send Bulk SMS' description='Sends SMS to multiple contacts')
    public static List<String> sendBulkSMSFromFlow(List<FlowRequest> requests) {
        List<String> results = new List<String>();
        
        for (FlowRequest req : requests) {
            try {
                // Convert String record IDs to proper Id format
                List<Id> contactIds = new List<Id>();
                if (req.getRecordIds() != null) {
                    for (String recordId : req.getRecordIds()) {
                        if (String.isNotBlank(recordId)) {
                            contactIds.add(Id.valueOf(recordId));
                        }
                    }
                }
                
                // Call the main bulk SMS method
                String result = sendBulkSMS(contactIds, req.getMessage(), req.getFromAddress());
                results.add(result);
                
            } catch (Exception e) {
                results.add('Error processing request: ' + e.getMessage());
            }
        }
        
        return results;
    }
    
    /**
     * FlowRequest class for handling Flow input parameters in bulk SMS operations.
     * 
     * This class serves as a wrapper for parameters passed from Salesforce Flows
     * to the bulk SMS invocable method. It contains all necessary data for processing
     * bulk SMS requests including selected record IDs, message content, and sender information.
     * 
     * @author Generated
     * @since API Version 58.0
     */
    public class FlowRequest {
        
        /** Selected Contact IDs for bulk SMS processing */
        @InvocableVariable(label='Selected Contact IDs' description='Selected Contact IDs' required=true)
        public List<String> recordIds;
        
        /** SMS message text content */
        @InvocableVariable(label='SMS Message' description='SMS text' required=true)
        public String message;
        
        /** Optional sender phone number */
        @InvocableVariable(label='From Address' description='Sender number' required=false)
        public String fromAddress;
        
        /**
         * Default no-args constructor.
         * Initializes a new FlowRequest instance with default values.
         */
        public FlowRequest() {
            this.recordIds = new List<String>();
            this.message = '';
            this.fromAddress = '';
        }
        
        /**
         * Gets the list of selected Contact record IDs.
         * @return List<String> The Contact IDs selected for bulk SMS
         */
        public List<String> getRecordIds() {
            return this.recordIds;
        }
        
        /**
         * Sets the list of selected Contact record IDs.
         * @param recordIds List<String> The Contact IDs to set
         */
        public void setRecordIds(List<String> recordIds) {
            this.recordIds = recordIds != null ? recordIds : new List<String>();
        }
        
        /**
         * Gets the SMS message text content.
         * @return String The SMS message content
         */
        public String getMessage() {
            return this.message;
        }
        
        /**
         * Sets the SMS message text content.
         * @param message String The SMS message to set
         */
        public void setMessage(String message) {
            this.message = message != null ? message : '';
        }
        
        /**
         * Gets the sender phone number or address.
         * @return String The sender phone number
         */
        public String getFromAddress() {
            return this.fromAddress;
        }
        
        /**
         * Sets the sender phone number or address.
         * @param fromAddress String The sender number to set
         */
        public void setFromAddress(String fromAddress) {
            this.fromAddress = fromAddress != null ? fromAddress : '';
        }
        
        /**
         * Returns a string representation of the FlowRequest object.
         * @return String A formatted string containing the FlowRequest details
         */
        public override String toString() {
            return 'FlowRequest{' +
                'recordIds=' + (recordIds != null ? recordIds.size() + ' records' : 'null') +
                ', message=' + (String.isNotBlank(message) ? '\'' + message + '\'' : 'null') +
                ', fromAddress=' + (String.isNotBlank(fromAddress) ? '\'' + fromAddress + '\'' : 'null') +
                '}';
        }
    }
}
