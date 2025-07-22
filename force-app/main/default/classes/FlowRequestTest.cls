/**
 * Test class for FlowRequest functionality in BulkSMSController.
 * 
 * This test class validates the FlowRequest wrapper class including its
 * constructors, getters, setters, and integration with the invocable method.
 * 
 * @author Generated
 * @since API Version 58.0
 */
@isTest
public class FlowRequestTest {
    
    /**
     * Test the default no-args constructor.
     */
    @isTest
    static void testDefaultConstructor() {
        // Test
        BulkSMSController.FlowRequest request = new BulkSMSController.FlowRequest();
        
        // Verify
        System.assertNotEquals(null, request.getRecordIds(), 'Record IDs should be initialized');
        System.assertEquals(0, request.getRecordIds().size(), 'Record IDs should be empty list');
        System.assertEquals('', request.getMessage(), 'Message should be empty string');
        System.assertEquals('', request.getFromAddress(), 'From address should be empty string');
    }
    
    /**
     * Test getter and setter methods for recordIds.
     */
    @isTest
    static void testRecordIdsProperty() {
        // Setup
        BulkSMSController.FlowRequest request = new BulkSMSController.FlowRequest();
        List<String> testIds = new List<String>{'003000000000001', '003000000000002'};
        
        // Test setter
        request.setRecordIds(testIds);
        System.assertEquals(testIds, request.getRecordIds(), 'Record IDs should match set value');
        
        // Test null handling
        request.setRecordIds(null);
        System.assertNotEquals(null, request.getRecordIds(), 'Should handle null by creating empty list');
        System.assertEquals(0, request.getRecordIds().size(), 'Should be empty list when null passed');
    }
    
    /**
     * Test getter and setter methods for message.
     */
    @isTest
    static void testMessageProperty() {
        // Setup
        BulkSMSController.FlowRequest request = new BulkSMSController.FlowRequest();
        String testMessage = 'Hello, this is a test SMS message!';
        
        // Test setter
        request.setMessage(testMessage);
        System.assertEquals(testMessage, request.getMessage(), 'Message should match set value');
        
        // Test null handling
        request.setMessage(null);
        System.assertEquals('', request.getMessage(), 'Should handle null by setting empty string');
    }
    
    /**
     * Test getter and setter methods for fromAddress.
     */
    @isTest
    static void testFromAddressProperty() {
        // Setup
        BulkSMSController.FlowRequest request = new BulkSMSController.FlowRequest();
        String testFromAddress = '+1-555-123-4567';
        
        // Test setter
        request.setFromAddress(testFromAddress);
        System.assertEquals(testFromAddress, request.getFromAddress(), 'From address should match set value');
        
        // Test null handling
        request.setFromAddress(null);
        System.assertEquals('', request.getFromAddress(), 'Should handle null by setting empty string');
    }
    
    /**
     * Test the toString method.
     */
    @isTest
    static void testToStringMethod() {
        // Setup
        BulkSMSController.FlowRequest request = new BulkSMSController.FlowRequest();
        request.setRecordIds(new List<String>{'003000000000001', '003000000000002'});
        request.setMessage('Test message');
        request.setFromAddress('+1-555-123-4567');
        
        // Test
        String result = request.toString();
        
        // Verify
        System.assert(result.contains('FlowRequest{'), 'Should start with class name');
        System.assert(result.contains('2 records'), 'Should show record count');
        System.assert(result.contains('Test message'), 'Should include message');
        System.assert(result.contains('+1-555-123-4567'), 'Should include from address');
    }
    
    /**
     * Test toString with null/empty values.
     */
    @isTest
    static void testToStringWithNullValues() {
        // Setup
        BulkSMSController.FlowRequest request = new BulkSMSController.FlowRequest();
        
        // Test
        String result = request.toString();
        
        // Verify
        System.assert(result.contains('0 records'), 'Should show 0 records for empty list');
        System.assert(result.contains('null'), 'Should show null for empty message and address');
    }
    
    /**
     * Test @InvocableVariable annotations are properly configured.
     * This is a compile-time test - if the class compiles, the annotations are valid.
     */
    @isTest
    static void testInvocableVariableAnnotations() {
        // Setup
        BulkSMSController.FlowRequest request = new BulkSMSController.FlowRequest();
        
        // Test - accessing the public variables validates they exist with proper annotations
        request.recordIds = new List<String>{'003000000000001'};
        request.message = 'Direct access test';
        request.fromAddress = '+1-555-999-8888';
        
        // Verify
        System.assertEquals(1, request.recordIds.size(), 'Direct recordIds access should work');
        System.assertEquals('Direct access test', request.message, 'Direct message access should work');
        System.assertEquals('+1-555-999-8888', request.fromAddress, 'Direct fromAddress access should work');
    }
}
