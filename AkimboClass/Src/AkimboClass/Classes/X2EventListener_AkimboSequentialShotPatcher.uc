class X2EventListener_AkimboSequentialShotPatcher extends X2EventListener config(Game); //All of this is created by Robojumper

var config array<name> Abilities;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateSequentialShotPatcherTemplate());

	return Templates;
}



static function X2EventListenerTemplate CreateSequentialShotPatcherTemplate()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'FSS_SequentialShotListener');

	Template.RegisterInTactical = true;
	Template.AddEvent('AbilityActivated', OnAbilityActivated);

	return Template;
}

static function EventListenerReturn OnAbilityActivated(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

	if (AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)
		return ELR_NoInterrupt;

	if (default.Abilities.Find(AbilityContext.InputContext.AbilityTemplateName) == INDEX_NONE)
		return ELR_NoInterrupt;

	if (AbilityContext.PostBuildVisualizationFn.Find(PatchSequentialShots_PostBuildVisualization) == INDEX_NONE)
	{
		AbilityContext.PostBuildVisualizationFn.AddItem(PatchSequentialShots_PostBuildVisualization);
	}
	return ELR_NoInterrupt;
}


simulated function PatchSequentialShots_PostBuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateVisualizationMgr VisMgr;
	local X2Action_MarkerNamed MarkerNamed, JoinMarker;
	local array<X2Action> arrActions, ParentsToKeep;
	local int i;
	local XComGameStateContext_Ability AbilityContext;
	local StateObjectReference ShooterRef;

	VisMgr = `XCOMVISUALIZATIONMGR;

	// at this point, the VisualizationTree is the global tree with any other potential previous shots
	// BuildTree contains the current tree
	// we are only interested in the current tree
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_MarkerNamed', arrActions);
	
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	ShooterRef = AbilityContext.InputContext.SourceObject;

	// find the last (deepest) join marker. If this turns out to return the wrong node, fix this
	for (i = arrActions.Length - 1; i >= 0; --i)
	{
		MarkerNamed = X2Action_MarkerNamed(arrActions[i]);
		if (MarkerNamed.MarkerName == 'Join')
		{
			JoinMarker = MarkerNamed;
			break;
		}
	}
	if (JoinMarker != none)
	{
		for (i = JoinMarker.ParentActions.Length - 1; i >= 0; --i)
		{
			if (JoinMarker.ParentActions[i].Metadata.StateObject_NewState != none && JoinMarker.ParentActions[i].Metadata.StateObject_NewState.GetReference() == ShooterRef)
			{
				// this action is a good parent -- it's the shooter of the ability
				ParentsToKeep.AddItem(JoinMarker.ParentActions[i]);
			}
		}
		// if we have any good parents, disconnect the join marker and connect it to the parents we chose
		// it would be a terrible idea to disconnect it from the tree with no nodes to connect it to again, and we really don't want to rely on the heuristic ;)
		if (ParentsToKeep.Length > 0)
		{
			VisMgr.DisconnectAction(JoinMarker);
			// per code comments, this should just add it as a child of ParentsToKeep. I am not sure what ReparentChildren does, but leaving it off seems like a good idea
			VisMgr.ConnectAction(JoinMarker, VisMgr.BuildVisTree, false, none, ParentsToKeep);
		}
	}

}