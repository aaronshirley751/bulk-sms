@isTest
private class SMS_TemplateServiceTest {
    @isTest
    static void testRender() {
        // Sample Contact & Campaign
        Contact c = new Contact(LastName='Smith', FirstName='Anna');
        insert c;
        Campaign camp = new Campaign(Name='Summer Promo', IsActive=true);
        insert camp;

        SMS_TemplateService.MergeContext ctx = new SMS_TemplateService.MergeContext();
        ctx.contactId = c.Id;
        ctx.campaignId = camp.Id;
        
        // Test the template rendering
        String result = SMS_TemplateService.renderTemplate('Welcome_New_Lead', ctx);

        System.assert(result.contains('Anna'), 'Template should contain contact first name');
        System.assert(result.contains('Summer Promo'), 'Template should contain campaign name');
    }
}
