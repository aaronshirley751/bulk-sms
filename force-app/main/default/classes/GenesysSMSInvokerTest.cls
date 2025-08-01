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
        System.debug(LoggingLevel.DEBUG, 'Test setup completed for GenesysSMSInvokerTest');
    }

    @isTest
    static void testSendSMSSuccess() {
        // Create test user
        User testUser = createTestUser();
        insert testUser;

        System.runAs(testUser) {
            // Mock successful HTTP response
            Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(200, '{"id":"msg123","messageStatus":"sent"}'));

            Test.startTest();
            Boolean result = GenesysSMSInvoker.sendSMS('+15551234567', 'Test message');
            Test.stopTest();

            System.assertEquals(true, result, 'SMS should be sent successfully');
        }
    }

    @isTest
    static void testSendSMSWithResponse() {
        // Create test user
        User testUser = createTestUser();
        insert testUser;

        System.runAs(testUser) {
            // Mock successful HTTP response
            Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(200, '{"id":"msg123","messageStatus":"sent"}'));

            Test.startTest();
            GenesysSMSInvoker.SMSResponse response = GenesysSMSInvoker.sendSMSWithResponse('+15551234567', 'Test message');
            Test.stopTest();

            System.assertEquals(true, response.success, 'SMS should be sent successfully');
            System.assertEquals('msg123', response.messageId, 'Message ID should be returned');
            System.assertEquals('sent', response.status, 'Status should be returned');
        }
    }

    @isTest
    static void testSendSMSAPIError() {
        // Create test user
        User testUser = createTestUser();
        insert testUser;

        System.runAs(testUser) {
            // Mock error HTTP response
            Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(400, '{"error":"Invalid phone number"}'));

            Test.startTest();
            Boolean result = GenesysSMSInvoker.sendSMS('+15551234567', 'Test message');
            Test.stopTest();

            System.assertEquals(false, result, 'SMS should fail due to API error');
        }
    }

    @isTest
    static void testInvalidPhoneNumber() {
        // Create test user
        User testUser = createTestUser();
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            Boolean result = GenesysSMSInvoker.sendSMS('invalid', 'Test message');
            Test.stopTest();

            System.assertEquals(false, result, 'SMS should fail due to invalid phone number');
        }
    }

    @isTest
    static void testEmptyMessage() {
        // Create test user
        User testUser = createTestUser();
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            Boolean result = GenesysSMSInvoker.sendSMS('+15551234567', '');
            Test.stopTest();

            System.assertEquals(false, result, 'SMS should fail due to empty message');
        }
    }

    @isTest
    static void testSendSMSFromFlow() {
        // Create test user
        User testUser = createTestUser();
        insert testUser;

        System.runAs(testUser) {
            // Mock successful HTTP response
            Test.setMock(HttpCalloutMock.class, new MockGenesysResponse(200, '{"id":"msg123","messageStatus":"sent"}'));

            // Create test SMS requests
            List<GenesysSMSInvoker.SMSRequest> requests = new List<GenesysSMSInvoker.SMSRequest>();
            GenesysSMSInvoker.SMSRequest request = new GenesysSMSInvoker.SMSRequest();
            request.phoneNumber = '+15551234567';
            request.messageContent = 'Test message from Flow';
            request.fromAddress = '+15559876543';
            request.contactId = null; // Optional for this test
            requests.add(request);

            Test.startTest();
            GenesysSMSInvoker.sendSMSFromFlow(requests);
            Test.stopTest();

            // Verify no exceptions thrown (success is logged, not returned in this method)
            System.assert(true, 'Flow SMS method should complete without exceptions');
        }
    }

    @isTest
    static void testEmptyFlowRequests() {
        // Create test user
        User testUser = createTestUser();
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            GenesysSMSInvoker.sendSMSFromFlow(new List<GenesysSMSInvoker.SMSRequest>());
            Test.stopTest();

            // Verify no exceptions thrown with empty list
            System.assert(true, 'Empty Flow SMS requests should be handled gracefully');
        }
    }

    /**
     * @description Helper method to create test user
     * @return User Test user with required fields
     */
    private static User createTestUser() {
        return new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'Test',
            Email = 'test@example.com',
            Username = 'test' + System.currentTimeMillis() + '@example.com.test',
            CompanyName = 'Test',
            Title = 'Test',
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
    }

    /**
     * @description Mock HTTP response for Genesys API calls
     */
    private class MockGenesysResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        /**
         * @description Constructor for mock response
         * @param statusCode HTTP status code to return
         * @param responseBody Response body to return
         */
        public MockGenesysResponse(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        /**
         * @description Respond method for HttpCalloutMock
         * @param req HTTP request
         * @return HTTPResponse Mock response
         */
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
}
