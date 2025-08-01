/**
 * @description FlowSMSSender - Simplified Flow-compatible SMS sender using string parameters
 * Provides a single invocable method for sending SMS from Salesforce Flows
 * Uses string concatenation for input to work around Flow limitations
 *
 * @author System Administrator
 * @version 1.2
 * @since 2024
 */
public with sharing class FlowSMSSender {

    /**
     * @description Invocable method to send SMS from Flow using string parameters
     * Input format: "contactIds|||message|||fromAddress"
     * Example: "003XX000001,003XX000002|||Hello World|||+15551234567"
     *
     * @param contextData List of strings with SMS parameters
     * @return List<String> Success or error messages
     */
    @InvocableMethod(label='Flow SMS Sender' description='Send SMS to multiple contacts from Flow using string parameters')
    public static List<String> sendSMSFromFlow(List<String> contextData) {
        List<String> results = new List<String>();

        try {
            // Validate and parse input
            SMSParameters params = parseContextData(contextData);
            if (params.hasError) {
                results.add(params.errorMessage);
                return results;
            }

            // Process contacts and send SMS
            List<Contact> contacts = getContactsWithPhones(params.contactIds);
            if (contacts.isEmpty()) {
                results.add('ERROR: No contacts found with phone numbers for provided IDs');
                return results;
            }

            // Send SMS messages
            sendSMSToContacts(contacts, params.messageText, params.fromAddress);

            // Return success message
            String successMsg = 'SUCCESS: SMS queued for ' + contacts.size() + ' contacts. Message: "' + params.messageText + '" From: ' + params.fromAddress;
            results.add(successMsg);
            System.debug(LoggingLevel.INFO, 'FlowSMSSender Success: ' + successMsg);

        } catch (Exception e) {
            String errorMsg = 'ERROR: ' + e.getMessage();
            results.add(errorMsg);
            System.debug(LoggingLevel.ERROR, 'FlowSMSSender error: ' + errorMsg);
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }

        return results;
    }

    /**
     * @description Parse and validate context data from Flow
     * @param contextData Input data from Flow
     * @return SMSParameters Parsed parameters with validation status
     */
    private static SMSParameters parseContextData(List<String> contextData) {
        SMSParameters params = new SMSParameters();

        // Validate input
        if (contextData == null || contextData.isEmpty() || String.isBlank(contextData[0])) {
            params.hasError = true;
            params.errorMessage = 'ERROR: No contextData provided. Required format: "contactIds|||message|||fromAddress"';
            return params;
        }

        // Parse contextData string
        String[] parts = contextData[0].split('\\|\\|\\|');
        if (parts.size() < 3) {
            params.hasError = true;
            params.errorMessage = 'ERROR: Invalid contextData format. Required: "contactIds|||message|||fromAddress"';
            return params;
        }

        String contactIdsStr = parts[0];
        params.messageText = parts[1];
        params.fromAddress = parts[2];

        // Process contact IDs
        params.contactIds = parseContactIds(contactIdsStr);

        // Validate required parameters
        if (params.contactIds.isEmpty()) {
            params.hasError = true;
            params.errorMessage = 'ERROR: No valid contact IDs provided';
            return params;
        }

        if (String.isBlank(params.messageText)) {
            params.hasError = true;
            params.errorMessage = 'ERROR: No message text provided in contextData';
            return params;
        }

        if (String.isBlank(params.fromAddress)) {
            params.hasError = true;
            params.errorMessage = 'ERROR: No from address provided in contextData';
            return params;
        }

        return params;
    }

    /**
     * @description Parse contact IDs from string format
     * @param contactIdsStr Comma-separated contact IDs
     * @return List<Id> Valid contact IDs
     */
    private static List<Id> parseContactIds(String contactIdsStr) {
        List<Id> contactIdList = new List<Id>();

        if (String.isBlank(contactIdsStr)) {
            return contactIdList;
        }

        // Remove trailing comma if present
        if (contactIdsStr.endsWith(',')) {
            contactIdsStr = contactIdsStr.substring(0, contactIdsStr.length() - 1);
        }

        List<String> contactIds = contactIdsStr.split(',');

        for (String idStr : contactIds) {
            try {
                if (String.isNotBlank(idStr.trim())) {
                    contactIdList.add((Id)idStr.trim());
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, 'Invalid contact ID: ' + idStr + ', Error: ' + e.getMessage());
            }
        }

        return contactIdList;
    }

    /**
     * @description Query contacts with phone numbers
     * @param contactIds List of contact IDs to query
     * @return List<Contact> Contacts with phone numbers
     */
    private static List<Contact> getContactsWithPhones(List<Id> contactIds) {
        return [
            SELECT Id, Name, MobilePhone, Phone, Email
            FROM Contact
            WHERE Id IN :contactIds
            AND (MobilePhone != null OR Phone != null)
            WITH USER_MODE
        ];
    }

    /**
     * @description Send SMS to list of contacts
     * @param contacts Contacts to send SMS to
     * @param messageText SMS message content
     * @param fromAddress SMS from address
     */
    private static void sendSMSToContacts(List<Contact> contacts, String messageText, String fromAddress) {
        List<GenesysSMSInvoker.SMSRequest> smsRequests = new List<GenesysSMSInvoker.SMSRequest>();

        for (Contact contact : contacts) {
            GenesysSMSInvoker.SMSRequest smsRequest = new GenesysSMSInvoker.SMSRequest();
            smsRequest.phoneNumber = String.isNotBlank(contact.MobilePhone) ? contact.MobilePhone : contact.Phone;
            smsRequest.messageContent = messageText;
            smsRequest.fromAddress = fromAddress;
            smsRequest.contactId = contact.Id;

            smsRequests.add(smsRequest);
            System.debug(LoggingLevel.DEBUG, 'Created SMS request for: ' + contact.Name + ' (' + smsRequest.phoneNumber + ')');
        }

        // Send SMS using existing GenesysSMSInvoker
        System.debug(LoggingLevel.INFO, 'Sending SMS to ' + smsRequests.size() + ' contacts via GenesysSMSInvoker');
        GenesysSMSInvoker.sendSMSFromFlow(smsRequests);
    }

    /**
     * @description Internal class to hold parsed SMS parameters
     */
    private class SMSParameters {
        public List<Id> contactIds;
        public String messageText;
        public String fromAddress;
        public Boolean hasError = false;
        public String errorMessage;

        /**
         * @description Constructor for SMSParameters
         */
        public SMSParameters() {
            this.contactIds = new List<Id>();
        }
    }
}
