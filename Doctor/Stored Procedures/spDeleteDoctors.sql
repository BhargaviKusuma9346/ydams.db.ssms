CREATE procedure [Doctor].[spDeleteDoctors] 
  @DoctorGuid uniqueIdentifier,
  @UserGuid uniqueIdentifier
  
AS        
      
/*
 exec [Doctor].[spDeleteDoctors] @DoctorGuid='87D4A28E-0589-474B-A253-6F954F0C388F',@UserGuid='AEA80B99-1D3A-4CBE-AC61-1563630BF7B5'
 -------------------------------------------------------------              
    select * from [Doctor].[Doctor] where IsDeleted=1
	select * from [mapping].[DoctorLanguages]
	
 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Doctors
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @UserId INT,@UserName varchar(100)
SELECT @UserId=UserId,@UserName=CONCAT(FirstName,' ',LastName) from  Doctor.Doctor with(nolock,readuncommitted) WHERE Guid=@DoctorGuid

DECLARE @DeletedByUserId INT,@DeletedBy varchar(100)
SELECT @DeletedByUserId=UserId,@DeletedBy =CONCAT(FirstName,' ',LastName) from  dbo.users with(nolock,readuncommitted) WHERE UserGuid=@UserGuid

	UPDATE
	     Doctor.Doctor
    SET
	     IsDeleted=1,IsAvailable=0
	WHERE
	     Guid=@DoctorGuid

	UPDATE
	     mapping.DoctorLanguages
	SET
	     IsDeleted=1
	WHERE
	     DoctorId IN (Select Id from Doctor.Doctor WHERE Guid=@DoctorGuid)

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
            Values('3',@UserId,@UserName,@DeletedBy,'1','1',@DeletedByUserId,getdate(),@DeletedBy)

SET NOCOUNT OFF

END
GO

