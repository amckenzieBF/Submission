trigger SubmissionTriggerBizfi on McaApp__Submission__c (after insert, before update) {

    if ((SingleTriggerRun.submissionTrigger || Test.isRunningTest())
    && !System.isBatch() && !System.isFuture()) {
        SingleTriggerRun.submissionTrigger = false;
        //if((Trigger.isAfter && Trigger.isInsert)) { QueuedSubmissions.submitDeals(trigger.new); }
        QueuedSubmissions.submitDocs(trigger.oldMap, trigger.newMap);
        //else{ QueuedSubmissions.submitDocs(trigger.oldMap, trigger.newMap); }
    }
  
}