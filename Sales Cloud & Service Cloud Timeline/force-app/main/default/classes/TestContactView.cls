@isTest
public class TestContactView {
    static testMethod void wrapperTestgetContactId(){
        Case c = new Case();
        c.ContactId = '0032w00000JK818AAD';
        c.Status ='New';
        c.Priority = 'Medium';
        INSERT c;
        
        LiveChatTranscript l = new LiveChatTranscript();
        l.ContactId = '0032w00000JK818AAD';
        l.ChatKey = 'Z1234567890fghjk';
        l.LiveChatVisitorId = '5712w000000i9jPAAQ';
        INSERT l;
        
        Task t = new Task();
        t.WhoId = '0032w00000JK818AAD';
        t.Type = 'call';
        t.Status = 'Completed';
        t.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        INSERT t;
        
        
        Task t_e = new Task();
        t_e.WhoId = '0032w00000JK818AAD';
        t_e.Type = 'Email';
        t_e.Status = 'Completed';
        t_e.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        INSERT t_e;
        
        /*MessagingSession m = new MessagingSession();
        m.EndUserContactId = '0032w00000C6g9NAAR';
        INSERT m;*/
        
        Contact cnct = new Contact();
        cnct.FirstName ='Lohit';
        cnct.LastName = 'Krishna';
        cnct.Email = 'lohit.b@salesforce.com';
        cnct.AccountId = '0012w00000M04TUAAZ';
        INSERT cnct;
        
        Task t_e_cnct = new Task();
        t_e_cnct.WhoId = cnct.Id;
        t_e_cnct.Type = 'Email';
        t_e_cnct.Status = 'Completed';
        t_e_cnct.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        INSERT t_e_cnct;
        
        Task t_cnct = new Task();
        t_cnct.WhoId = cnct.Id;
        t_cnct.Type = 'call';
        t_cnct.Status = 'Completed';
        t_cnct.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        INSERT t_cnct;
        
        SocialPost s_cnct = new SocialPost();
        s_cnct.WhoId = cnct.Id;
        s_cnct.Name = 'Test Social Post';
        INSERT s_cnct;
        
        LiveChatTranscript l_cnct = new LiveChatTranscript();
        l_cnct.ContactId = cnct.Id;
        l_cnct.ChatKey = 'Z1234567890fghjk';
        l_cnct.LiveChatVisitorId = '5712w000000i9jPAAQ';
        INSERT l_cnct;
		
		Case c_cnct = new Case();
        c_cnct.ContactId = cnct.Id;
        c_cnct.Status ='New';
        c_cnct.Priority = 'Medium';
        INSERT c_cnct;        
        
        SocialPost s = new SocialPost();
        s.WhoId = '0032w00000JK818AAD';
        s.Name = 'Test Social Post';
        INSERT s;
        
        test.startTest();
        
        GetMultiObjectRecord.Wrapper w = GetMultiObjectRecord.getRecords(c.Id);
        w.getContactId();
        System.assertEquals(w.contactId, '0032w00000JK818AAD');
        System.assertEquals(w.caseList.size(), 1);
        System.assertEquals(w.emailMessages.size(), 1);
        System.assertEquals(w.chatsList.size(), 1);
        System.assertEquals(w.callTasks.size(), 1);
        System.assertEquals(w.socialPosts.size(), 1);
        
		GetMultiObjectRecord.Wrapper w_l = GetMultiObjectRecord.getRecords(l.Id);
        w_l.getContactId();
        System.assertEquals(w_l.contactId, '0032w00000JK818AAD');       
        System.assertEquals(w_l.chatsList.size(), 1);
        System.assertEquals(w_l.emailMessages.size(), 1);
        System.assertEquals(w_l.callTasks.size(), 1);
        System.assertEquals(w_l.socialPosts.size(), 1);
        
        GetMultiObjectRecord.Wrapper w_T = GetMultiObjectRecord.getRecords(t.Id);
        w_T.getContactId();
        System.assertEquals(w_T.contactId, '0032w00000JK818AAD'); 
        System.assertEquals(w_T.callTasks.size(), 1);
        System.assertEquals(w_T.chatsList.size(), 1);
        System.assertEquals(w_T.emailMessages.size(), 1);
        System.assertEquals(w_T.socialPosts.size(), 1);
        
        GetMultiObjectRecord.Wrapper w_C = GetMultiObjectRecord.getRecords(cnct.Id);
        w_C.getContactId();
        System.assertEquals(w_C.contactId, cnct.Id);
        System.assertEquals(w_C.callTasks.size(), 1);
        System.assertEquals(w_C.chatsList.size(), 1);
        System.assertEquals(w_C.emailMessages.size(), 1);
        System.assertEquals(w_C.socialPosts.size(), 1);
        
        GetMultiObjectRecord.Wrapper w_SP = GetMultiObjectRecord.getRecords(s.Id);
        w_SP.getContactId();
        System.assertEquals(w_SP.contactId, '0032w00000JK818AAD');
        System.assertEquals(w_SP.socialPosts.size(), 1);
        System.assertEquals(w_SP.callTasks.size(), 1);
        System.assertEquals(w_SP.chatsList.size(), 1);
        System.assertEquals(w_SP.emailMessages.size(), 1);
        
        test.stopTest();
        
    }
}