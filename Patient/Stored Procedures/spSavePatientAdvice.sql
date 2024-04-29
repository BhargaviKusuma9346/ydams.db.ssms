CREATE PROCEDURE [Patient].[spSavePatientAdvice]
	   @AppointmentGuid  uniqueidentifier=null
	  ,@Advice varchar(MAX)

 AS
 
/*
select * from [mapping].[PatientAdvice] order by 1 desc 
exec [Patient].[spSavePatientAdvice]
       @AppointmentGuid='CB1F789A-BA4D-4DBF-AD75-0145AF5F9152'
	  ,@Advice='abc'

 Date					Author				Description          
 -----------------------------------------------------------------------------
27/04/2023			M Chandrani	           Save PatientAdvice related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @AppointmentId INT,@Id INT

SELECT @AppointmentId=id from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

SELECT @Id=Id from [mapping].[PatientAdvice] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and AppointmentId=@AppointmentId


/*Main Query */

    
  MERGE [mapping].[PatientAdvice] AS trg 
  Using (
          select
		          @Id as Id
                 ,@AppointmentId as AppointmentId
                 ,@Advice as Advice

		     ) as src
		   ON  
		        trg.Id=@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET	
		          Advice=src.Advice
			    
		  WHEN NOT MATCHED THEN
		        INSERT
			         (  
					   AppointmentId
                      ,Advice
				     )
			   values(
					   @AppointmentId
                      ,@Advice
			        );

SET NOCOUNT OFF
END
GO

