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
        for (Integer i = 0; i < requests.size(); i += chunkSize) {
            // *** Must assign the subList result to a variable ***
            List<GenesysSMSInvoker.SMSRequest> chunk =
                requests.subList(
                    i,
                    Math.min(requests.size(), i + chunkSize)
                );
            GenesysSMSInvoker.sendSMS(chunk);
        }
    }
}
