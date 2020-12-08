public class SObjectUtil {
	
    public static boolean isObjectExist(String ObjectNameParam){
     for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
        String sobjName = String.valueOf(sObjectType);
        if (sobjName.contains(ObjectNameParam) ) {
            return true;
        }
     }
     return false;
   }
    
}