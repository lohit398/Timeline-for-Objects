public with sharing class GetMultiObjectRecord {
    @AuraEnabled(cacheable=true)
    public static Wrapper getRecords(String recId){
        String sObjName = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        Wrapper wrapperObject = new Wrapper();
        wrapperObject.recordId = recId;
        wrapperObject.sObjectType = sObjName;
        wrapperObject.getContactId();
        wrapperObject.getCases();
        wrapperObject.getEmails();
        wrapperObject.getTasks();
        
        if(SObjectUtil.isObjectExist('LiveChatTranscript'))
        	wrapperObject.getChatTranscripts();
        if(SObjectUtil.isObjectExist('MessagingSession'))
        	wrapperObject.getConversationEntries();
        if(SObjectUtil.isObjectExist('SocialPost'))
        	wrapperObject.getSocialPosts();
        //System.debug(wrapperObject);
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
        public list<SObject> messagingList = new List<SObject>();
        @AuraEnabled
        public list<SObject> chatsList = new List<SObject>();
        @AuraEnabled
        public String transcriptCompiler ='';
        @AuraEnabled
        public list<messagingWrapper> messaging = new List<messagingWrapper>();
        @AuraEnabled
        public list<Task> emailMessages;
        @AuraEnabled
        public List<Task> callTasks;
        @AuraEnabled
        public List<SObject> socialPosts = new List<SObject>();
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
                String query= 'SELECT ContactId From LiveChatTranscript WHERE Id =\''+String.valueOf(this.recordId)+'\' LIMIT 1';
                SObject chatContact = Database.query(query);
                contactId = String.valueOf(chatContact.get('ContactId'));
                this.leadId = '';
            }
            else if(sObjectType == 'Task') {
                contactId = [SELECT WhoId From Task WHERE Id =: this.recordId LIMIT 1].WhoId;
                this.leadId = '';
            } else if(sObjectType == 'MessagingSession') {
                String query1= 'SELECT EndUserContactId From MessagingSession WHERE Id =\''+String.valueOf(this.recordId)+'\' LIMIT 1';
                SObject messagingContact = Database.query(query1);
                contactId = String.valueOf(messagingContact.get('EndUserContactId'));
                this.leadId = '';
            }
            else if(sObjectType == 'Contact'){
                contactId = [SELECT Id FROM Contact WHERE Id =: this.recordId LIMIT 1].Id;
                this.leadId = '';
            }
            else if(sObjectType == 'SocialPost'){
                String query2 = 'SELECT WhoId From SocialPost WHERE Id =\''+String.valueOf(this.recordId)+'\' LIMIT 1';
                SObject socialPostContact = Database.query(query2);
                contactId = String.valueOf(socialPostContact.get('WhoId'));
                this.leadId = '';
            }
            else if(sObjectType == 'Account'){
                //contactId = [SELECT PersonContactId from Account where Id =: this.recordId LIMIT 1].PersonContactId;
                String query3 = 'SELECT PersonContactId from Account where Id =\''+this.recordId+'\'this.recordId LIMIT 1';
                SObject personAccount = Database.query(query3);
                contactId = String.valueOf(personAccount.get('PersonContactId'));
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
            if(SObjectUtil.isObjectExist('SocialPost')){
                String getSocialPostsQuery = 'select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where WhoId =\'';
                if(this.contactId != ''){
                    //socialPosts = [select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where WhoId = :this.contactId];
                    socialPosts = Database.query(getSocialPostsQuery + this.contactId + '\'');
                }
                else if(this.leadId != ''){
                    //socialPosts = [select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where WhoId = :this.leadId];
                    socialPosts = Database.query(getSocialPostsQuery + this.leadId + '\'');
                }
            }
        }
        
        public  void getChatTranscripts(){
            if(SObjectUtil.isObjectExist('LiveChatTranscript')){
                String getChatsQuery = 'SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where ';
                if(this.contactId != '')
                    chatsList = Database.query(getChatsQuery + 'ContactId = \'' + this.contactId + '\' ORDER BY StartTime DESC');
                else if(this.leadId != '')
                    chatsList = Database.query(getChatsQuery + 'LeadId = \'' + this.leadId + '\' ORDER BY StartTime DESC');
                //chatsList = [SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Lead.Name,CreatedDate from LiveChatTranscript where LeadId=: leadId ORDER BY StartTime DESC];
            }
        }
        
        
        public void getConversationEntries() {
            if(SObjectUtil.isObjectExist('MessagingSession')){
                String query = 'SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate,MessagingEndUserId,MessagingEndUser.Contact.Name from MessagingSession where ';
                if(this.contactId != ''){
                    if(caseId == '' && !remainingRecords){
                     	//this.messagingList = [SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate from MessagingSession where EndUserContactId =: contactId ORDER BY StartTime DESC];
                     	this.messagingList = Database.query(query + 'EndUserContactId = \''+contactId+'\'ORDER BY StartTime DESC');   
                    }    
                    else if(caseId != '' && !remainingRecords){
                        //this.messagingList = [SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate from MessagingSession where CaseId =: caseId ORDER BY StartTime DESC];
                        this.messagingList = Database.query(query + 'CaseId = \''+caseId+'\'ORDER BY StartTime DESC');
                        caseIds.add(caseId);
                    }
                    else if ((caseId != '' && remainingRecords) || (caseId =='' && remainingRecords)){
                        //System.debug(caseIds);
                        //this.messagingList = [SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate from MessagingSession where CaseId NOT IN :caseIds AND  EndUserContactId =: contactId ORDER BY StartTime DESC];
                        String queryRR = 'SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate,MessagingEndUserId,MessagingEndUser.Contact.Name from MessagingSession where CaseId NOT IN :caseIds AND  EndUserContactId =: contactId ORDER BY StartTime DESC';
                        this.messagingList = Database.query(queryRR);
                    }
                    getConversationItemsHelper();
                }
                else if(this.leadId != ''){
                    String queryLead = 'SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate,MessagingEndUserId,MessagingEndUser.Contact.Name from MessagingSession where CaseId NOT IN :caseIds AND  LeadId =\''+leadId+'\' ORDER BY StartTime DESC';
                    //this.messagingList = [SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate from MessagingSession where CaseId NOT IN :caseIds AND  LeadId = :leadId ORDER BY StartTime DESC];
                    this.messagingList = Database.query(queryLead);
                    getConversationItemsHelper();
                }   
            }
        }
        
        public void getConversationItemsHelper(){
            for(Integer i=0;i< this.messagingList.size();i++){
                String getConvQuery = 'SELECT ActorName,ActorType,EntryType,Message FROM ConversationEntry WHERE EntryType = \'Text\' AND ConversationId =\''+messagingList[i].get('Id')+'\'';
                List<SObject> messageEntryItems = Database.query(getConvQuery);
                for (Sobject entry : messageEntryItems) {
                    if (String.valueOf(entry.get('ActorType')) == 'EndUser') {
                        if (String.valueOf(entry.get('Message'))==null) {
                            this.transcriptCompiler = this.transcriptCompiler +this.messagingList[i].getSObject('MessagingEndUser').getSObject('Contact').get('Name') + ': ' + '[Unsupported Object]' + '\n';
                        } else {
                            this.transcriptCompiler = this.transcriptCompiler + this.messagingList[i].getSObject('MessagingEndUser').getSObject('Contact').get('Name') + ': ' + String.valueOf(entry.get('Message')) + '\n';
                        }          
                    }
                    else if(String.valueOf(entry.get('ActorType')) == 'Agent'){
                        this.transcriptCompiler = this.transcriptCompiler + String.valueOf(entry.get('ActorType')) + ': ' + String.valueOf(entry.get('Message')) + '\n';
                    }
                    else if (String.valueOf(entry.get('ActorType')) == 'Bot'){
                        this.transcriptCompiler = this.transcriptCompiler + 'Me: ' + String.valueOf(entry.get('Message')) + '\n';
                    }
                }
                this.messaging.add(new messagingWrapper(this.messagingList[i],this.transcriptCompiler));
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
        public SObject messagingSession;
        @AuraEnabled
        public String messagingSessionData;
        
        messagingWrapper(SObject messagingSession, String messagingSessionData){
            this.messagingSession = messagingSession;
            this.messagingSessionData = messagingSessionData;
        }
        
    }
}