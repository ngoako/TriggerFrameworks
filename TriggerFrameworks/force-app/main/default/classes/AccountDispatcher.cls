public with sharing class AccountDispatcher {
    public static void run(AccountInterface handler, System.TriggerOperation operationType){
        switch on operationType {
            when  BEFORE_INSERT{
                handler.before_insert(Trigger.new);
            }
            when AFTER_INSERT {
                handler.after_Insert(Trigger.new, Trigger.newMap);
            }
            when BEFORE_UPDATE{
                handler.before_update(Trigger.newMap, Trigger.oldMap);
            }
            when AFTER_UPDATE{
                handler.after_update(Trigger.newMap, Trigger.oldMap);
            }
            when BEFORE_DELETE{
                handler.before_delete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_DELETE{
                handler.after_delete(Trigger.oldMap);
            }
            WHEN AFTER_UNDELETE{
                handler.after_UNDELETE(Trigger.new, Trigger.newMap);
            }
        }
    }
}