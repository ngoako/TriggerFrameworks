public with sharing class AccountHandler implements AccountInterface{
    public static void before_insert(List<sObject> newRecordsList){
        AccountHelper.updateRating((List<Account>) newRecordsList);
        AccountHelper.copyBillingToShipping((List<Account>) newRecordsList);
    }
    public static void after_insert(List<sObject> newRecordsList, map<Id,sObject> newRecordsMap){
        AccountHelper.createRelatedContact((List<Account>) newRecordsList);
        AccountHelper.createRelatedOpportunity((List<Account>) newRecordsList);
    }
    public static void before_update(map<Id,sObject> newRecordsMap, map<Id,sObject> oldRecordsMap){

    }
    public static void after_update(map<Id,sObject> newRecordsMap, map<Id,sObject> oldRecordsMap){

    }
    public static void before_delete(List<sObject> oldRecordsList, map<Id,sObject> oldRecordsMap){
    
    }

    public static void after_delete(map<Id,sObject> oldRecordsMap){

    }

    public static void after_undelete(List<sObject> newRecordsList, map<Id,sObject> newRecordsMap){
    
    }
}