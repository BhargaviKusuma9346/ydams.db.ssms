CREATE procedure [dbo].[spAdminDeleteRequests] 
  @DeleteRequestGuid uniqueIdentifier=null,
  @DeletedByUserGuid uniqueIdentifier
  
AS        
      
/*
 exec [dbo].[spAdminDeleteRequests]  @DeleteRequestGuid='E003271C-6EF3-4AEC-A807-8E586B4BD113',@DeletedByUserGuid=''
 -------------------------------------------------------------              
    select * from [Doctor].[Doctor] where IsDeleted=1
	select * from [mapping].[DoctorLanguages]
	
 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   Ravali           created
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON
DECLARE @UserId int,@DeletedByUserId int,@PatientId int,@RequestedForUserId int
DECLARE @UserName nvarchar(max),@DeletedByUserName nvarchar(max)
DECLARE @UserGuid uniqueidentifier
DECLARE @RelationId int

SELECT @RequestedForUserId=RequestedForUserId,@PatientId=PatientId from dbo.deleterequests where Guid=@DeleteRequestGuid
SELECT @UserGuid=UserGuid,@UserId=UserId,@UserName=CONCAT_WS(' ', FirstName, LastName) from dbo.users where UserId=@RequestedForUserId and IsDeleted=0
SELECT @DeletedByUserId=UserId,@DeletedByUserName=CONCAT_WS(' ', FirstName, LastName) from dbo.users where UserGuid=@DeletedByUserGuid and IsDeleted=0


IF EXISTS (SELECT 1 FROM Doctor.Doctor WHERE UserId = @UserId AND IsDeleted = 0)
	BEGIN
		UPDATE
			 Doctor.Doctor
		SET
			 IsDeleted=1,IsAvailable=0
		WHERE
			 UserId=@UserId

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
			 UserGuid=@UserGuid

	END
ELSE IF EXISTS (SELECT 1 FROM Patient.Patient WHERE Id = @PatientId AND IsDeleted = 0)
	BEGIN 
	  SET @RelationId=(SELECT RelationId FROM Patient.Patient WHERE Id = @PatientId)
		  IF @RelationId IS NULL
			  BEGIN
				UPDATE
					dbo.Users
				SET
					IsDeleted=1
				WHERE
					 UserId=@UserId

				UPDATE
					Patient.Patient
				SET
					IsDeleted=1
				WHERE
					 UserId=@UserId
			   END
		UPDATE
			Patient.Patient
		SET
			IsDeleted=1
		WHERE
			Id=@PatientId
END
BEGIN
	UPDATE 
		 dbo.DeleteRequests
	SET 
		IsAccepted=1 ,ModifiedName=@DeletedByUserName,ModifiedDt=GETDATE(),ModifiedBy=@DeletedByUserId,IsDeleted=1
	where 
		Guid = @DeleteRequestGuid

END


SET NOCOUNT OFF

END
GO

