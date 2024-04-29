CREATE PROCEDURE [Patient].[spScheduleAppointments] 
     @AppointmentGuid  uniqueidentifier=null
    ,@PatientGuid uniqueidentifier
    ,@DoctorGuid uniqueidentifier
	,@CoordinatorUserGuid uniqueidentifier=null
	,@BranchGuid uniqueidentifier=null
	,@AppointmentDate datetime
	,@AppointmentName varchar(200)
	,@Description varchar(200)
	,@IsPatientAttended bit=0
	,@IsDoctorAttended bit=0
	,@IsCoordinatorAttended bit=0
	,@VideoUrl varchar(200)=''
	,@IsRescheduled bit =0
	,@IsConfirmed bit =0
	,@IsDoctorSelected bit=1
 AS
 
/*
select * from [Patient].[Appointment] order by 1 desc 
select * from [Patient].[Patient]
select * from [Doctor].[Doctor]
select * from [Coordinator].[Coordinator]
select * from mapping.patientvitals order by 1 desc

 
exec [Patient].[spScheduleAppointments] 
       @AppointmentGuid=null
      ,@PatientGuid='08274C77-3A27-45EC-AE49-2E003FE82537'
	  ,@DoctorGuid='D6E2CB59-A953-47F4-B127-E87CE51C3AC3'
      ,@CoordinatorUserGuid=null
	  ,@BranchGuid=null
	  ,@AppointmentDate='2023-09-09 15:00:00.000'
	  ,@AppointmentName='Chandrani/Dharani'
	  ,@Description=''
	  ,@IsPatientAttended=0
	  ,@IsDoctorAttended=0
	  ,@IsCoordinatorAttended=0
	  ,@VideoUrl=''
	  ,@IsConfirmed=1

 Date					Author				Description          
 -------------------------------------- ---------------------------------------
03/05/2023			M Chandrani	           Save Patient Appointment information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @PatientId INT,@AppointmentID INT,@PatientName varchar(200),@PhoneNumber varchar(10)
SELECT @PatientId=Id,@PatientName=CONCAT(FirstName,' ',[MiddleName],' ',[LastName]),@PhoneNumber=MobileNumber from [Patient].[Patient] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@PatientGuid

DECLARE @DoctorId INT,@AppointmentDuration INT,@DoctorName varchar(200),@DoctorPhoneNumber varchar(10)
SELECT @DoctorId=id,@AppointmentDuration=AppointmentDurationInMin,@DoctorName= CONCAT(FirstName,' ',LastName),@DoctorPhoneNumber=ContactNumber from [Doctor].[Doctor] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@DoctorGuid

DECLARE @UserId INT
SELECT @UserId=UserId from dbo.Users where UserGuid=@CoordinatorUserGuid

DECLARE @CoordinatorId INT 
SELECT @CoordinatorId=id from [Coordinator].[Coordinator] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and UserId=@UserId
print(@CoordinatorId)

DECLARE @BranchId INT 
SELECT @BranchId=Id from [Lookup].[Branch] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@BranchGuid

DECLARE @Id INT 
SELECT @Id=id from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @SlotStartTime DATETIME,@SlotEndTime DATETIME

DECLARE @Guid uniqueIdentifier
DECLARE @OutputId TABLE (Id INT); 

/*Main Query */

