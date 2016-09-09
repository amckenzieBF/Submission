public virtual class SubmitDealAbstract {
  

  private static McaApp__Submission__c submission;
	public static Map<String, List<SObject>> dealData;

	public void setSubmission(McaApp__Submission__c newSubmission) {
    submission = newSubmission;

		Id[] cIds = new Id[]{};
    Id subId = newSubmission.Id;
    McaApp__Submission__c sub = [SELECT External_Id__c, McaApp__Opportunity__c FROM McaApp__Submission__c WHERE Id = :subId LIMIT 1];
    Id oppId = sub.McaApp__Opportunity__c;
        
    List<Opportunity> oList = [SELECT Id,
                                  McaApp__NSFs_avg__c,
                         		  Monthly_CC_Batches__c,
                         		  McaApp__Term_Requested__c,
                         		  Monthly_CC_Transactions__c,
                                  McaApp__Use_of_Proceeds__c,
                                  McaApp__Amount_Requested__c,
                                  Amt_Monthly_Bank_Deposits__c,
                         		  McaApp__Average_Daily_Balance__c,
                                  McaApp__Avg_Number_Bank_Deposits__c,
                                  Account.Sic,
                                  Account.Name, 
                                  Account.Phone,
                         		  Account.Website, 
                                  Account.Industry,
                                  Account.AnnualRevenue,
                                  Account.BillingStreet, 
                                  Account.BillingCity, 
                                  Account.BillingState, 
                                  Account.BillingPostalCode, 
                                  Account.McaApp__Legal_Name__c, 
                                  Account.McaApp__Type_of_Entity__c, 
                                  Account.McaApp__Federal_Tax_ID_No__c,
                                  Account.McaApp__Landlord_Contact_Name__c,
                                  Account.McaApp__Landlord_Phone__c, 
                                  Account.McaApp__Date_Business_Established__c, 
                                  Account.McaApp__Years_in_Business__c FROM Opportunity WHERE Id = :oppId];

    Id primeCon;                         
    for(OpportunityContactRole ocr : [SELECT ContactId, IsPrimary FROM OpportunityContactRole WHERE OpportunityId = :oppId]) {
        cIds.add(ocr.ContactId);
        if(ocr.IsPrimary == TRUE) { primeCon = ocr.ContactId; }
    }
            
        List<Contact> cList = [SELECT Id, FirstName, LastName, BirthDate, McaApp__Of_Ownership__c, McaApp__Social_Security_Number1__c, Authorize_Run_Credit__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MobilePhone, Email, Phone, Credit_Score__c FROM Contact WHERE Id IN :cIds];

        //Map<String, List<SObject>> dataMap = new Map<String, List<SObject>>();
        dealData.put('Opportunity', (List<SObject>) oList);
        dealData.put('Contact', (List<SObject>) cList);

	}

	//private static Map<String, List<SObject>> dealData = new Map<String, List<SObject>>{ pullDealData(submission); }

	public virtual String formatData(Map<String, List<SObject>> dealInfo) {
		String dealJSON = 'dealJSON';
		return dealJSON;
	}


}