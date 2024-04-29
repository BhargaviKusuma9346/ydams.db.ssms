CREATE procedure [Patient].[spDeletePatients] 
  @PatientGuid uniqueIdentifier,
  @UserGuid uniqueIdentifier
  
AS        
      
/*
 exec [Patient].[spDeletePatients]  @PatientGuid='669689A3-8F69-4111-9069-F5FD101ACF7F',@UserGuid='AEA80B99-1D3A-4CBE-AC61-1563630BF7B5'
 -------------------------------------------------------------              
    select * from [Patient].[Patient] where IsDeleted=1
	select * from [mapping].[PatientVitals] where IsDeleted=1

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Patients
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @UserId INT,@RelationId INT,@UserName varchar(100)
SELECT @UserId=UserId ,@RelationId=RelationId,@UserName=CONCAT(FirstName,' ',LastName) from  Patient.Patient with(nolock,readuncommitted) WHERE Guid=@PatientGuid

DECLARE @DeletedByUserId INT,@DeletedBy varchar(100)
SELECT @DeletedByUserId=UserId,@DeletedBy =CONCAT(FirstName,' ',LastName) from  dbo.users with(nolock,readuncommitted) WHERE UserGuid=@UserGuid

	UPDATE
	     Patient.Patient
    SET
	     IsDeleted=1
	WHERE
	     Guid=@PatientGuid

    UPDATE
	     mapping.PatientVitals
	SET
	     IsDeleted=1
	WHERE
	     PatientId IN (Select Id from Patient.Patient WHERE Guid=@PatientGuid)
IF @RelationId IS NULL
BEGIN
    UPDATE
	     dbo.Users
    SET
	     IsDeleted=1
	WHERE
	     UserId=@UserId
END
BEGIN
  insert into dbo.DeleteRequests(UserTypeId,RequestedForUserId,RequestedFor,RequestedBy,IsAccepted,IsDeleted,ModifiedBy,ModifiedDt,ModifiedName)
            Values('5',@UserId,@UserName,@DeletedBy,'1','1',@DeletedByUserId,getdate(),@DeletedBy)
END
SET NOCOUNT OFF

END
GO

