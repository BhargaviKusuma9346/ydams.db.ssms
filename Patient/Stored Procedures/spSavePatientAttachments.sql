CREATE PROCEDURE [Patient].[spSavePatientAttachments]
	   @AppointmentGuid  uniqueidentifier=null
	  ,@PatientGuid uniqueidentifier=null
	  ,@AttachmentTitle varchar(200)
	  ,@AttachmentUrl varchar(500)
 AS
 
/*
select * from [mapping].[PatientAttachments] order by 1 desc

exec [Patient].[spSavePatientAttachments]
      @AppointmentGuid = null,
	  @PatientGuid = '10DCB119-EF04-402E-B2D2-D56C527D9C1C',
      @AttachmentTitle ='cde',
	  @AttachmentUrl  = 'lam'

 Date					Author				Description          
 -----------------------------------------------------------------------------
27/04/2023			M Chandrani	           Save Patient Attachments related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @AppointmentId INT, @PatientId INT,@Id INT

SELECT @AppointmentId = id FROM [Patient].[Appointment] WITH (NOLOCK, READUNCOMMITTED) WHERE IsDeleted = 0 AND guid = @AppointmentGuid

IF @AppointmentGuid IS NULL
	BEGIN
	  SELECT @PatientId = Id FROM [Patient].[Patient] WITH (NOLOCK, READUNCOMMITTED)WHERE IsDeleted = 0 AND guid = @PatientGuid
	  SELECT @Id=Id from [mapping].[PatientAttachments] WITH(NOLOCK,READUNCOMMITTED) WHERE (IsDeleted=0 and AttachmentTitle=@AttachmentTitle) and PatientId=@PatientId
	End
ELSE
    BEGIN
      SELECT @PatientId = PatientId FROM [Patient].[Appointment] WITH (NOLOCK, READUNCOMMITTED) WHERE IsDeleted = 0 AND guid = @AppointmentGuid
      SELECT @Id=Id from [mapping].[PatientAttachments] WITH(NOLOCK,READUNCOMMITTED) WHERE (IsDeleted=0 and AttachmentTitle=@AttachmentTitle) and AppointmentId=@AppointmentId	
	End
print(@PatientId)
print(@Id)
print(@AppointmentId)

/*Main Query */

 MERGE [mapping].[PatientAttachments] AS trg 
  Using (
          select
                  @PatientId as PatientId
                 ,@AppointmentId as AppointmentId
                 ,@AttachmentTitle as AttachmentTitle
				 ,@AttachmentUrl as AttachmentUrl

		     ) as src
		   ON  
		        trg.Id=@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET
			AttachmentUrl = src.AttachmentUrl
		  WHEN NOT MATCHED THEN
		        INSERT
			         (  
					   PatientId
					  ,AppointmentId
					  ,AttachmentTitle
					  ,AttachmentUrl
				     )
			   values(
					   @PatientId
					  ,@AppointmentId
					  ,@AttachmentTitle
					  ,@AttachmentUrl
			        );


SET NOCOUNT OFF
END
GO