MERGE [Patient].[Appointment] AS trg 
Using (
    SELECT
        @Id as Id,
        @PatientId as PatientId,
        @DoctorId as DoctorId,
        @CoordinatorId as CoordinatorId,
		@BranchId as BranchId,
        @AppointmentDate as AppointmentDate,
        @AppointmentName as AppointmentName,
        @Description as Description,
        @IsPatientAttended as IsPatientAttended,
        @IsDoctorAttended as IsDoctorAttended,
        @IsCoordinatorAttended as IsCoordinatorAttended,
        @VideoUrl as VideoUrl,
        @AppointmentDuration as AppointmentDuration,
        @IsRescheduled as IsRescheduled,
		@IsConfirmed as IsConfirmed,
        @SlotStartTime as SlotStartTime,
        @SlotEndtime as SlotEndTime,
		@IsDoctorSelected as IsDoctorSelected
) as src
ON trg.Id = @Id
WHEN MATCHED THEN
    UPDATE SET
	    DoctorId=@DoctorId,
		CoordinatorId=@CoordinatorId,
		BranchId=@BranchId,
        AppointmentDate = src.AppointmentDate,
        AppointmentName = src.AppointmentName,
        Description = src.Description,
        IsPatientAttended = src.IsPatientAttended,
        IsDoctorAttended = src.IsDoctorAttended,
        IsCoordinatorAttended = src.IsCoordinatorAttended,
        VideoUrl = src.VideoUrl,
        AppointmentDuration = src.AppointmentDuration,
        IsRescheduled = CASE WHEN ((trg.IsRescheduled = 1 OR trg.AppointmentDate <> src.AppointmentDate) and trg.IsConfirmed=1) THEN 1 ELSE src.IsRescheduled END,
        SlotStartTime = CAST(src.AppointmentDate AS TIME),
        SlotEndTime = DATEADD(MINUTE, src.AppointmentDuration, src.AppointmentDate),
		IsConfirmed = src.IsConfirmed,
		IsDoctorSelected = src.IsDoctorSelected
WHEN NOT MATCHED THEN
    INSERT (
        PatientId,
        DoctorId,
        CoordinatorId,
		BranchId,
        AppointmentDate,
        AppointmentName,
        Description,
        IsPatientAttended,
        IsDoctorAttended,
        IsCoordinatorAttended,
        VideoUrl,
        AppointmentDuration,
        IsRescheduled,
        SlotStartTime,
        SlotEndTime,
		IsDoctorSelected,
		IsConfirmed
    )
    VALUES (
        @PatientId,
        @DoctorId,
        @CoordinatorId,
		@BranchId,
        @AppointmentDate,
        @AppointmentName,
        @Description,
        @IsPatientAttended,
        @IsDoctorAttended,
        @IsCoordinatorAttended,
        @VideoUrl,
        @AppointmentDuration,
        '0',
        CAST(@AppointmentDate AS TIME),
        DATEADD(MINUTE, @AppointmentDuration, CAST(@AppointmentDate AS DATETIME)),
		@IsDoctorSelected,
		@IsConfirmed
    )
	OUTPUT INSERTED.Id INTO @OutputId;
SELECT @Id=(SELECT Id FROM @OutputId)

SELECT @Guid=Guid,@AppointmentId=Id from [Patient].[Appointment] where Id=@Id
print(@AppointmentId)

IF NOT EXISTS (SELECT 1 FROM [mapping].[PatientVitals] WHERE AppointmentId = @AppointmentId)
BEGIN
Insert into [mapping].[PatientVitals](AppointmentId, PatientId, VitalId, VitalName, VitalValue)
SELECT 
    @AppointmentID,
    pp.Id as PatientId,
    mpv.VitalId,
    mpv.VitalName,
    mpv.VitalValue
FROM
    [Patient].[Patient] pp WITH(NOLOCK, READUNCOMMITTED)
INNER JOIN
    [mapping].[PatientVitals] mpv WITH(NOLOCK, READUNCOMMITTED) ON mpv.PatientId = pp.Id
INNER JOIN
    (
        SELECT PatientId, MAX(LastUpdatedTime) AS MaxLastUpdatedTime
        FROM [mapping].[PatientVitals]
        GROUP BY PatientId
    ) maxvital ON mpv.PatientId = maxvital.PatientId AND mpv.LastUpdatedTime = maxvital.MaxLastUpdatedTime
WHERE
    pp.IsDeleted = 0
    AND 
	mpv.IsDeleted = 0
	AND
	pp.Id = @PatientId
	AND
	CAST(mpv.LastUpdatedTime AS DATE) = CAST(GETDATE() AS DATE)

END

SELECT @Guid as AppointmentGuid,@AppointmentDate as AppointmentDate,@DoctorName as DoctorName,@PatientName as PatientName,@PhoneNumber as PhoneNumber,@DoctorPhoneNumber as DoctorPhoneNumber

SET NOCOUNT OFF
END
GO

