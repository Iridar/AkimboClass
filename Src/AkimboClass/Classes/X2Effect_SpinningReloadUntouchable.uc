class X2Effect_SpinningReloadUntouchable extends X2Effect_Untouchable;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;

	EventMgr.RegisterForEvent(EffectObj, 'Parry', EffectGameState.UntouchableCheck, ELD_OnStateSubmitted);
}