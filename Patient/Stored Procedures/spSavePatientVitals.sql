CREATE PROCEDURE [Patient].[spSavePatientVitals]
      @AppointmentGuid  uniqueidentifier=null
	 ,@PatientGuid uniqueidentifier=null
     ,@Weight varchar(200)=null
     ,@Height varchar(200)=null
     ,@Systolic varchar(200)=null
     ,@Diastolic varchar(200)=null
     ,@Pulse varchar(200)=null
     ,@SpO2 varchar(200)=null
     ,@Respiratoryrate varchar(200)=null
     ,@Temperature varchar(200)=null
     ,@Randombloodsugar varchar(200)=null

 AS
 
/*
select * from [mapping].[PatientVitals] where PatientGuid='67cc3eb4-75cc-4422-88a8-747956195cf7'  order by 1 desc  
exec [Patient].[spSavePatientVitals]
      @AppointmentGuid = null
	 ,@PatientGuid='08274c77-3a27-45ec-ae49-2e003fe82537'
     ,@Weight = 23
     ,@Height = 2
     ,@Systolic = null
     ,@Diastolic = null
     ,@Pulse = null
     ,@SpO2 = null
     ,@Respiratoryrate = null
     ,@Temperature = null
     ,@Randombloodsugar = null


 Date					Author				Description          
 -----------------------------------------------------------------------------
27/04/2023			M Chandrani	           Save Patient vitals related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */
DECLARE @AppointmentId INT,@PatientId INT,@Id INT 

IF @AppointmentGuid IS NOT NULL
	BEGIN
	SELECT @AppointmentId=id,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid
	END
ELSE
    BEGIN
	SELECT @PatientId=Id from [Patient].[Patient] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@PatientGuid
	END

DECLARE @Vitals TABLE
 (
     AppointmentId INT,
     PatientId INT,
     VitalId INT,
     VitalName VARCHAR(200),
     VitalValue VARCHAR(200)
 )

 INSERT INTO @Vitals (AppointmentId,PatientId,VitalId, VitalName, VitalValue)
    VALUES
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'Weight'), 'Weight', isnull(CAST(@Weight AS VARCHAR(200)),'')),
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'Height'), 'Height', isnull(CAST(@Height AS VARCHAR(200)),'')),
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'Systolic'), 'Systolic', isnull(CAST(@Systolic AS VARCHAR(200)),'')),
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'Diastolic'), 'Diastolic', isnull(CAST(@Diastolic AS VARCHAR(200)),'')),
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'Pulse'), 'Pulse', isnull(CAST(@Pulse AS VARCHAR(200)),'')),
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'SpO2'), 'SpO2', isnull(CAST(@SpO2 AS VARCHAR(200)),'')),
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'Respiratory rate'), 'Respiratoryrate', isnull(CAST(@Respiratoryrate AS VARCHAR(200)),'')),
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'Temperature'), 'Temperature', isnull(CAST(@Temperature AS VARCHAR(200)),'')),
    (@AppointmentId,@PatientId,(SELECT id FROM [Lookup].[Vital] WHERE VitalName = 'Random blood sugar'), 'Randombloodsugar',isnull( CAST(@Randombloodsugar AS VARCHAR(200)),''))

/*Main Query */
MERGE INTO 
      [mapping].[PatientVitals] AS target
USING 
      @Vitals AS source
ON 
    target.VitalId = source.VitalId AND target.AppointmentId=source.Appointmentid
WHEN MATCHED THEN
    UPDATE 
	       SET 
		       target.VitalValue = source.VitalValue,
			   target.LastUpdatedTime=getdate()
WHEN NOT MATCHED BY TARGET AND source.VitalValue IS NOT NULL THEN
    INSERT (AppointmentId, PatientId, VitalId, VitalName, VitalValue,LastUpdatedTime)
    VALUES (COALESCE(source.AppointmentId, @AppointmentId), source.PatientId, source.VitalId, source.VitalName, source.VitalValue,getdate());



SET NOCOUNT OFF
END
GO

