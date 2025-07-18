// BulkSMSService: Queueable class for sending bulk SMS via GenesysSMSInvoker
public class BulkSMSService implements Queueable, Database.AllowsCallouts {
    private List<GenesysSMSInvoker.SMSRequest> requests;

    /** Constructor: accepts a list of SMS requests */
    public BulkSMSService(List<GenesysSMSInvoker.SMSRequest> requests) {
        this.requests = requests;
    }

    /** Called asynchronously by the queue */
    public void execute(QueueableContext context) {
        Integer chunkSize = 50;
        if (requests.size() <= chunkSize) {
            // If within one chunk, send directly
            GenesysSMSInvoker.sendSMS(requests);
        } else {
            // Send the first chunk of 50
            List<GenesysSMSInvoker.SMSRequest> chunk = new List<GenesysSMSInvoker.SMSRequest>();
            for (Integer j = 0; j < chunkSize; j++) {
                chunk.add(requests[j]);
            }
            GenesysSMSInvoker.sendSMS(chunk);
            // Prepare remaining requests
            List<GenesysSMSInvoker.SMSRequest> remaining = new List<GenesysSMSInvoker.SMSRequest>();
            for (Integer k = chunkSize; k < requests.size(); k++) {
                remaining.add(requests[k]);
            }
            // Chain the next queueable for the remaining messages
            System.enqueueJob(new BulkSMSService(remaining));
        }
    }
}
