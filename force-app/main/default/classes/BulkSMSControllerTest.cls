@isTest
public class BulkSMSControllerTest {
    @isTest
    static void testSendBulkSMS() {
        // Insert two Contacts
        Contact c1 = new Contact(LastName='Smith', MobilePhone='+1234567890', HasOptedOutOfSMS=false);
        Contact c2 = new Contact(LastName='Jones', MobilePhone='+0987654321', HasOptedOutOfSMS=true);
        insert new List<Contact>{c1, c2};

        // Call sendBulkSMS
        Test.startTest();
        String result = BulkSMSController.sendBulkSMS(
            new List<Id>{c1.Id, c2.Id},
            'Hello world',
            'MyFromAddress'
        );
        Test.stopTest();

        // Assert result
        System.assert(result.contains('Queued 1 messages'), 'Result should indicate 1 message queued');
    }
}
