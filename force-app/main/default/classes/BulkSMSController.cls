// BulkSMSController: Aura-enabled controller for bulk SMS
public with sharing class BulkSMSController {
    /**
     * Sends bulk SMS messages to a list of Contacts.
     * @param recordIds   List of Contact Ids
     * @param messageText SMS message content
     * @param fromAddress SMS sender address
     * @return Status message
     */
    @AuraEnabled
    public static String sendBulkSMS(List<Id> recordIds, String messageText, String fromAddress) {
        // 1. Query Contacts by recordIds
        List<Contact> contacts = [SELECT Id, MobilePhone, HasOptedOutOfSMS FROM Contact WHERE Id IN :recordIds];
        List<GenesysSMSInvoker.SMSRequest> requests = new List<GenesysSMSInvoker.SMSRequest>();
        Integer queued = 0;
        // 2. Filter out null/opted-out and build requests
        for (Contact c : contacts) {
            if (String.isBlank(c.MobilePhone) || c.HasOptedOutOfSMS) {
                continue;
            }
            GenesysSMSInvoker.SMSRequest req = new GenesysSMSInvoker.SMSRequest();
            req.phoneNumber    = c.MobilePhone;
            req.messageContent = messageText;
            req.fromAddress    = fromAddress;
            req.contactId      = c.Id;
            requests.add(req);
            queued++;
        }
        // 3. Enqueue job if there are requests
        if (!requests.isEmpty()) {
            System.enqueueJob(new BulkSMSService(requests));
        }
        // 4. Return status
        return 'Queued ' + queued + ' messages';
    }
}
