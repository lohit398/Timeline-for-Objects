public with sharing class GetMultiObjectRecord {
    @AuraEnabled(cacheable=true)
    public static Wrapper getRecords(String recId){
        String sObjName = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        Wrapper wrapperObject = new Wrapper();
        wrapperObject.recordId = recId;
        wrapperObject.sObjectType = sObjName;
        wrapperObject.getContactId();
        wrapperObject.getCases();
        wrapperObject.getChatTranscripts();
        wrapperObject.getConversationEntries();
        wrapperObject.getEmails();
        wrapperObject.getTasks();
        wrapperObject.getSocialPosts();
        return wrapperObject;
    }
    public class Wrapper{
        @AuraEnabled
        public String sObjectType;
        @AuraEnabled
        public Id recordId;
        public List<Id> caseIds = new List<Id>();
        
        @AuraEnabled
        public list<Case> caseList {get;set;}
        @AuraEnabled
        public list<MessagingSession> messagingList {get;set;}
        @AuraEnabled
        public list<LiveChatTranscript> chatsList {get;set;}
        @AuraEnabled
        public String transcriptCompiler ='';
        @AuraEnabled
        public list<messagingWrapper> messaging = new List<messagingWrapper>();
        @AuraEnabled
        public list<Task> emailMessages;
        @AuraEnabled
        public List<Task> callTasks;
        @AuraEnabled
        public List<SocialPost> socialPosts;
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String leadId;
        @AuraEnabled
        public Boolean remainingRecords = false;
        
        public String caseId = '';
        
        public void getContactId() {
            if(sObjectType == 'Case') {
                contactId = [SELECT ContactId FROM Case WHERE Id =: this.recordId LIMIT 1].ContactId;
                this.leadId = '';
            } else if(sObjectType == 'LiveChatTranscript') {
                contactId = [SELECT ContactId From LiveChatTranscript WHERE Id =: this.recordId LIMIT 1].ContactId;
                this.leadId = '';
            }
            else if(sObjectType == 'Task') {
                contactId = [SELECT WhoId From Task WHERE Id =: this.recordId LIMIT 1].WhoId;
                this.leadId = '';
            } else if(sObjectType == 'MessagingSession') {
                contactId = [SELECT EndUserContactId FROM MessagingSession WHERE Id =: this.recordId LIMIT 1 ].EndUserContactId;
                this.leadId = '';
            }
            else if(sObjectType == 'Contact'){
                contactId = [SELECT Id FROM Contact WHERE Id =: this.recordId LIMIT 1].Id;
                this.leadId = '';
            }
            else if(sObjectType == 'SocialPost'){
                contactId = [SELECT WhoId from SocialPost where Id=: this.recordId LIMIT 1].Id;
                this.leadId = '';
            }
            else if(sObjectType == 'Account'){
                contactId = [SELECT PersonContactId from Account where Id =: this.recordId LIMIT 1].PersonContactId;
                this.leadId = '';
            }
            else if(sObjectType == 'Lead'){
                leadId = this.recordId;
                contactId = '';
            }
        } 
        
        
        public  void getCases(){
            if(this.contactId != '')
                caseList = [SELECT id,CaseNumber,Subject,Description,CreatedDate,Owner.Name,Status from Case where ContactId =: contactId ORDER BY CreatedDate DESC]; // no lead field on case
            else
                caseList = new List<Case>();
        }
        
        public void getSocialPosts(){
            if(this.contactId != '')
                socialPosts = [select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where WhoId = :this.contactId];
            else if(this.leadId != '')
                socialPosts = [select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where WhoId = :this.leadId];
        }
        
        public  void getChatTranscripts(){
            if(this.contactId != '')
                chatsList = [SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where ContactId=: contactId ORDER BY StartTime DESC];
            else if(this.leadId != '')
                chatsList = [SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Lead.Name,CreatedDate from LiveChatTranscript where LeadId=: leadId ORDER BY StartTime DESC];
        }
        
        
        public void getConversationEntries() {
            if(this.contactId != ''){
                if(caseId == '' && !remainingRecords)
                    this.messagingList = [SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate from MessagingSession where EndUserContactId =: contactId ORDER BY StartTime DESC];
                else if(caseId != '' && !remainingRecords){
                    this.messagingList = [SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate from MessagingSession where CaseId =: caseId ORDER BY StartTime DESC];
                    caseIds.add(caseId);
                }
                else if ((caseId != '' && remainingRecords) || (caseId =='' && remainingRecords)){
                    System.debug(caseIds);
                    this.messagingList = [SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate from MessagingSession where CaseId NOT IN :caseIds AND  EndUserContactId =: contactId ORDER BY StartTime DESC];
                }
                
                for(Integer i=0;i< this.messagingList.size();i++){
                    List<ConversationEntry> messageEntryItems = [SELECT ActorName,ActorType,EntryType,Message FROM ConversationEntry WHERE EntryType = 'Text' AND ConversationId = :this.messagingList[i].Id];
                    
                    for (ConversationEntry entry : messageEntryItems) {
                        if (entry.ActorType=='EndUser') {
                            if (entry.Message==null) {
                                this.transcriptCompiler = this.transcriptCompiler +this.messagingList[i].EndUserContact.Name + ': ' + '[Unsupported Object]' + '\n';
                            } else {
                                this.transcriptCompiler = this.transcriptCompiler + this.messagingList[i].EndUserContact.Name + ': ' + entry.Message + '\n';
                            }          
                        }
                        else if(entry.ActorType == 'Agent'){
                            this.transcriptCompiler = this.transcriptCompiler + entry.ActorName + ': ' + entry.Message + '\n';
                        }
                        else if (entry.ActorType=='Bot'){
                            this.transcriptCompiler = this.transcriptCompiler + 'Me: ' + entry.Message + '\n';
                        }
                    }
                    
                    this.messaging.add(new messagingWrapper(this.messagingList[i],this.transcriptCompiler));
                    
                }
            }
            else if(this.leadId != ''){
                this.messagingList = [SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate from MessagingSession where CaseId NOT IN :caseIds AND  LeadId = :leadId ORDER BY StartTime DESC];
                for(Integer i=0;i< this.messagingList.size();i++){
                    List<ConversationEntry> messageEntryItems = [SELECT ActorName,ActorType,EntryType,Message FROM ConversationEntry WHERE EntryType = 'Text' AND ConversationId = :this.messagingList[i].Id];
                    
                    for (ConversationEntry entry : messageEntryItems) {
                        if (entry.ActorType=='EndUser') {
                            if (entry.Message==null) {
                                this.transcriptCompiler = this.transcriptCompiler +this.messagingList[i].EndUserContact.Name + ': ' + '[Unsupported Object]' + '\n';
                            } else {
                                this.transcriptCompiler = this.transcriptCompiler + this.messagingList[i].EndUserContact.Name + ': ' + entry.Message + '\n';
                            }          
                        }
                        else if(entry.ActorType == 'Agent'){
                            this.transcriptCompiler = this.transcriptCompiler + entry.ActorName + ': ' + entry.Message + '\n';
                        }
                        else if (entry.ActorType=='Bot'){
                            this.transcriptCompiler = this.transcriptCompiler + 'Me: ' + entry.Message + '\n';
                        }
                    }
                    
                    this.messaging.add(new messagingWrapper(this.messagingList[i],this.transcriptCompiler));
                    
                }
            }
        }
        
        public void getEmails(){
            if(this.contactId != ''){
                emailMessages = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject FROM Task WHERE Type = 'Email' AND WhoId =: contactId];
                List<Task> eM = new List<Task>();
                for(Task t: emailMessages){
                    if(t.Subject.indexOf('[') != -1)
                        t.Subject = t.Subject.substring(0,t.Subject.indexOf('['));
                    em.add(t);
                }
                emailMessages =eM;
            }
            else if(this.leadId != ''){
                emailMessages = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject FROM Task WHERE Type = 'Email' AND WhoId =: leadId];
                List<Task> eM = new List<Task>();
                for(Task t: emailMessages){
                    if(t.Subject.indexOf('[') != -1)
                        t.Subject = t.Subject.substring(0,t.Subject.indexOf('['));
                    em.add(t);
                }
                emailMessages =eM;
            }
        }
        
        public void getTasks(){
            if(this.contactId != ''){
                callTasks = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' and WhoId =: contactId ORDER BY createddate DESC];
            }
            else if(this.leadId != ''){
                callTasks = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' and WhoId =: leadId ORDER BY createddate DESC];
            }
        }
        
    }
    
    public class messagingWrapper{
        @AuraEnabled 
        public MessagingSession messagingSession;
        @AuraEnabled
        public String messagingSessionData;
        
        messagingWrapper(MessagingSession messagingSession, String messagingSessionData){
            this.messagingSession = messagingSession;
            this.messagingSessionData = messagingSessionData;
        }
        
    }
}