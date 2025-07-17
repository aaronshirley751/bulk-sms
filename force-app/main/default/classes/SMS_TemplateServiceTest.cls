@isTest(seeAllData=true)
private class SMS_TemplateServiceTest {
    @isTest
    static void testRender() {
        // Sample Contact & Campaign
        Contact c = new Contact(LastName='Smith', FirstName='Anna');
@isTest(seeAllData=true)
private class SMS_TemplateServiceTest {
  @isTest
  static void testRender() {
    // assume your record is already in the org
    // set up your Contact & Campaign
    Contact c = new Contact(LastName='Smith', FirstName='Anna');
    insert c;
    Campaign camp = new Campaign(Name='Summer Promo', IsActive=true);
    insert camp;

    SMS_TemplateService.MergeContext ctx = new SMS_TemplateService.MergeContext();
    ctx.contactId  = c.Id;
    ctx.campaignId = camp.Id;
    // now just call the service
    String result = SMS_TemplateService.renderTemplate('Welcome_New_Lead', ctx);

    System.assert(result.contains('Anna'));
    System.assert(result.contains('Summer Promo'));
  }
}
