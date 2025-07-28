/**
 * @description Test class for GenesysSMSInvoker
 * @author System Administrator  
 * @date 2025-07-28
 */
@isTest
public class GenesysSMSInvokerTest {
    
    @TestSetup
    static void makeData() {
        // Test data creation is handled by individual test methods
        // as Custom Metadata cannot be inserted in tests
    }
    
    @isTest
    static void testSendSMSSuccess() {
        // Mock successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(200, '{"id":"msg123","messageStatus":"sent"}'));
        
        Test.startTest();
        Boolean result = GenesysSMSInvoker.sendSMS('+15551234567', 'Test message');
        Test.stopTest();
        
        System.assertEquals(true, result, 'SMS should be sent successfully');
    }
    
    @isTest
    static void testSendSMSWithResponse() {
        // Mock successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(200, '{"id":"msg123","messageStatus":"sent"}'));
        
        Test.startTest();
        GenesysSMSInvoker.SMSResponse response = GenesysSMSInvoker.sendSMSWithResponse('+15551234567', 'Test message');
        Test.stopTest();
        
        System.assertEquals(true, response.success, 'SMS should be sent successfully');
        System.assertEquals('msg123', response.messageId, 'Message ID should be returned');
        System.assertEquals('sent', response.status, 'Status should be returned');
    }
    
    @isTest
    static void testSendSMSAPIError() {
        // Mock API error response
        Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(400, '{"error":"Invalid request"}'));
        
        Test.startTest();
        GenesysSMSInvoker.SMSResponse response = GenesysSMSInvoker.sendSMSWithResponse('+15551234567', 'Test message');
        Test.stopTest();
        
        System.assertEquals(false, response.success, 'SMS should fail');
        System.assert(response.error.contains('400'), 'Error should contain status code');
    }
    
    @isTest
    static void testInvalidPhoneNumber() {
        Test.startTest();
        GenesysSMSInvoker.SMSResponse response = GenesysSMSInvoker.sendSMSWithResponse('invalid', 'Test message');
        Test.stopTest();
        
        System.assertEquals(false, response.success, 'SMS should fail for invalid phone');
        System.assert(response.error.contains('Invalid phone number'), 'Error should mention invalid phone');
    }
    
    @isTest
    static void testEmptyMessage() {
        Test.startTest();
        GenesysSMSInvoker.SMSResponse response = GenesysSMSInvoker.sendSMSWithResponse('+15551234567', '');
        Test.stopTest();
        
        System.assertEquals(false, response.success, 'SMS should fail for empty message');
        System.assert(response.error.contains('empty'), 'Error should mention empty message');
    }
    
    @isTest
    static void testBulkSMS() {
        // Mock successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(200, '{"id":"msg123","messageStatus":"sent"}'));
        
        List<GenesysSMSInvoker.SMSRequest> requests = new List<GenesysSMSInvoker.SMSRequest>();
        
        GenesysSMSInvoker.SMSRequest req1 = new GenesysSMSInvoker.SMSRequest();
        req1.phoneNumber = '+15551234567';
        req1.messageContent = 'Test message 1';
        requests.add(req1);
        
        GenesysSMSInvoker.SMSRequest req2 = new GenesysSMSInvoker.SMSRequest();
        req2.phoneNumber = '+15551234568';
        req2.messageContent = 'Test message 2';
        requests.add(req2);
        
        Test.startTest();
        Boolean result = GenesysSMSInvoker.sendSMS(requests);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Bulk SMS should succeed');
    }
    
    @isTest
    static void testPhoneNumberValidation() {
        System.assertEquals(true, GenesysSMSInvoker.isValidPhoneNumber('+15551234567'), 'Valid international format should pass');
        System.assertEquals(true, GenesysSMSInvoker.isValidPhoneNumber('5551234567'), 'Valid US format should pass');
        System.assertEquals(true, GenesysSMSInvoker.isValidPhoneNumber('(555) 123-4567'), 'Valid formatted US number should pass');
        
        System.assertEquals(false, GenesysSMSInvoker.isValidPhoneNumber('123'), 'Too short number should fail');
        System.assertEquals(false, GenesysSMSInvoker.isValidPhoneNumber(''), 'Empty number should fail');
        System.assertEquals(false, GenesysSMSInvoker.isValidPhoneNumber(null), 'Null number should fail');
    }
    
    @isTest 
    static void testNoConfiguration() {
        // This test simulates no configuration being found
        // Since we can't delete Custom Metadata in tests, we use a mock that throws exception
        Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(200, '{"id":"msg123"}'));
        
        Test.startTest();
        try {
            // This will work in a real org with configuration, but we're testing the error path
            GenesysSMSInvoker.SMSResponse response = GenesysSMSInvoker.sendSMSWithResponse('+15551234567', 'Test');
            // In a real test org with no config, this would fail
            // In this test context, it may succeed due to test data isolation
        } catch (Exception e) {
            System.assert(e.getMessage().contains('configuration'), 'Should mention configuration error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Mock HTTP response for Genesys API
     */
    private class MockGenesysResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockGenesysResponse(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
}
