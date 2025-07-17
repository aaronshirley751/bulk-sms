// BulkSMSService: Queueable class for sending bulk SMS via GenesysSMSInvoker
public class BulkSMSService implements Queueable, Database.AllowsCallouts {
    // List of SMS requests to process
    private List<GenesysSMSInvoker.SMSRequest> requests;

    // Constructor: accepts a list of SMS requests
    public BulkSMSService(List<GenesysSMSInvoker.SMSRequest> requests) {
        this.requests = requests;
    }

    // Called asynchronously by the queue
    public void execute(QueueableContext context) {
        // Chunk requests into sublists of 50 to respect callout limits
        Integer chunkSize = 50;
        for (Integer i = 0; i < requests.size(); i += chunkSize) {
            List<GenesysSMSInvoker.SMSRequest> chunk = requests.subList(i, Math.min(requests.size(), i + chunkSize));
            // Send SMS for each chunk
            GenesysSMSInvoker.sendSMS(chunk);
        }
    }
}
