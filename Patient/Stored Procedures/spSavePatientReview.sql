
CREATE PROCEDURE [Patient].[spSavePatientReview]
	   @AppointmentGuid  uniqueidentifier=null
	  ,@NextReviewDate datetime
	  ,@ReviewDoctorGuid uniqueidentifier=null

 AS
 
/*
select * from [Patient].[appointment] order by 1 desc 
exec [Patient].[spSavePatientReview]
       @AppointmentGuid='322bde2d-71c6-42d7-ba5b-1dc8edb68108'
	  ,@NextReviewDate='2023-08-25 11:00:00'
	  ,@ReviewDoctorGuid='694001c7-c0b7-4f47-8fca-c514e1d35590'

 Date					Author				Description          
 -----------------------------------------------------------------------------
27/04/2023			M Chandrani	           Save Patient next review date related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */
DECLARE @AppointmentId INT
DECLARE @ReviewDoctorId INT,@AppointmentDuration INT,@DoctorName VARCHAR(200)
SELECT @ReviewDoctorId=Id,@DoctorName=FirstName,@AppointmentDuration=AppointmentDurationInMin from [Doctor].[Doctor] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@ReviewDoctorGuid

DECLARE @OutputId TABLE (AppointmentId INT); 

DECLARE @PatientId INT,@PreviousAppointmentId INT,@CoordinatorId INT,@BranchId INT 
SELECT @PatientId=PatientId,@PreviousAppointmentId=id,@CoordinatorId=CoordinatorId,@BranchId=BranchId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @PatientName VARCHAR(200)
SELECT @PatientName=FirstName from [Patient].[Patient] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Id=@PatientId

DECLARE @SlotStartTime DATETIME,@SlotEndTime DATETIME
DECLARE @Guid uniqueIdentifier

DECLARE @Id INT
SELECT @Id = Id FROM [Patient].[Appointment] WITH(NOLOCK, READUNCOMMITTED) WHERE PreviousAppointmentId=@PreviousAppointmentId

/*Main Query */

IF @Id IS NULL
BEGIN
	INSERT INTO [Patient].[Appointment](
			PatientId,
			DoctorId,
			CoordinatorId,
			PreviousAppointmentId,
			BranchId,
			AppointmentDate,
			AppointmentName, 
			Description,
			AppointmentDuration,
			VideoUrl,
			SlotStartTime,
			SlotEndTime,
			IsConfirmed
		)
		OUTPUT INSERTED.Id INTO @OutputId
		VALUES (
			@PatientId,
			@ReviewDoctorId,
			@CoordinatorId,
			@PreviousAppointmentId,
			@BranchId,
			@NextReviewDate,
			CONCAT(@DoctorName,'/',@PatientName),
			'Next Diagnosis',
			@AppointmentDuration,
			'',
			CAST(@NextReviewDate AS TIME),
			DATEADD(MINUTE, @AppointmentDuration, CAST(@NextReviewDate AS DATETIME)),
			'1'
		)
  
	SELECT @Id=(Select AppointmentId from @OutputId);
	print(@Id)
	SELECT @Guid=Guid,@AppointmentId=Id,@PreviousAppointmentId=PreviousAppointmentId from [Patient].[Appointment] where Id=@Id
    SELECT @Guid as AppointmentGuid,@AppointmentId as AppointmentId,@PreviousAppointmentId  as PreviousAppointmentId
	BEGIN
      print(@AppointmentId)
	  print(@PreviousAppointmentId)
	  EXECUTE [dbo].[spSavePreviousCaseSheet] @PreviousAppointmentId,@AppointmentId;
	END

 END
ELSE
 BEGIN
	UPDATE [Patient].[Appointment]
	SET	
		AppointmentDate=@NextReviewDate
	   ,DoctorId=@ReviewDoctorId
	   ,SlotStartTime=CAST(@NextReviewDate AS TIME)
	   ,SlotEndTime=DATEADD(MINUTE, @AppointmentDuration, CAST(@NextReviewDate AS DATETIME))
	WHERE
	    Id=@Id
		AND
	    Isdeleted=0
 END

 BEGIN
	UPDATE [Patient].[Appointment]
	SET	
		NextReviewDate=@NextReviewDate
	   ,ReviewDoctorId=@ReviewDoctorId
	WHERE
	    Id=@PreviousAppointmentId
		AND
	    Isdeleted=0
 END

SET NOCOUNT OFF
END




  



