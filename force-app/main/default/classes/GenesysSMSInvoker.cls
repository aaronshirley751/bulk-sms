public class GenesysSMSInvoker {
    public class SMSRequest {
        @InvocableVariable(label='To Phone Number' required=true)
        public String phoneNumber;

        @InvocableVariable(label='Message Content' required=true)
        public String messageContent;

        @InvocableVariable(label='From Address' required=true)
        public String fromAddress;

        @InvocableVariable(label='Contact Id (optional)')
        public Id contactId;
    }

    @InvocableMethod(label='Send Genesys SMS' description='Sends an SMS via the Genesys Agentless SMS API.')
    public static void sendSMS(List<SMSRequest> requests) {
        for (SMSRequest req : requests) {
            GenesysSMSHandler.sendSMSFuture(
                req.phoneNumber,
                req.messageContent,
                req.fromAddress,
                req.contactId
            );
        }
    }
}