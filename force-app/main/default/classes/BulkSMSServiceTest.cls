@isTest
public class BulkSMSServiceTest {
    @isTest
    static void testEnqueueAndChunking() {
        // Create a dummy SMSRequest
        GenesysSMSInvoker.SMSRequest req = new GenesysSMSInvoker.SMSRequest();
        req.phoneNumber = '+1234567890';
        req.messageContent = 'Test message';
        req.fromAddress = 'TestSender';
        req.contactId = null;
        List<GenesysSMSInvoker.SMSRequest> requests = new List<GenesysSMSInvoker.SMSRequest>{req};

        // Enqueue the job and assert jobId is not null
        Test.startTest();
        ID jobId = System.enqueueJob(new BulkSMSService(requests));
        Test.stopTest();
        System.assertNotEquals(null, jobId, 'JobId should not be null');

        // Cover chunking logic with >50 requests
        List<GenesysSMSInvoker.SMSRequest> manyRequests = new List<GenesysSMSInvoker.SMSRequest>();
        for (Integer i = 0; i < 55; i++) {
            GenesysSMSInvoker.SMSRequest r = new GenesysSMSInvoker.SMSRequest();
            r.phoneNumber = '+12345678' + String.valueOf(i);
            r.messageContent = 'Msg ' + i;
            r.fromAddress = 'Sender';
            r.contactId = null;
            manyRequests.add(r);
        }
        Test.startTest();
        jobId = System.enqueueJob(new BulkSMSService(manyRequests));
        Test.stopTest();
        System.assertNotEquals(null, jobId, 'JobId for chunked requests should not be null');
    }
}
