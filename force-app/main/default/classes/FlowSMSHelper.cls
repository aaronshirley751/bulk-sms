/**
 * @description Helper class to set Flow context for SMS sending using assignment
 * @author System Administrator  
 * @date 2025-07-28
 */
public with sharing class FlowSMSHelper {
    
    /**
     * @description Set all SMS context values at once using separate calls
     */
    @InvocableMethod(label='Set SMS Context' description='Set all SMS context values for processing')
    public static void setSMSContext(List<String> dummy) {
        // This method will be called just to trigger the Flow
        // The actual context setting happens via static variables set by Flow assignments
        System.debug('FlowSMSHelper: setSMSContext called');
    }
    
    /**
     * @description Static method to set contact IDs from Flow
     */
    public static void setContactIds(List<String> contactIds) {
        FlowSMSSender.flowContactIds = contactIds;
        System.debug('FlowSMSHelper: Set contact IDs: ' + (contactIds != null ? String.join(contactIds, ', ') : 'null'));
    }
    
    /**
     * @description Static method to set message text from Flow
     */
    public static void setMessageText(String messageText) {
        FlowSMSSender.flowMessageText = messageText;
        System.debug('FlowSMSHelper: Set message text: ' + messageText);
    }
    
    /**
     * @description Static method to set from address from Flow
     */
    public static void setFromAddress(String fromAddress) {
        FlowSMSSender.flowFromAddress = fromAddress;
        System.debug('FlowSMSHelper: Set from address: ' + fromAddress);
    }
}
