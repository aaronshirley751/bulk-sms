public with sharing class SMS_TemplateService {
    public class MergeContext {
        public Id contactId;
        public Id leadId;
        public Id campaignId;
        public Map<String, Object> extraTokens;
    }

    public class TemplateNotFoundException extends Exception {}

    /** Returns the merged SMS text.
     *  @param developerName The DeveloperName of the SMS_Template__mdt record
     *  @param ctx           Merge context with record Ids for tokens
     **/
    public static String renderTemplate(String developerName, MergeContext ctx) {
        // 1. fetch active SMS_Template__mdt by developerName
        List<SMS_Template__mdt> records = [
            SELECT Body__c FROM SMS_Template__mdt
            WHERE DeveloperName = :developerName AND IsActive__c = true
            LIMIT 1
        ];
        if (records.isEmpty()) {
            throw new TemplateNotFoundException('No active template named ' + developerName);
        }
        SMS_Template__mdt template = records[0];
        String body = template.Body__c;
        Map<String, String> tokens = new Map<String, String>();
        // 2. build tokens
        if (ctx != null) {
            if (ctx.contactId != null) {
                Contact c = [SELECT FirstName FROM Contact WHERE Id = :ctx.contactId LIMIT 1];
                tokens.put('{!Contact.FirstName}', c.FirstName);
            }
            if (ctx.leadId != null) {
                Lead l = [SELECT FirstName FROM Lead WHERE Id = :ctx.leadId LIMIT 1];
                tokens.put('{!Lead.FirstName}', l.FirstName);
            }
            if (ctx.campaignId != null) {
                Campaign camp = [SELECT Name FROM Campaign WHERE Id = :ctx.campaignId LIMIT 1];
                tokens.put('{!Campaign.Name}', camp.Name);
            }
            if (ctx.extraTokens != null) {
                for (String key : ctx.extraTokens.keySet()) {
                    Object val = ctx.extraTokens.get(key);
                    tokens.put(key, val == null ? '' : String.valueOf(val));
                }
            }
        }
        // 3. perform string replace
        for (String token : tokens.keySet()) {
            body = body.replace(token, tokens.get(token));
        }
        return body;
    }
}
