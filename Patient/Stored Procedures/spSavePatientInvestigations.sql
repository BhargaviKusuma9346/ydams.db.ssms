
CREATE PROCEDURE [Patient].[spSavePatientInvestigations]
     @AppointmentGuid uniqueIdentifier=null
	,@InvestigationsUDT [dbo].[InvestigationsUDT] READONLY

 AS

/*

 MODIFICATIONS
 select * from mapping.PatientInvestigations

 DECLARE @InvestigationsUDT [dbo].[InvestigationsUDT]

 insert into @InvestigationsUDT values('Stool Culture')
 
 exec [Patient].[spSavePatientInvestigations]
             @AppointmentGuid='CE4D4710-BF03-48F9-92CC-79210F06CBD0'
			,@InvestigationsUDT = @InvestigationsUDT
			
 Date					Author				Description          
 -----------------------------------------------------------------------------
 07/04/2023			M Chandrani	           Additions of Investigations For Patients
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @InvestigationsNames varchar(max)

DECLARE @Investigations TABLE(Investigations varchar(max))
        insert into @Investigations
		SELECT  
             test_name as Investigations
        FROM	          
	        @InvestigationsUDT ludt

		SELECT @InvestigationsNames= STRING_AGG(Investigations,';') FROM @Investigations

DECLARE @AppointmentId INT,@DoctorId INT,@PatientId INT  
SELECT @AppointmentId=id,@DoctorId=DoctorId,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @Id INT
SELECT @Id=id from [mapping].[PatientInvestigations] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and AppointmentId=@AppointmentId



/*Main Query */

  MERGE [mapping].[PatientInvestigations] AS trg 
  Using(
        select
             @Id as Id,
             @AppointmentId as AppointmentId
			,@DoctorId as DoctorId
			,@PatientId as PatientId
			,@InvestigationsNames as Investigations
		  ) as src
		  ON  
		    trg.Id =@Id 

	WHEN MATCHED THEN
		 UPDATE 
		   SET		    
              Investigations=src.Investigations

	 WHEN NOT MATCHED THEN
		insert(
		    AppointmentId
		    ,PatientId
			,DoctorId
			,Investigations
		  )
		   values( 
		      @AppointmentId
			 ,@PatientId
			 ,@DoctorId
			 ,@InvestigationsNames
		);

SET NOCOUNT OFF
END




  



