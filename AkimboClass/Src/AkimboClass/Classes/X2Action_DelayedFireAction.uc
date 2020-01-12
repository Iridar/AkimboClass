class X2Action_DelayedFireAction extends X2Action_Fire; //NOT IN USE CURRENTLY

var float ActionTimer;

simulated state Executing
{
    simulated event Tick(float fDeltaT)
    {
        ActionTimer += fDeltaT;
    }
Begin:
    while(ActionTimer < NotifyTargetTimer)
    {
        Sleep(0.0f);
    }
    
    NotifyTargetsAbilityApplied();
    CompleteAction();
}

DefaultProperties
{
    NotifyTargetTimer = 1.4f;
}