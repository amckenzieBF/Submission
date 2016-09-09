global class SubmitDocs2Quickbridge implements SubmitDealIF, Queueable, Database.AllowsCallouts{
    
    
    private McaApp__Submission__c submission;
    
    public SubmitDocs2Quickbridge(){}
    
    public void submitRecord(McaApp__Submission__c newSubmission) {
        this.submission = newSubmission;
    }
	
    public void execute(QueueableContext context) {
        Id qbSubmission = submission.Id;
        McaApp__Submission__c subUpdate = [SELECT Name, External_Id__c, McaApp__Opportunity__c FROM McaApp__Submission__c WHERE Id = :qbSubmission LIMIT 1];
        Id apiUser = [SELECT Id FROM User WHERE LastName = 'API User' LIMIT 1].Id;
        Attachment[] dealDocs = [SELECT Name, Body FROM Attachment WHERE ParentId = :subUpdate.McaApp__Opportunity__c AND OwnerId != :apiUser];

        if(!dealDocs.isEmpty()) {
            Zippex zip = new Zippex();
            
            for(Attachment a : dealDocs) {
                zip.addFile(a.Name, a.Body, null);
            }
            
            Map<String,Object> data = APIService.accessToken(); 
            AccessTokenResult token = new AccessTokenResult();  
            token.ErrorMessage = (String)data.get('ErrorMessage');
            token.StatusCode = (Integer)data.get('StatusCode');
            token.AccessToken = (String)data.get('AccessToken');
                    
            String due = (String)data.get('ExpiresOn');
            String secs;
            Datetime dt = Datetime.newInstance(Long.valueOf(due));
            token.ExpiresOn = dt.date();
            
            Integer dealId = Integer.valueOf(subUpdate.External_Id__c);
            ConnectResult cr = APIService.uploadDocument(token, dealId, zip.getZipArchive(), 'Zippex.zip');
            
            System.debug(cr);
            
            if(cr.StatusCode == '0') {
                subUpdate.Docs_Submitted__c = true;
                update subUpdate;
            }
        }
    }
    
    
}