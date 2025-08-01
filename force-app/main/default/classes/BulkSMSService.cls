/**
 * @description Queueable class for sending bulk SMS via GenesysSMSInvoker with comprehensive logging
 * @author System Administrator
 * @date 2025-07-28
 */
public class BulkSMSService implements Queueable, Database.AllowsCallouts, Finalizer {
    /**
     * @description List of SMS requests to process
     */
    private List<GenesysSMSInvoker.SMSRequest> requests;

    /**
     * @description Template name used for this batch (if applicable)
     */
    private String templateUsed;

    /**
     * @description Campaign ID for tracking (if applicable)
     */
    private Id campaignId;

    /**
     * @description SMS Log record ID for batch tracking
     */
    private Id smsLogId;

    /**
     * @description Constructor that accepts a list of SMS requests
     * @param requests List of SMS requests to be processed
     */
    public BulkSMSService(List<GenesysSMSInvoker.SMSRequest> requests) {
        this.requests = requests;
        this.templateUsed = null;
        this.campaignId = null;
        this.smsLogId = null;
    }

    /**
     * @description Constructor with template and campaign tracking
     * @param requests List of SMS requests to be processed
     * @param templateUsed Template name/ID used for this batch
     * @param campaignId Campaign ID for tracking
     */
    public BulkSMSService(List<GenesysSMSInvoker.SMSRequest> requests, String templateUsed, Id campaignId) {
        this.requests = requests;
        this.templateUsed = templateUsed;
        this.campaignId = campaignId;
        this.smsLogId = null;
    }

    /**
     * @description Called asynchronously by the queue to process SMS requests
     * @param context QueueableContext provided by the platform
     */
    public void execute(QueueableContext context) {
        // Add finalizer for error handling
        System.attachFinalizer(this);

        // Create SMS Log record for this batch
        this.smsLogId = createSMSLogRecord();

        Integer sentCount = 0;
        Integer failedCount = 0;
        List<SMS_History__c> historyRecords = new List<SMS_History__c>();

        // Chunk requests into sublists of 50 to respect callout limits
        Integer chunkSize = 50;
        for (Integer i = 0; i < requests.size(); i += chunkSize) {
            Integer endIndex = Math.min(requests.size(), i + chunkSize);
            List<GenesysSMSInvoker.SMSRequest> chunk = new List<GenesysSMSInvoker.SMSRequest>();
            for (Integer j = i; j < endIndex; j++) {
                chunk.add(requests[j]);
            }

            // Process each SMS in the chunk
            for (GenesysSMSInvoker.SMSRequest request : chunk) {
                GenesysSMSInvoker.SMSResponse response = GenesysSMSInvoker.sendSMSWithResponse(
                    request.phoneNumber,
                    request.messageContent
                );

                // Create SMS History record with enhanced details
                SMS_History__c history = createSMSHistoryRecord(request, response);
                historyRecords.add(history);

                if (response.success) {
                    sentCount++;
                } else {
                    failedCount++;
                    System.debug(LoggingLevel.ERROR, 'SMS failed for ' + request.phoneNumber + ': ' + response.error);
                }
            }
        }

        // Insert all SMS History records
        if (!historyRecords.isEmpty()) {
            try {
                insert historyRecords;
            } catch (Exception e) { //NOPMD EmptyCatchBlock
                // History logging failed but SMS processing succeeded
                // In production, could log to Platform Events for retry mechanism
                // Continue processing without failing the batch
            }
        }

        // Update SMS Log record with final counts
        updateSMSLogRecord(sentCount, failedCount);
    }

    /**
     * @description Creates an SMS Log record for batch tracking
     * @return Id The SMS Log record ID
     */
    private Id createSMSLogRecord() {
        SMS_Log__c logRecord = new SMS_Log__c(
            Total_Records__c = requests.size(),
            Sent_Count__c = 0,
            Failed_Count__c = 0,
            Template_Used__c = this.templateUsed,
            Campaign__c = this.campaignId,
            User__c = UserInfo.getUserId(),
            Send_Timestamp__c = System.now()
        );

        try {
            insert logRecord;
            return logRecord.Id;
        } catch (Exception e) { //NOPMD EmptyCatchBlock
            // Log creation failed - continue with SMS processing but without logging
            // In production, could log to Platform Events or send notification
            return null;
        }
    }

    /**
     * @description Creates an SMS History record for individual SMS tracking
     * @param request The SMS request
     * @param response The API response with detailed information
     * @return SMS_History__c The history record
     */
    private SMS_History__c createSMSHistoryRecord(GenesysSMSInvoker.SMSRequest request, GenesysSMSInvoker.SMSResponse response) {
        SMS_History__c history = new SMS_History__c(
            Contact__c = request.contactId,
            Message_Text__c = request.messageContent,
            Template_Used__c = this.templateUsed,
            Status__c = response.success ? 'Sent' : 'Failed',
            Sent_Timestamp__c = System.now(),
            Campaign__c = this.campaignId
        );

        if (response.success) {
            history.Response__c = 'Message ID: ' + response.messageId +
                (String.isNotBlank(response.status) ? ', Status: ' + response.status : '');
        } else {
            history.Error__c = response.error;
        }

        return history;
    }

    /**
     * @description Updates the SMS Log record with final counts
     * @param sentCount Number of successfully sent SMS
     * @param failedCount Number of failed SMS
     */
    private void updateSMSLogRecord(Integer sentCount, Integer failedCount) {
        if (this.smsLogId == null) {
            // No SMS Log record was created, skip update
            return;
        }

        SMS_Log__c logRecord = new SMS_Log__c(
            Id = this.smsLogId,
            Sent_Count__c = sentCount,
            Failed_Count__c = failedCount
        );

        try {
            update logRecord;
        } catch (Exception e) { //NOPMD EmptyCatchBlock
            // Log update failed - batch processing succeeded but metrics not updated
            // In production, could send notification or log to Platform Events
        }
    }

    /**
     * @description Finalizer method to handle job completion or failure
     * @param context FinalizerContext provided by the platform
     */
    public void execute(FinalizerContext context) {
        if (context.getResult() == ParentJobResult.UNHANDLED_EXCEPTION) {
            // Log to custom object or send notification in production
            Exception jobException = context.getException();
            if (jobException != null) { //NOPMD EmptyIfStmt
                // Future enhancement: Log to SMS_Log__c custom object
                // Could also send platform events or notifications here
                // Exception details available: jobException.getMessage(), jobException.getStackTraceString()
            }
        }
    }
}
