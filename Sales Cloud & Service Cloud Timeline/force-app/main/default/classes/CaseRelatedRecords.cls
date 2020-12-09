public with sharing class CaseRelatedRecords {
    
    public class CaseWrapper {
        @AuraEnabled
        public Case c = new Case();        
        @AuraEnabled
        public list<SObject> chatsList {get;set;}
        @AuraEnabled
        public list<Task> emailMessages;
        @AuraEnabled
        public List<Task> callTasks;
        @AuraEnabled
        public List<SObject> socialPosts;
        @AuraEnabled
        public List<GetMultiObjectRecord.messagingWrapper> messagingList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Case> getRelatedCases(String contactId){
        return [SELECT id,CaseNumber,Subject,Description,CreatedDate,Owner.Name,Status from Case where ContactId =: contactId ORDER BY CreatedDate DESC];
    }
    @AuraEnabled
    public static CaseWrapper unrelatedRecords(Id contactId,List<Id> cases){
        CaseWrapper cWrapperUnrelated = new CaseWrapper();
        //cWrapperUnrelated.chatsList = [SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where ContactId =: contactId AND CaseId NOT IN: cases ORDER BY StartTime DESC];
        String chatsListQuery = 'SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where ContactId =\''+contactId+'\'AND CaseId NOT IN: cases ORDER BY StartTime DESC';
        cWrapperUnrelated.chatsList = Database.query(chatsListQuery);
        cWrapperUnrelated.emailMessages = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject FROM Task WHERE Type = 'Email' AND whatId NOT IN: cases AND WhoId =: contactId];
        List<Task> eM = new List<Task>();
        for(Task t: cWrapperUnrelated.emailMessages){
            if(t.Subject.indexOf('[') != -1)
                t.Subject = t.Subject.substring(0,t.Subject.indexOf('['));
            em.add(t);
        }
        cWrapperUnrelated.emailMessages =eM;
        cWrapperUnrelated.callTasks = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' AND whatId NOT IN: cases AND WhoId =: contactId ORDER BY createddate DESC];
        //cWrapperUnrelated.socialPosts =[select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where ParentId NOT IN: cases and WhoId =: contactId];
        String socialPostsQuery = 'select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where ParentId NOT IN :cases and WhoId = \''+contactId+'\'';
        cWrapperUnrelated.socialPosts = Database.query(socialPostsQuery);
        GetMultiObjectRecord.Wrapper obj = new GetMultiObjectRecord.Wrapper();
        obj.caseId = '';
        obj.caseIds = cases;
        obj.contactId = contactId;
        obj.remainingRecords = true;
        obj.getConversationEntries();
        cWrapperUnrelated.messagingList = obj.messaging;
        return cWrapperUnrelated;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CaseWrapper> getRelatedRecords(String recId){
        List<Id> caseIds = new List<Id>();
        GetMultiObjectRecord.Wrapper w = new GetMultiObjectRecord.Wrapper();
        w.sObjectType = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        w.recordId = recId;
        w.getContactId();
        Id contactId = w.contactId;
        list<CaseWrapper> caseWrapperList = new List<CaseWrapper>();
        List <Case> caseList = getRelatedCases(contactId);
        for(Case item: caseList){
            CaseWrapper cW = new CaseWrapper();
            cW.c = item;
            caseIds.add(item.Id);
            //cW.chatsList = [SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where CaseId=: item.Id ORDER BY StartTime DESC];
            String queryChatList = 'SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where CaseId= \''+item.Id+'\' ORDER BY StartTime DESC';
            cW.chatsList = Database.query(queryChatList);
            cW.emailMessages = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject FROM Task WHERE Type = 'Email' AND whatId =: item.Id];
            List<Task> eM = new List<Task>();
            for(Task t: cW.emailMessages){
                if(t.Subject.indexOf('[') != -1)
                    t.Subject = t.Subject.substring(0,t.Subject.indexOf('['));
                em.add(t);
            }
            cW.emailMessages =eM;
            cW.callTasks = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' and whatId =: item.Id ORDER BY createddate DESC];
            //cW.socialPosts = [select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where ParentId =: item.Id];
            String querySocialPosts = 'select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where ParentId = \''+item.Id+'\'';
            cW.socialPosts = Database.query(querySocialPosts);
            
            GetMultiObjectRecord.Wrapper obj = new GetMultiObjectRecord.Wrapper();
            obj.caseId = item.Id;
            obj.getConversationEntries();
            cW.messagingList = obj.messaging;
            caseWrapperList.add(cW);            
        }
        CaseWrapper cW = new CaseWrapper();
        cW = unrelatedRecords(contactId,caseIds);
        caseWrapperList.add(cW);
        return caseWrapperList;
    }
}