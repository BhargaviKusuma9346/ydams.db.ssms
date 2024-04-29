
CREATE procedure [dbo].[spDeleteMedications] 
  @MedicationGuid uniqueIdentifier,
  @UserGuid uniqueIdentifier=null

AS        
      
/*
 exec [dbo].[spDeleteMedications]    @MedicationGuid='5AF7A25F-C2D5-4146-93A1-48DC42117BA2',@UserGuid='null'
 -------------------------------------------------------------              
	select * from [Lookup].[Medications] where IsDeleted=1

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Medications
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

/*Declaration */
DECLARE @CreatedByUserId INT,@UserTypeId INT
SELECT @CreatedByUserId=UserId,@UserTypeId=UserTypeId  from dbo.Users where UserGuid=@UserGuid

/*Main Query */ 
    UPDATE
	     Lookup.Medications
	SET
	     IsDeleted=1
	WHERE
	     Guid = @MedicationGuid and (CreatedByUserId=@CreatedByUserId or @UserTypeId='1')


SET NOCOUNT OFF

END
