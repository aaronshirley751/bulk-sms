// Check available Apex invocable methods
System.debug('Checking FlowSMSSender class...');

// Try to find the sendSMSFromFlow method
Type flowSMSSenderType = Type.forName('FlowSMSSender');
System.debug('FlowSMSSender type: ' + flowSMSSenderType);

// Test some basic functionality
List<String> testContext = new List<String>{'contact123|||Test message|||+15559876543'};
try {
    List<String> result = FlowSMSSender.sendSMSFromFlow(testContext);
    System.debug('Method exists and callable, result: ' + result);
} catch (Exception e) {
    System.debug('Error calling method: ' + e.getMessage());
}
