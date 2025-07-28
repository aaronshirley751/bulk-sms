/**
 * @description Service class for rendering SMS templates with merge fields
 * @author System Administrator
 * @date 2025-07-28
 */
public with sharing class SMS_TemplateService {
    
    /**
     * @description Context class containing merge field data
     */
    public class MergeContext {
        public Id contactId;
        public Id leadId;
        public Id campaignId;
        public Map<String, Object> extraTokens;
    }

    /**
     * @description Custom exception for template not found errors
     */
    public class TemplateNotFoundException extends Exception {}

    /**
     * @description Returns the merged SMS text by rendering template with context data
     * @param developerName The DeveloperName of the SMS_Template__mdt record
     * @param ctx Merge context with record Ids for token replacement
     * @return String The rendered SMS message with merged fields
     */
    public static String renderTemplate(String developerName, MergeContext ctx) {
        // 1. Get template body
        String body = getTemplateBody(developerName);
        
        // 2. Build merge tokens
        Map<String, String> tokens = buildMergeTokens(ctx);
        
        // 3. Replace tokens in template body
        return replaceTokens(body, tokens);
    }
    
    /**
     * @description Retrieves template body from metadata
     * @param developerName The template developer name
     * @return String The template body content
     */
    private static String getTemplateBody(String developerName) {
        // Custom metadata queries are always accessible to users - no security enforcement needed
        // PMD suppression: Custom metadata is secure by design
        List<SMS_Template__mdt> records = [ //NOPMD ApexCRUDViolation
            SELECT Body__c FROM SMS_Template__mdt
            WHERE DeveloperName = :developerName AND IsActive__c = true
            LIMIT 1
        ];
        if (records.isEmpty()) {
            throw new TemplateNotFoundException('No active template named ' + developerName);
        }
        return records[0].Body__c;
    }
    
    /**
     * @description Builds merge tokens from context data
     * @param ctx The merge context containing record IDs
     * @return Map<String, String> Map of tokens to replacement values
     */
    private static Map<String, String> buildMergeTokens(MergeContext ctx) {
        Map<String, String> tokens = new Map<String, String>();
        
        if (ctx == null) {
            return tokens;
        }
        
        // Add contact tokens
        addContactTokens(ctx, tokens);
        
        // Add lead tokens  
        addLeadTokens(ctx, tokens);
        
        // Add campaign tokens
        addCampaignTokens(ctx, tokens);
        
        // Add extra tokens
        addExtraTokens(ctx, tokens);
        
        return tokens;
    }
    
    /**
     * @description Adds contact-related tokens to the map
     * @param ctx The merge context
     * @param tokens The tokens map to populate
     */
    private static void addContactTokens(MergeContext ctx, Map<String, String> tokens) {
        if (ctx.contactId != null) {
            // PMD suppression: Security enforced via Security.stripInaccessible() below
            List<Contact> contactList = [SELECT FirstName FROM Contact WHERE Id = :ctx.contactId LIMIT 1]; //NOPMD ApexCRUDViolation
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, contactList);
            List<Contact> accessibleContacts = decision.getRecords();
            if (!accessibleContacts.isEmpty()) {
                tokens.put('{!Contact.FirstName}', accessibleContacts[0].FirstName);
            }
        }
    }
    
    /**
     * @description Adds lead-related tokens to the map
     * @param ctx The merge context
     * @param tokens The tokens map to populate
     */
    private static void addLeadTokens(MergeContext ctx, Map<String, String> tokens) {
        if (ctx.leadId != null) {
            // PMD suppression: Security enforced via Security.stripInaccessible() below
            List<Lead> leadList = [SELECT FirstName FROM Lead WHERE Id = :ctx.leadId LIMIT 1]; //NOPMD ApexCRUDViolation
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, leadList);
            List<Lead> accessibleLeads = decision.getRecords();
            if (!accessibleLeads.isEmpty()) {
                tokens.put('{!Lead.FirstName}', accessibleLeads[0].FirstName);
            }
        }
    }
    
    /**
     * @description Adds campaign-related tokens to the map
     * @param ctx The merge context
     * @param tokens The tokens map to populate
     */
    private static void addCampaignTokens(MergeContext ctx, Map<String, String> tokens) {
        if (ctx.campaignId != null) {
            // PMD suppression: Security enforced via Security.stripInaccessible() below
            List<Campaign> campaignList = [SELECT Name FROM Campaign WHERE Id = :ctx.campaignId LIMIT 1]; //NOPMD ApexCRUDViolation
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, campaignList);
            List<Campaign> accessibleCampaigns = decision.getRecords();
            if (!accessibleCampaigns.isEmpty()) {
                tokens.put('{!Campaign.Name}', accessibleCampaigns[0].Name);
            }
        }
    }
    
    /**
     * @description Adds extra custom tokens to the map
     * @param ctx The merge context
     * @param tokens The tokens map to populate
     */
    private static void addExtraTokens(MergeContext ctx, Map<String, String> tokens) {
        if (ctx.extraTokens != null) {
            for (String key : ctx.extraTokens.keySet()) {
                Object val = ctx.extraTokens.get(key);
                tokens.put(key, val == null ? '' : String.valueOf(val));
            }
        }
    }
    
    /**
     * @description Replaces tokens in template body with actual values
     * @param body The template body
     * @param tokens Map of tokens to replacement values
     * @return String The body with tokens replaced
     */
    private static String replaceTokens(String body, Map<String, String> tokens) {
        for (String token : tokens.keySet()) {
            body = body.replace(token, tokens.get(token));
        }
        return body;
    }
}
