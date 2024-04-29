
CREATE procedure [dbo].[spDeleteInvestigations] 
  @InvestigationGuid uniqueIdentifier,
  @UserGuid uniqueIdentifier=null

AS        
      
/*
 exec [dbo].[spDeleteInvestigations]    @InvestigationGuid='15E461C5-2A5C-4344-934D-1B231A8DE79A', @UserGuid=null
 -------------------------------------------------------------              
	select * from [Lookup].[Investigations] where IsDeleted=1

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Investigations
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
	     Lookup.Investigations
	SET
	     IsDeleted=1
	WHERE
	     Guid = @InvestigationGuid and (CreatedByUserId=@CreatedByUserId or @UserTypeId='1')


SET NOCOUNT OFF

END
