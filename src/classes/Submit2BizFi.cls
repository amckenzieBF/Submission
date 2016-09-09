global class Submit2BizFi implements SubmitDealIF, Queueable, Database.AllowsCallouts{


	private McaApp__Submission__c submission;
    
    public Submit2BizFi(){}
    
    public void submitRecord(McaApp__Submission__c newSubmission) {
        this.submission = newSubmission;
    }

    global void execute(QueueableContext context) {
        
        Id[] cIds = new Id[]{};
    	Id subId = submission.Id;
    	McaApp__Submission__c sub = [SELECT External_Id__c, McaApp__Opportunity__c FROM McaApp__Submission__c WHERE Id = :subId LIMIT 1];
        Id oppId = sub.McaApp__Opportunity__c;
        
        Opportunity o = [SELECT Id,
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
            
        Map<Id, Contact> cList = new Map<Id, Contact>([SELECT Id, FirstName, LastName, BirthDate, McaApp__Of_Ownership__c, McaApp__Social_Security_Number1__c, Authorize_Run_Credit__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MobilePhone, Email, Phone, Credit_Score__c FROM Contact WHERE Id IN :cIds]);
                                
        JSONGenerator gen = JSON.createGenerator(true);
        /*
        gen.writeStartObject();
        gen.writeNumberField('PartnerID',);
        gen.writeStringField('APIKey',);
        gen.writeFieldName('Merchant');
        gen.writeStartObject();
        gen.writeStringField('DBA',);
        gen.writeStringField('LegalName',);
        gen.writeStringField('Address1',);
        gen.writeStringField('Address2',);
        gen.writeStringField('City',);
        gen.writeStringField('State',);
        gen.writeStringField('Zip',);
        gen.writeStringField('Phone',);
        gen.writeStringField('Email',);
        gen.writeStringField('LegalEntity',);
        gen.writeStringField('Industry',);
        gen.writeStringField('TaxID',);
        gen.writeNumberField('TimeInBusiness',);
        gen.writeStringField('Website',);
        gen.writeEndObject();
        gen.writeFieldName('Owners');
        gen.writeStartObject();
        gen.writeFieldName('PrimaryOwner');
        gen.writeStartObject();
        gen.writeStringField('FirstName',);
        gen.writeStringField('LastName');
        gen.writeStringField('DateBirth');
        gen.writeStringField('Address1');
        gen.writeStringField('Address2');
        gen.writeStringField('City');
        gen.writeStringField('State');
        gen.writeStringField('Zip');
        gen.writeStringField('PersonalPhone');
        gen.writeStringField('PersonalEmail');
        gen.writeStringField('FICORange');
        gen.writeStringField('SSN');
        gen.writeBooleanField('AuthorizePullCredit');
        gen.writeNumberField('PercentageofOwnership');
        gen.writeEndObject();
        //if more than one owner
        gen.writeFieldName('AdditionalOwnerOne');
        gen.writeStartObject();
        gen.writeEndObject();
        //.....
        gen.writeEndObject();
        gen.writeFieldName('Financials');
        gen.writeStartObject();
        gen.writeNumberField('AnnualGrossRevenue');
        gen.writeNumberField('MonthlyBankDeposit');
        gen.writeNumberField('DailyBankBalance');
        gen.writeBooleanField('AcceptCreditCard');
        //if accepts credit cards
        gen.writeNumberField('MonthlyCreditCardSales');
        //
        gen.writeNumberField('RequestAmount');
        gen.writeNumberField('RequestTerm');
        gen.writeStringField('PlanToUseFunding');
        // if existing financing
        gen.writeFieldName('ExistingFinancing');
        gen.writeStartObject();
        gen.writeEndObject();
        // ......
        // if collateral
        gen.writeFieldName('Collateral');
        gen.writeStartObject();
        gen.writeEndObject();
        // ......
        // if profit loss
        gen.writeFieldName('ProfitLoss');
        gen.writeStartObject();
        gen.writeEndObject();
        // ......
        gen.writeNumberField('Upsell',);
        gen.writeNumberField('MaxHoldback',);
        gen.writeNumberField('MaxTerm',);
        gen.writeNumberField('DesiredHoldback',);
        gen.writeNumberField('AcgCCBatchDays',);
        gen.writeNumberField('AvgBankDepositDays',);
        gen.writeBooleanField('SeasonalBusiness',);
        gen.writeStringField('CashAdvanceMethod',);
        gen.writeStringField('DealType',);
        gen.writeStringField('NegDailyEndingBalanceDays',);
        gen.writeStringField('NoNSF',);
        gen.writeStringField('BizfiRestrictedSIC',);
        gen.writeEndObject();
        gen.writeEndObject();
        */
        
        String deal = gen.getAsString();
    }


}