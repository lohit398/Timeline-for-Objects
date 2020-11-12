trigger StageTracker_Opportunity on Opportunity (after insert, after update) {
    List<OpportunityStage_Tracker__c> oppStageChanges = new List<OpportunityStage_Tracker__c>();
    
    if(Trigger.isUpdate){
        for(Opportunity opp:Trigger.new){
            Opportunity oppOld = Trigger.oldMap.get(opp.ID);
            if(oppOld.StageName != opp.StageName){
                OpportunityStage_Tracker__c oppChange = new OpportunityStage_Tracker__c();
                oppChange.Current_Stage__c = opp.StageName;
                oppChange.Change_Date_and_Time__c = DateTime.now();
                oppChange.Name = opp.Id;
                oppChange.Previous_Stage__c  = oppOld.StageName;
                oppStageChanges.add(oppChange);
            }
        }
    }
    else if(Trigger.isInsert){
        for(Opportunity opp:Trigger.new){
            OpportunityStage_Tracker__c oppInserted = new OpportunityStage_Tracker__c();
            oppInserted.Current_Stage__c = opp.StageName;
            oppInserted.Change_Date_and_Time__c = DateTime.now();
            oppInserted.Name = opp.Id;
            oppInserted.Previous_Stage__c  = 'None - New Inserted Opportunity';
            oppStageChanges.add(oppInserted);
        }
    } 
    if(!oppStageChanges.isEmpty())
    	INSERT oppStageChanges;
}