/**
 * @description Service class for invoking Genesys Cloud SMS API
 * @author System Administrator
 * @date 2025-07-28
 */
public with sharing class GenesysSMSInvoker {
    
    private static final String NAMED_CREDENTIAL = 'callout:Genesys_Cloud_SMS';
    
    /**
     * @description Wrapper class for SMS request data
     */
    public class SMSRequest {
        public String phoneNumber;
        public String message;
        public String fromAddress;
        public Id contactId;
        public String messageContent; // For compatibility with BulkSMSService
    }
    
    /**
     * @description Response wrapper for Genesys SMS API
     */
    public class SMSResponse {
        public Boolean success;
        public String messageId;
        public String error;
        public String status;
    }
    
    /**
     * @description Gets active Genesys configuration
     * @return Genesys_SMS_Configuration__mdt record
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static Genesys_SMS_Configuration__mdt getConfiguration() {
        // Custom Metadata Types don't require CRUD checks as they're configuration data
        List<Genesys_SMS_Configuration__mdt> configs = [
            SELECT API_Region__c, SMS_From_Address__c, Organization_ID__c 
            FROM Genesys_SMS_Configuration__mdt 
            WHERE Is_Active__c = true 
            LIMIT 1
        ];
        
        if (configs.isEmpty()) {
            throw new SMSException('No active Genesys SMS configuration found');
        }
        
        return configs[0];
    }
    
    /**
     * @description Sends SMS message via Genesys Cloud API
     * @param phoneNumber The recipient phone number
     * @param message The SMS message content
     * @return Boolean indicating success or failure
     */
    public static Boolean sendSMS(String phoneNumber, String message) {
        SMSResponse response = sendSMSWithResponse(phoneNumber, message);
        return response.success;
    }
    
    /**
     * @description Sends SMS message via Genesys Cloud API with detailed response
     * @param phoneNumber The recipient phone number
     * @param message The SMS message content
     * @return SMSResponse with detailed result information
     */
    public static SMSResponse sendSMSWithResponse(String phoneNumber, String message) {
        SMSResponse result = new SMSResponse();
        result.success = false;
        
        try {
            if (!isValidPhoneNumber(phoneNumber)) {
                result.error = 'Invalid phone number format: ' + phoneNumber;
                return result;
            }
            
            if (String.isBlank(message)) {
                result.error = 'Message content cannot be empty';
                return result;
            }
            
            Genesys_SMS_Configuration__mdt config = getConfiguration();
            
            // Build Genesys Cloud SMS API request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(NAMED_CREDENTIAL + '/api/v2/conversations/messages');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            
            // Genesys Cloud SMS API payload structure
            Map<String, Object> payload = new Map<String, Object>{
                'fromAddress' => config.SMS_From_Address__c,
                'toAddress' => formatPhoneNumber(phoneNumber),
                'textBody' => message,
                'messageType' => 'sms'
            };
            
            req.setBody(JSON.serialize(payload));
            req.setTimeout(30000); // 30 second timeout
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                // Parse successful response
                Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                result.success = true;
                result.messageId = (String)responseData.get('id');
                result.status = (String)responseData.get('messageStatus');
            } else {
                // Handle API errors
                result.error = 'Genesys API Error: ' + res.getStatusCode() + ' - ' + res.getBody();
                System.debug(LoggingLevel.ERROR, 'Genesys SMS API Error: ' + res.getStatusCode() + ' Body: ' + res.getBody());
            }
            
        } catch (Exception e) {
            result.error = 'SMS sending failed: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'GenesysSMSInvoker error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    /**
     * @description Validates phone number format
     * @param phoneNumber The phone number to validate
     * @return Boolean indicating if phone number is valid
     */
    public static Boolean isValidPhoneNumber(String phoneNumber) {
        if (String.isBlank(phoneNumber)) {
            return false;
        }
        
        // Enhanced phone number validation
        String cleanPhone = phoneNumber.replaceAll('[^0-9+]', '');
        
        // Must start with + for international format or be 10+ digits
        if (cleanPhone.startsWith('+')) {
            return cleanPhone.length() >= 11 && cleanPhone.length() <= 15;
        } else {
            return cleanPhone.length() >= 10 && cleanPhone.length() <= 11;
        }
    }
    
    /**
     * @description Formats phone number for Genesys API
     * @param phoneNumber Raw phone number
     * @return Formatted phone number
     */
    private static String formatPhoneNumber(String phoneNumber) {
        String cleaned = phoneNumber.replaceAll('[^0-9+]', '');
        
        // Ensure international format with +
        if (!cleaned.startsWith('+')) {
            // Assume US number if no country code
            if (cleaned.length() == 10) {
                cleaned = '+1' + cleaned;
            } else if (cleaned.length() == 11 && cleaned.startsWith('1')) {
                cleaned = '+' + cleaned;
            }
        }
        
        return cleaned;
    }
    
    
    /**
     * @description Sends bulk SMS messages via Genesys API
     * @param requests List of SMS requests to process
     * @return Boolean indicating overall success
     */
    public static Boolean sendSMS(List<SMSRequest> requests) {
        Boolean overallSuccess = true;
        
        for (SMSRequest request : requests) {
            String phoneToUse = request.phoneNumber;
            String messageToUse = String.isNotBlank(request.messageContent) ? request.messageContent : request.message;
            
            if (isValidPhoneNumber(phoneToUse)) {
                SMSResponse response = sendSMSWithResponse(phoneToUse, messageToUse);
                if (!response.success) {
                    overallSuccess = false;
                    System.debug(LoggingLevel.WARN, 'SMS failed for ' + phoneToUse + ': ' + response.error);
                }
            } else {
                System.debug(LoggingLevel.WARN, 'Invalid phone number: ' + phoneToUse);
                overallSuccess = false;
            }
        }
        
        return overallSuccess;
    }
    
    /**
     * @description Custom exception for SMS operations
     */
    public class SMSException extends Exception {}
}
