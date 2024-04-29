CREATE PROCEDURE [Doctor].[spSaveDoctor]
     @DoctorGuid uniqueidentifier = null
    ,@FirstName varchar(200)
    ,@LastName varchar(200)
    ,@Gender varchar(200)
    ,@DateOfBirth datetime
    ,@ProfileURL varchar(200)
	,@SignURL varchar(200)
    ,@QualificationUDT [Doctor].[QualificationUDT] READONLY
    ,@SpecializationUDT [Doctor].[SpecializationUDT] READONLY
	,@LanguagesUDT [dbo].[LanguagesUDT] READONLY
    ,@ContactNumber varchar(200)
    ,@EmailId varchar(max)
    ,@City varchar(200)
    ,@State varchar(200)
    ,@Pincode int
    ,@Address varchar(200)
    ,@RegistrationNumber varchar(200)
    ,@StateOfRegistration varchar(200)
    ,@RegistrationDate datetime
    ,@RegistrationValidity datetime
    ,@PracticeStartDate datetime
	,@AlternateNumber varchar(200)
	,@ConsultationFee varchar(200)
	,@UserName varchar(max)

 AS

/*

 MODIFICATIONS
 select * from  [Doctor].[Doctor] order by 1 desc
 select * from [Doctor].[Doctor] where GUID='1E7AE986-C4CB-446E-B68B-F87A7216364C'
 select * from [mapping].[DoctorLanguages] where doctorid='9105'
 select * from [mapping].[DoctorEducation]
 select * from [Lookup].[Languages]
 select * from [Lookup].[DrQualification]
 select * from [Lookup].[DrSpecialization]

 DECLARE @LanguagesUDT [dbo].[LanguagesUDT]
 DECLARE @QualificationUDT [Doctor].[QualificationUDT]
 DECLARE @SpecializationUDT [Doctor].[SpecializationUDT]

 insert into @LanguagesUDT values('9760dbaa-3785-4248-9018-d30d2630d15e')
 insert into @QualificationUDT values('ef82d9e6-cfe1-4b72-a25b-03a192560e74')
 insert into @SpecializationUDT values('6d3690f5-d9d0-4654-bfde-b74a30cf162d')
 
 exec [Doctor].[spSaveDoctor]
             @DoctorGuid='bf9833a2-c22f-4ed3-9b86-17fd936565e2'
            ,@FirstName ='vinay'
			,@LastName ='dashsari' 
			,@Gender  ='male'
			,@DateOfBirth  ='1975-9-18'
			,@ProfileURL  ='https://hiremeus.s3.amazonaws.com/users/profile/imagesmedical-team.png'
			,@SignURL ='https://hiremeus.s3.amazonaws.com/users/profile/images/01.png'
			,@QualificationUDT = @QualificationUDT
			,@SpecializationUDT  = @SpecializationUDT
			,@LanguagesUDT = @LanguagesUDT 
			,@ContactNumber  ='7890048908'
			,@EmailId  ='vinay@gmail.com'
			,@City  ='Nagpur'
			,@State  ='Maharashtra'
			,@Pincode  =346345
			,@Address  ='hyderabad'
			,@RegistrationNumber  ='43432443243453'
			,@StateOfRegistration  ='Madhya Pradesh'
			,@RegistrationDate  ='2023-11-5'
			,@RegistrationValidity  ='2028-5-18'
			,@AlternateNumber	 ='6565655665'
			,@PracticeStartDate  = '2023-11-5'
			,@ConsultationFee = 2009
			,@UserName = 'vinay@gmail.com'
			
 Date					Author				Description          
 -----------------------------------------------------------------------------
 07/04/2023			M Chandrani           Addition of Doctors
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @LanguageNames varchar(max)
DECLARE @Qualifications varchar(max)
declare @Specializations varchar(max)
DECLARE @OutputId TABLE (DoctorId INT); 

DECLARE @Languages TABLE(Languages varchar(max))
        insert into @Languages
		SELECT  
             ll.Languages as Languages
        FROM	          
	        [Lookup].[Languages] ll WITH(NOLOCK,READUNCOMMITTED)
			 inner join @LanguagesUDT ludt
	         on 
	         ll.Guid=ludt.LanguageGuid 
        WHERE 
	       ll.IsDeleted=0 

		SELECT @LanguageNames= STRING_AGG(Languages,',') FROM @Languages

DECLARE @Qualification TABLE(Qualification varchar(max))
        insert into @Qualification
		SELECT  
             dq.QualificationName as Qualification
        FROM	          
	        [Lookup].[DrQualification] dq WITH(NOLOCK,READUNCOMMITTED)
			 inner join @QualificationUDT qudt
	         on 
	         dq.Guid=qudt.QualificationGuid 
        WHERE 
	       dq.IsDeleted=0 

		SELECT @Qualifications= STRING_AGG(Qualification,',') FROM @Qualification


DECLARE @Specialization TABLE(Specialization varchar(max))
        insert into @Specialization
		SELECT  
             ds.SpecializationName as Specialization
        FROM	          
	        [Lookup].[DrSpecialization] ds WITH(NOLOCK,READUNCOMMITTED)
			 inner join @SpecializationUDT sudt
	         on 
	         ds.Guid=sudt.SpecializationGuid 
        WHERE 
	       ds.IsDeleted=0 

		SELECT @Specializations= STRING_AGG(Specialization,',') FROM @Specialization



DECLARE @Id INT 
SELECT @Id=id from [Doctor].[Doctor] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@DoctorGuid


DECLARE @UserId INT
SELECT @UserId=UserId from [dbo].[Users] with(nolock,readuncommitted) WHERE UserName=@UserName and IsDeleted=0

DECLARE @YearOfRegistration INT
SET @YearOfRegistration=YEAR(@RegistrationDate)

/*Main Query */

  MERGE [Doctor].[Doctor] AS trg 
  Using(
        select
             @UserId AS UserId
            ,@FirstName as FirstName
			,@LastName as LastName
			,@Gender as Gender
			,@DateOfBirth as DateOfBirth
			,@ProfileURL as ProfileURL
			,@SignURL as SignURL
			,@Qualifications as Qualification
			,@Specializations as Specialization
			,@LanguageNames as Languages
			,@ContactNumber as ContactNumber
			,@EmailId as EmailId
			,@City as City
			,@State as State
			,@Pincode as Pincode
			,@Address as Address
			,@RegistrationNumber as RegistrationNumber
			,@StateOfRegistration as StateOfRegistration
			,@YearOfRegistration as YearOfRegistration
			,@RegistrationDate as RegistrationDate
			,@RegistrationValidity as RegistrationValidity
			,@PracticeStartDate as PracticeStartDate
			,@AlternateNumber as AlternateNumber
			,@ConsultationFee  as ConsultationFee 
		  ) as src
		  ON  
		    trg.Id =@Id 

	WHEN MATCHED THEN
		 UPDATE 
		   SET		    
             FirstName =src.FirstName
			,LastName =src.LastName
			,Gender =src.Gender
			,DateOfBirth =src.DateOfBirth
			,ProfileURL =src.ProfileURL
			,SignURL=src.SignURL
			,QualificationName =src.Qualification
			,SpecializationName =src.Specialization
			,Languages=src.Languages
			,ContactNumber =src.ContactNumber
			,EmailId =src.EmailId
			,City =src.City
			,State =src.State
			,Pincode =src.Pincode
			,Address =src.Address
			,RegistrationNumber =src.RegistrationNumber
			,StateOfRegistration =src.StateOfRegistration
			,YearOfRegistration =src.YearOfRegistration
			,RegistrationDate =src.RegistrationDate
			,RegistrationValidity =src.RegistrationValidity
			,PracticeStartDate =src.PracticeStartDate
			,AlternateNumber =src.AlternateNumber
			,ConsultationFee =src.ConsultationFee

	 WHEN NOT MATCHED THEN
		insert( 
		     UserId
		    ,FirstName 
			,LastName 
			,Gender 
			,DateOfBirth 
			,ProfileURL 
			,SignURL
			,QualificationName
			,SpecializationName
			,Languages
			,ContactNumber 
			,EmailId 
			,City 
			,State 
			,Pincode 
			,Address 
			,RegistrationNumber 
			,StateOfRegistration 
			,YearOfRegistration 
			,RegistrationDate 
			,RegistrationValidity 
			,PracticeStartDate 
			,AlternateNumber
			,ConsultationFee
		  )
		   values( 
		     @UserId
		    ,@FirstName 
			,@LastName 
			,@Gender 
			,@DateOfBirth 
			,@ProfileURL
			,@SignURL
			,@Qualifications
			,@Specializations
			,@LanguageNames
			,@ContactNumber 
			,@EmailId 
			,@City 
			,@State 
			,@Pincode 
			,@Address 
			,@RegistrationNumber 
			,@StateOfRegistration 
			,@YearOfRegistration 
			,@RegistrationDate 
			,@RegistrationValidity 
			,@PracticeStartDate 
			,@AlternateNumber
			,@ConsultationFee
		)

 		OUTPUT INSERTED.Id INTO @OutputId;
 DECLARE @DoctorId INT
 SET @DoctorId=(SELECT DoctorId FROM @OutputId)
 print @DoctorId

 If Exists(select * from [mapping].[DoctorLanguages] with(nolock,readuncommitted) where DoctorId = @Id and IsDeleted=0)
  
  BEGIN
	 UPDATE 
       [mapping].[DoctorLanguages]
	 SET 
	    Languages= @LanguageNames		
	 WHERE
	    DoctorId =@Id 
  END

 ELSE

     INSERT INTO 
	    [mapping].[DoctorLanguages]
	    (
		  [DoctorId],
          [Languages]

	    )
        VALUES
	    (
		  @DoctorId,
		  @LanguageNames
	     )

 If Exists(select * from [mapping].[DoctorEducation] with(nolock,readuncommitted) where DoctorId = @Id and IsDeleted=0)
  
  BEGIN
     print(@Id)
	 UPDATE 
       [mapping].[DoctorEducation] 
	 SET 
	    Qualification= @Qualifications,
		Specialization= @Specializations
	 WHERE
	    DoctorId =@Id 
  END

 ELSE
 print @DoctorId
     INSERT INTO 
	    [mapping].[DoctorEducation] 
	    (
		  [DoctorId],
          [Qualification],
		  [Specialization]

	    )
        VALUES
	    (
		  @DoctorId,
		  @Qualifications,
		  @Specializations
	    )

BEGIN
UPDATE [dbo].[Users] 
   SET PhoneNumber=@ContactNumber
   Where UserId=@UserId
END

SET NOCOUNT OFF
END
GO

