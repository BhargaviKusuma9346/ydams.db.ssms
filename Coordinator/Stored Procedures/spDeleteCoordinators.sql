CREATE procedure [Coordinator].[spDeleteCoordinators] 
  @CoordinatorGuid uniqueIdentifier,
  @UserGuid uniqueIdentifier
  
AS        
      
/*
 exec [Coordinator].[spDeleteCoordinators]   @CoordinatorGuid='8BCA80E4-E222-4FEB-A6B7-268D47E65314',@UserGuid='AEA80B99-1D3A-4CBE-AC61-1563630BF7B5'
 -------------------------------------------------------------              
    select * from [Coordinator].[Coordinator] where IsDeleted=1
	
 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Coordinators
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @UserId INT,@UserName varchar(100)
SELECT @UserId=UserId,@UserName=CONCAT(FirstName,' ',LastName) from  Coordinator.Coordinator with(nolock,readuncommitted) WHERE Guid=@CoordinatorGuid

DECLARE @DeletedByUserId INT,@DeletedBy varchar(100)
SELECT @DeletedByUserId=UserId,@DeletedBy =CONCAT(FirstName,' ',LastName) from  dbo.users with(nolock,readuncommitted) WHERE UserGuid=@UserGuid


	UPDATE
	     Coordinator.Coordinator
	SET
	     IsDeleted=1
	WHERE
	     Guid = @CoordinatorGuid

	UPDATE
	     dbo.Users
    SET
	     IsDeleted=1
	WHERE
	     UserId=@UserId

	UPDATE
	     dbo.PasswordHistory
    SET
	     IsDeleted=1
	WHERE
	     UserGuid IN (Select UserGuid from dbo.users WHERE UserId=@UserId)

insert into dbo.DeleteRequests(UserTypeId,RequestedForUserId,RequestedFor,RequestedBy,IsAccepted,IsDeleted,ModifiedBy,ModifiedDt,ModifiedName)
            Values('2',@UserId,@UserName,@DeletedBy,'1','1',@DeletedByUserId,getdate(),@DeletedBy)

SET NOCOUNT OFF

END
GO

