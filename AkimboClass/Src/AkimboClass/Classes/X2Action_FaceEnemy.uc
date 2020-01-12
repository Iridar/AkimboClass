class X2Action_FaceEnemy extends X2Action_MoveTurn; //this is part of Take Initiative routine; it forces the soldier to turn to each specific enemy he's currently attacking in melee.

simulated state Executing
{
		simulated function bool ShouldTurn()
	{
		local float fDot;

		m_vFaceDir = m_vFacePoint - UnitPawn.Location;
		m_vFaceDir.Z = 0;
		m_vFaceDir = normal(m_vFaceDir);

		fDot = m_vFaceDir dot vector(UnitPawn.Rotation);

		return fDot < 0.9f;
	}

Begin:
	Unit = XGUnit(Metadata.VisualizeActor);
	UnitPawn = Unit.GetPawn();

	//Check to see whether we are in the middle of a run that has been interrupted
	if (!PerformingInterruptedMove())
	{
		if(UpdateAimTarget && UnitPawn.GetAnimTreeController().GetAllowNewAnimations())
		{
			UnitPawn.TargetLoc = m_vFacePoint;
		}

		if(ShouldTurn())
		{
			FinishAnim(UnitPawn.StartTurning(UnitPawn.Location + m_vFaceDir*vect(1000, 1000, 0)));
		}

		if (ForceSetPawnRotation)
		{
			UnitPawn.SetRotation(Rotator(m_vFaceDir));
		}

		UnitPawn.Acceleration = vect(0, 0, 0);

		if(!Unit.IsMine()) // Debug code to show alien's last facing direction before action completed.
			Unit.m_kBehavior.SetDebugDir(Vector(UnitPawn.Rotation), , true);
		// done!
	}	
	CompleteAction();
}
