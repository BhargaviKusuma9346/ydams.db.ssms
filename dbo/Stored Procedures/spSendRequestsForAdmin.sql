CREATE procedure [dbo].[spSendRequestsForAdmin]     
    @UserGuid uniqueidentifier,
	@DoctorGuid uniqueidentifier=null,
	@PatientGuid uniqueIdentifier=null,
	@Comments nvarchar(max),
	@IsAccepted bit=0
	AS        
      
/*
 exec [dbo].[spSendRequestsForAdmin] @UserGuid='5ea3279c-22c1-4340-a05c-9110205ae400',@DoctorGuid=null,
 @PatientGuid='3868f5c8-6f25-46c1-bb4f-8b62e17e814c',@Comments='bad',@IsAccepted=0
 -------------------------------------------------------------              
 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
23/06/2023		     Ravali		         Created
 ------------------------------------------------------------------------------      
                Copyright 2023@Hireme
*/        
BEGIN
SET NOCOUNT ON 
DECLARE @UserTypeId INT
DECLARE @RequestedBy nvarchar(max)
DECLARE @RequestedFor nvarchar(max)
DECLARE @IsRequested bit=1
DECLARE @BranchName nvarchar(max)
DECLARE @UserId Int,@RequestedForUserId Int
DECLARE @PatientId Int

SELECT @UserId=UserId FROM dbo.Users WITH(NOLOCK,READUNCOMMITTED) WHERE UserGuid=@UserGuid

SET @RequestedBy =(SELECT  CONCAT(FirstName, ' ', LastName) FROM [dbo].[Users] WITH(NOLOCK,READUNCOMMITTED) WHERE  UserGuid=@UserGuid)

IF @DoctorGuid IS NULL
  BEGIN
	   SELECT @RequestedForUserId=UserId,@RequestedFor=CONCAT(FirstName, ' ', LastName),@BranchName=BranchName,@PatientId=Id FROM [Patient].[Patient] WITH(NOLOCK,READUNCOMMITTED) WHERE Guid =@PatientGuid 
	   SET @UserTypeId=5
  END
ELSE
   BEGIN
	   SELECT @RequestedForUserId=UserId,@RequestedFor=CONCAT(FirstName, ' ', LastName) FROM [Doctor].[Doctor] WITH(NOLOCK,READUNCOMMITTED) WHERE Guid =@DoctorGuid 
	   SET @UserTypeId=3
   END

insert  into  [dbo].[DeleteRequests] (UserTypeId,RequestedForUserId,RequestedFor,RequestedBy,Comments,IsAccepted,IsRequested,BranchName,PatientId) values(@UserTypeId,@RequestedForUserId,@RequestedFor,@RequestedBy,@Comments,@IsAccepted,@IsRequested,@BranchName,@PatientId);


SET NOCOUNT OFF
END
GO

