
CREATE procedure [Doctor].[spChangeDoctorAvailability] 
  @UserGuid uniqueIdentifier
  
AS        
      
/*
 exec [Doctor].[spChangeDoctorAvailability]  @UserGuid=''
 -------------------------------------------------------------              
    select * from [Doctor].[Doctor] where IsAvailable=1
	
 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to update DoctorAvailability
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @UserId INT
SELECT @UserId=UserId from dbo.Users where UserGuid=@UserGuid 

UPDATE
	Doctor.Doctor
SET
	IsAvailable = CASE WHEN IsAvailable = 1 THEN 0 ELSE 1 END
WHERE
	UserId=@UserId

	SET NOCOUNT OFF

END
