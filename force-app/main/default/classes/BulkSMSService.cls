/**
 * @description Queueable class for sending bulk SMS via GenesysSMSInvoker
 * @author System Administrator  
 * @date 2025-07-28
 */
public class BulkSMSService implements Queueable, Database.AllowsCallouts, Finalizer {
    /**
     * @description List of SMS requests to process
     */
    private List<GenesysSMSInvoker.SMSRequest> requests;

    /**
     * @description Constructor that accepts a list of SMS requests
     * @param requests List of SMS requests to be processed
     */
    public BulkSMSService(List<GenesysSMSInvoker.SMSRequest> requests) {
        this.requests = requests;
    }

    /**
     * @description Called asynchronously by the queue to process SMS requests
     * @param context QueueableContext provided by the platform
     */
    public void execute(QueueableContext context) {
        // Add finalizer for error handling
        System.attachFinalizer(this);
        
        // Chunk requests into sublists of 50 to respect callout limits
        Integer chunkSize = 50;
        for (Integer i = 0; i < requests.size(); i += chunkSize) {
            List<GenesysSMSInvoker.SMSRequest> chunk = requests.subList(i, Math.min(requests.size(), i + chunkSize));
            // Send SMS for each chunk
            GenesysSMSInvoker.sendSMS(chunk);
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
            if (jobException != null) {
                // Future enhancement: Log to SMS_Log__c custom object
                // Could also send platform events or notifications here
                // Exception details: jobException.getMessage(), jobException.getStackTraceString()
            }
        }
    }
}
