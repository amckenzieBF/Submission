public class QueuedSubmissions {


	private static Map<String, SubmitDealIF> dealMap = new Map<String, SubmitDealIF>{ 
		'ONDECK' => new Submit2OnDeck(),
		'QUICKBRIDGE' => new Submit2Quickbridge(),
		'BIZFI FUNDING' => new Submit2BizFi()
	};

    private static Map<String, SubmitDealIF> docMap = new Map<String, SubmitDealIF>{
        'ONDECK' => new SubmitDocs2OnDeck(),
        'QUICKBRIDGE' => new SubmitDocs2Quickbridge(),
        'BIZFI FUNDING' => new SubmitDocs2BizFi() 
    };

	@InvocableMethod
	public static void submitDeals(List<McaApp__Submission__c> submissions) {
        
        Callout_Settings__c cs = Callout_Settings__c.getOrgDefaults();
		Boolean callEnabled = cs.ASAP__c;
		
        if(CallEnabled) {
            for(McaApp__Submission__c s : submissions){
                if(dealMap.keySet().contains(s.Funder_Name__c)){
                    dealMap.get(s.Funder_Name__c).submitRecord(s);
                    Id jobID = System.enqueueJob(dealMap.get(s.Funder_Name__c));
                    System.debug('Job Id:  ' + jobID);
                }
            }
        }
	}
    
    public static void submitDocs(Map<Id, McaApp__Submission__c> oldSubmissions, Map<Id, McaApp__Submission__c> newSubmissions) {
        
        Callout_Settings__c cs = Callout_Settings__c.getOrgDefaults();
		Boolean callEnabled = cs.ASAP__c;
        
        if(callEnabled) {
            for(McaApp__Submission__c submission : newSubmissions.values()){
                if((oldSubmissions.get(submission.Id).External_ID__c != newSubmissions.get(submission.Id).External_Id__c) 
                   && String.isNotBlank(submission.External_Id__c) && String.isBlank(oldSubmissions.get(submission.Id).External_Id__c)
                   && docMap.keySet().contains(submission.Funder_Name__c)) {
                       docMap.get(submission.Funder_Name__c).submitRecord(submission);
                       Id jobID = System.enqueueJob(docMap.get(submission.Funder_Name__c));
                }
            }
        }
    }


}