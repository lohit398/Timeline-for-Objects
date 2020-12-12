public with sharing class CaseRelatedRecords {
    
    public class CaseWrapper {
        @AuraEnabled
        public Case c = new Case();        
        @AuraEnabled
        public list<SObject> chatsList = new List<SObject>();
        @AuraEnabled
        public list<Task> emailMessages = new List<Task>();
        @AuraEnabled
        public List<Task> callTasks = new List<Task>();
        @AuraEnabled
        public List<SObject> socialPosts = new List<SObject>();
        @AuraEnabled
        public List<GetMultiObjectRecord.messagingWrapper> messagingList = new List<GetMultiObjectRecord.messagingWrapper>();
    }
    @AuraEnabled(cacheable=true)
    public static List<Case> getRelatedCases(String contactId){
        return [SELECT id,CaseNumber,Subject,Description,CreatedDate,Owner.Name,Status from Case where ContactId =: contactId ORDER BY CreatedDate DESC];
    }
    @AuraEnabled
    public static CaseWrapper unrelatedRecords(Id contactId,List<Id> cases){
        CaseWrapper cWrapperUnrelated = new CaseWrapper();
        if(SObjectUtil.isObjectExist('LiveChatTranscript')){
            String chatsListQuery = 'SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where ContactId =\''+contactId+'\'AND CaseId NOT IN: cases ORDER BY StartTime DESC';
            cWrapperUnrelated.chatsList = Database.query(chatsListQuery);
        }
        
        cWrapperUnrelated.emailMessages = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject FROM Task WHERE Type = 'Email' AND whatId NOT IN: cases AND WhoId =: contactId];
        cWrapperUnrelated.callTasks = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' AND whatId NOT IN: cases AND WhoId =: contactId ORDER BY createddate DESC];
        if(SObjectUtil.isObjectExist('SocialPost')){
            String socialPostsQuery = 'select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where ParentId NOT IN :cases and WhoId = \''+contactId+'\'';
            cWrapperUnrelated.socialPosts = Database.query(socialPostsQuery);
        }
        GetMultiObjectRecord.Wrapper obj = new GetMultiObjectRecord.Wrapper();
        obj.caseId = '';
        obj.caseIds = cases;
        obj.contactId = contactId;
        obj.remainingRecords = true;
        if(SObjectUtil.isObjectExist('MessagingSession')){
            obj.getConversationEntries();
        }
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
        
        for(Integer i=0;i<caseList.size();i++){
            caseIds.add(caseList[i].Id);
        }
        
        /*For Social Posts*/
        Map<String,List<SObject>> socialPostCases = new Map<String,List<SObject>>();
        if(SObjectUtil.isObjectExist('SocialPost')){
            String querySocialPosts = 'select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name,ParentId from SocialPost where ParentId IN :caseIds';
            List<SObject> socialPostsList = Database.query(querySocialPosts);
            for(Integer i=0;i<socialPostsList.size();i++){
                String key = String.valueOf(socialPostsList[i].get('ParentId'));
                if(socialPostCases.keySet().contains(key)){
                    List<SObject> correspondingList = socialPostCases.get(key);
                    correspondingList.add(socialPostsList[i]);
                    socialPostCases.put(key,correspondingList);
                }
                else{
                    List<SObject> newList = new List<SObject>();
                    newList.add(socialPostsList[i]);
                    socialPostCases.put(key,newList);
                }
            }
        }
        
        /*For LiveChatTranscripts*/
        Map<String,List<SObject>> chatsCases = new Map<String,List<SObject>>();
        if(SObjectUtil.isObjectExist('LiveChatTranscript')){
            String queryChatList = 'SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where CaseId IN :caseIds ORDER BY StartTime DESC';
            List<SObject> chatList = Database.query(queryChatList);
            for(Integer i=0;i<chatList.size();i++){
                String key = String.valueOf(chatList[i].get('CaseId'));
                if(chatsCases.keySet().contains(key)){
                    List<SObject> correspondingList = chatsCases.get(key);
                    correspondingList.add(chatList[i]);
                    chatsCases.put(key,correspondingList);
                }
                else{
                    List<SObject> newList = new List<SObject>();
                    newList.add(chatList[i]);
                    chatsCases.put(key,newList);
                }
            }
        }
        
        /*For Email Messages*/
        List<Task> emailMessagesCases = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject,WhatId FROM Task WHERE Type = 'Email' AND WhatId IN :caseIds];
        Map<String,List<Task>> emailWithCases = new Map<String,List<Task>>();
        for(Integer i=0;i<emailMessagesCases.size();i++){
            String key = String.valueOf(emailMessagesCases[i].WhatId);
            if(emailWithCases.keySet().contains(key)){
                List<Task> correspondingList = emailWithCases.get(key);
                correspondingList.add(emailMessagesCases[i]);
                emailWithCases.put(key,correspondingList);
            }
            else{
                List<Task> newList = new List<Task>();
                newList.add(emailMessagesCases[i]);
                emailWithCases.put(key,newList);
            }
        }
        
        /* For Calls */
        List<Task> callsCases = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' and whatId IN :caseIds ORDER BY createddate DESC];
        Map<String,List<Task>> callsWithCases = new Map<String,List<Task>>();
        for(Integer i=0;i<callsCases.size();i++){
            String key = String.valueOf(callsCases[i].WhatId);
            if(callsWithCases.keySet().contains(key)){
                List<Task> correspondingList = emailWithCases.get(key);
                correspondingList.add(callsCases[i]);
                callsWithCases.put(key,correspondingList);
            }
            else{
                List<Task> newList = new List<Task>();
                newList.add(callsCases[i]);
                callsWithCases.put(key,newList);
            }
        }
        
        for(Case item: caseList){
            CaseWrapper cW = new CaseWrapper();
            cW.c = item;
            
            if(SObjectUtil.isObjectExist('LiveChatTranscript')){
                cW.chatsList = chatsCases.get(String.valueOf(item.Id));
            }
            if(SObjectUtil.isObjectExist('SocialPost')){
                cW.socialPosts = socialPostCases.get(String.valueOf(item.Id));
            }
            
            cW.emailMessages = emailWithCases.get(String.valueOf(item.Id));
            cW.callTasks = callsWithCases.get(String.valueOf(item.Id));
            
            GetMultiObjectRecord.Wrapper obj = new GetMultiObjectRecord.Wrapper();
            obj.caseId = item.Id;
            if(SObjectUtil.isObjectExist('MessagingSession')){
                obj.getConversationEntries();
                cW.messagingList = obj.messaging;
            }
            caseWrapperList.add(cW);            
        }
        CaseWrapper cW = new CaseWrapper();
        cW = unrelatedRecords(contactId,caseIds);
        caseWrapperList.add(cW);
        //System.debug(caseWrapperList);
        return caseWrapperList;
    }
}