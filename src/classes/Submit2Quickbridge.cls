global class Submit2Quickbridge implements SubmitDealIF, Queueable, Database.AllowsCallouts {

    
    private McaApp__Submission__c submission;
    
    public Submit2Quickbridge(){}
    
    public void submitRecord(McaApp__Submission__c newSubmission) {
        this.submission = newSubmission;
    }

    global void execute(QueueableContext context) {
        Callout_Settings__c cs = Callout_Settings__c.getOrgDefaults();
        if(cs.ASAP__c){
            Map<String,Object> data = APIService.accessToken(); 
            AccessTokenResult token = new AccessTokenResult();  
            token.ErrorMessage = (String)data.get('ErrorMessage');
            token.StatusCode = (Integer)data.get('StatusCode');
            token.AccessToken = (String)data.get('AccessToken');
                    
            String due = (String)data.get('ExpiresOn');
            String secs;
            Datetime dt = Datetime.newInstance(Long.valueOf(due));
            token.ExpiresOn = dt.date();
            
            // Collections for map to be sent and contacts related to opportunity contact roles
            Id qbSubmission = submission.Id;
            List<Id> cIds = new List<Id>();
            List<Contact> cList;
            McaApp__Submission__c subUpdate = [SELECT Name, External_Id__c, McaApp__Opportunity__c FROM McaApp__Submission__c WHERE Id = :qbSubmission LIMIT 1];
            Id opp = subUpdate.McaApp__Opportunity__c;
            
            // Get Opportunity and Account info
            Opportunity o = [SELECT Id, 
                                    McaApp__NSFs_avg__c,
                                    McaApp__Use_of_Proceeds__c,
                                    McaApp__Amount_Requested__c,
                                    Amt_Monthly_Bank_Deposits__c,
                                    McaApp__Avg_Number_Bank_Deposits__c,
                                    Account.Name, 
                                    Account.Phone, 
                                    Account.AnnualRevenue,
                                    Account.BillingStreet, 
                                    Account.BillingCity, 
                                    Account.BillingState, 
                                    Account.BillingPostalCode, 
                                    Account.Website, 
                                    Account.Industry, 
                                    Account.McaApp__Legal_Name__c, 
                                    Account.McaApp__Type_of_Entity__c, 
                                    Account.McaApp__Federal_Tax_ID_No__c, 
                                    Account.McaApp__Date_Business_Established__c, 
                                    Account.McaApp__Years_in_Business__c FROM Opportunity WHERE Id = :opp];
            
            // Add Account and Opp info to deal submission object                       
            DealSubmission deal = new DealSubmission();
            deal.ExternalDealId = qbSubmission;
            deal.BusinessWebsite = o.Account.Website;
            deal.CompanyName = o.Account.Name;
            deal.FederalTaxID = o.Account.McaApp__Federal_Tax_ID_No__c;
            deal.BusinessType = o.Account.McaApp__Type_of_Entity__c;
            deal.BusinessAddress1 = o.Account.BillingStreet;
            deal.BusinessCity = o.Account.BillingCity;
            deal.BusinessState = o.Account.BillingState;
            deal.BusinessZip = o.Account.BillingPostalCode;
            deal.BusinessStartedDate = String.valueOf(o.Account.McaApp__Date_Business_Established__c);
            deal.RequestedAmount = o.McaApp__Amount_Requested__c;
            deal.AnnualSales = o.Account.AnnualRevenue;
            deal.UseOfFunds = o.McaApp__Use_of_Proceeds__c;
            
            // Get Contacts and add to map
            for(OpportunityContactRole ocr : [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :opp]) {
                cIds.add(ocr.ContactId);
            }
            
            cList = [SELECT FirstName, LastName, BirthDate, McaApp__Of_Ownership__c, McaApp__Social_Security_Number1__c, Authorize_Run_Credit__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MobilePhone, Email, Credit_Score__c FROM Contact WHERE Id IN :cIds];
                    
            // add contact info for business owners
            BusinessOwner[] boList = new BusinessOwner[]{};
            for(Contact c : cList) {
                BusinessOwner bo = new BusinessOwner();
            
                bo.FirstName = c.FirstName;
                bo.LastName = c.LastName;
                bo.Email = c.Email;
                bo.CellPhone = c.MobilePhone;
                bo.Address1 = c.MailingStreet;
                bo.City = c.MailingCity;
                bo.State = c.MailingState;
                bo.Zip = c.MailingPostalCode;
                bo.SSN = c.McaApp__Social_Security_Number1__c;
                bo.PercentOfOwnerShip = c.McaApp__Of_Ownership__c;
                        
                boList.add(bo);
            }
                    
            deal.BusinessOwners = boList;
            
            // Add cashflow info
            Cashflow[] cflows = new Cashflow[]{};
            Cashflow cf = new Cashflow();
            MonthlyCashFlow[] mcflows = new MonthlyCashFlow[]{};
            MonthlyCashFlow mcf = new MonthlyCashFlow();
            mcf.NumberOfDeposits = o.McaApp__Avg_Number_Bank_Deposits__c.intValue();
            mcf.NumberOfNSFs = o.McaApp__NSFs_avg__c.intValue();
            mcf.TotalDepositAmount = o.Amt_Monthly_Bank_Deposits__c;
            mcf.Year = Date.today().year();
            
            mcflows.add(mcf);
            cf.MonthlyCashFlow = mcflows;
            cf.IsMainAccount = true;
            cflows.add(cf);
            deal.Cashflows = cflows;

            try {
                Map<String, Object> dealData = APIService.submitDeal(token,deal); 
                   
                DealSubmissionResult dealResult = new DealSubmissionResult();
                due = (String)dealData.get('ProcessedOn');
                secs = due.split('\\(')[1].split('\\-')[0];
                dt = Datetime.newInstance(Long.valueOf(secs));
                dealResult.ProcessedOn = dt;
                dealResult.DealID = (Integer)dealData.get('DealID');
                dealResult.ExternalDealID = (String)dealData.get('ExternalDealID'); 
                
                System.debug('DealID: ' + String.valueOf(dealResult.DealId));      
                subUpdate.External_Id__c = String.valueOf(dealResult.DealId);
                update subUpdate;
            } catch (CalloutException coe) {
                System.debug('The callout returned an error: ' + coe.getMessage());
                Callout_Error__c ce = new Callout_Error__c(Outbound_Message__c = subUpdate.Name, Class__c = 'Submit2Quickbridge', Response_Body__c = coe.getMessage());
                insert ce;
            }
        }
    }
    
    
}