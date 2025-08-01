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
     * @return List<String> Results with success/error messages
     */
    @InvocableMethod(label='Send Bulk SMS Enhanced' description='Enhanced bulk SMS sending for Flow integration')
    public static List<String> sendBulkSMS(List<SMSRequest> requests) {
        List<String> results = new List<String>();

        try {
            // Validate input
            SMSRequest request = validateInput(requests);
            if (request == null) {
                results.add('ERROR: No SMS requests provided');
                return results;
            }

            // Validate request fields
            String validationError = validateRequestFields(request);
            if (validationError != null) {
                results.add(validationError);
                return results;
            }

            // Convert and validate contact IDs
            List<Id> contactIds = convertContactIds(request.contactIds);
            if (contactIds.isEmpty()) {
                results.add('ERROR: No valid contact IDs provided');
                return results;
            }

            // Send SMS using BulkSMSController
            String result = BulkSMSController.sendBulkSMS(contactIds, request.messageText, request.fromAddress);
            results.add(result);

        } catch (Exception e) {
            results.add('ERROR: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'FlowBulkSMS error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }

        return results;
    }

    /**
     * @description Validate input requests
     * @param requests List of SMS requests
     * @return SMSRequest First valid request or null
     */
    private static SMSRequest validateInput(List<SMSRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return null;
        }
        return requests[0]; // Take first request
    }

    /**
     * @description Validate request fields
     * @param request SMS request to validate
     * @return String Error message or null if valid
     */
    private static String validateRequestFields(SMSRequest request) {
        if (request.contactIds == null || request.contactIds.isEmpty()) {
            return 'ERROR: No contact IDs provided';
        }

        if (String.isBlank(request.messageText)) {
            return 'ERROR: Message text is required';
        }

        if (String.isBlank(request.fromAddress)) {
            return 'ERROR: From address is required';
        }

        return null; // No validation errors
    }

    /**
     * @description Convert string IDs to Id list
     * @param contactIdStrings List of contact ID strings
     * @return List<Id> Valid contact IDs
     */
    private static List<Id> convertContactIds(List<String> contactIdStrings) {
        List<Id> contactIds = new List<Id>();

        for (String idStr : contactIdStrings) {
            try {
                contactIds.add((Id)idStr);
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, 'Invalid contact ID: ' + idStr);
            }
        }

        return contactIds;
    }
}
