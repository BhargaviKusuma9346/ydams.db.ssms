CREATE PROCEDURE [Patient].[spSavePatient]
     @PatientGuid  uniqueidentifier=null
    ,@Title varchar (200)
    ,@FirstName varchar(200)
	,@MiddleName varchar(200)
    ,@LastName varchar(200)
	,@CountryCode varchar(200)='+91'
	,@MobileNumber varchar(50)
	,@AlternateMobileNumber varchar(50)
	,@Email varchar(max)
    ,@Gender varchar(200)
    ,@DateOfBirth datetime
	,@AddressProofTypeGuid uniqueidentifier=null
	,@IdentificationNumber varchar(200)=null
	,@MaritalStatus varchar(200) =null
	,@OccupationGuid uniqueidentifier=null
    ,@ReligionGuid uniqueidentifier=null
    ,@IncomeGroupGuid uniqueidentifier=null
    ,@EducationGuid uniqueidentifier=null
    ,@BloodGroup varchar(200) =null
    ,@RelationshipTypeGuid uniqueidentifier=null
    ,@RelationName varchar(200)=null
    ,@MothersMaidenName varchar(200)
    ,@CityGuid uniqueidentifier
    ,@StateGuid uniqueidentifier
    ,@Address1 varchar(200)
	,@Address2 varchar(200)
	,@PatientPhotoUrl varchar(200)
	,@CreatedByUserGuid uniqueidentifier=null
	,@BranchGuid uniqueidentifier=null

 AS
 
/*
select * from [Patient].[Patient] where Guid='DF753665-CB54-4EAF-8BDC-52D9409F5DED'

exec [Patient].[spSavePatient] 
     @PatientGuid='DF753665-CB54-4EAF-8BDC-52D9409F5DED'
    ,@Title='Mrs'
    ,@FirstName='Masdfghafj'
    ,@MiddleName='abc'
    ,@LastName='Madhira'
    ,@CountryCode='+91'
    ,@MobileNumber='7983395875'
    ,@AlternateMobileNumber='45657890123'
    ,@Email='mithra@gmail.com'
    ,@Gender='Female'
    ,@DateOfBirth='10-06-1999'
    ,@AddressProofTypeGuid='C4C59CE3-15E8-4082-9775-78C132358D82'
    ,@IdentificationNumber='36873829233398'
    ,@MaritalStatus='Single'
    ,@OccupationGuid=null
    ,@ReligionGuid='83908CA0-9338-452B-A519-5F660B3AFFED'
    ,@IncomeGroupGuid=null
    ,@EducationGuid='C29DCC76-87AE-41FC-A5C8-0C2CE2AADE82'
    ,@BloodGroup='B-'
    ,@RelationshipTypeGuid=null
    ,@RelationName=''
    ,@MothersMaidenName='P'
    ,@CityGuid=null
    ,@StateGuid=null
    ,@Address1='5-37,Guntur'
    ,@Address2='Palnadu'
    ,@PatientPhotoUrl='abc.com'
    ,@CreatedByUserGuid='8b7ea0d2-92ca-4aac-931c-3f256da23e37'
	,@BranchGuid=null

 Date					Author				Description          
 -----------------------------------------------------------------------------
19/04/2023			M Chandrani	           Save Patient related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */
DECLARE @AddressProofTypeId INT 
DECLARE @AddressProofType  varchar(max)
SELECT @AddressProofTypeId=id,@AddressProofType=AddressProofType from [Lookup].[AddressProofType] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@AddressProofTypeGuid

DECLARE @OccupationId INT 
DECLARE @OccupationName  varchar(max)
SELECT @OccupationId=id,@OccupationName=OccupationName from [Lookup].[Occupation] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@OccupationGuid

DECLARE @ReligionId INT 
DECLARE @ReligionName  varchar(max)
SELECT @ReligionId=id,@ReligionName=ReligionName from [Lookup].[Religion] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@ReligionGuid

DECLARE @IncomeGroupId INT 
DECLARE @IncomeGroupName  varchar(max)
SELECT @IncomeGroupId=id,@IncomeGroupName=IncomeGroupName from [Lookup].[IncomeGroup] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@IncomeGroupGuid

DECLARE @EducationId INT 
DECLARE @EducationName  varchar(max)
SELECT @EducationId=id,@EducationName=EducationName from [Lookup].[Education] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@EducationGuid

DECLARE @RelationshipTypeId INT 
DECLARE @RelationshipType  varchar(max)
SELECT @RelationshipTypeId=id,@RelationshipType=RelationshipType from [Lookup].[RelationshipType] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@RelationshipTypeGuid

DECLARE @CityId INT 
DECLARE @CityName  varchar(max)
SELECT @CityId=id,@CityName=CityName from [Lookup].[City] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@CityGuid

DECLARE @StateId INT 
DECLARE @StateName  varchar(max)
SELECT @StateId=id,@StateName=StateName from [Lookup].[State] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@StateGuid

DECLARE @Id INT 
SELECT @Id=id from [Patient].[Patient] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and guid=@PatientGuid

DECLARE @BranchName varchar(200)
SELECT @BranchName=BranchName from [Lookup].[Branch] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@BranchGuid

DECLARE @UserId INT
SELECT @UserId=UserId from dbo.Users where PhoneNumber=@MobileNumber

DECLARE @ModifiedName varchar(100)
DECLARE @ModifiedDt datetime
DECLARE @ModifiedBy INT

DECLARE @CreatedByUserId INT,@CreatedByFirstName varchar(100)
SELECT @CreatedByUserId=UserId,@CreatedByFirstName=FirstName from dbo.Users where UserGuid=@CreatedByUserGuid

/*Main Query */
			

  MERGE [Patient].[Patient] AS trg 
  Using (
          select
                  @Id as Id
                 ,@Title as Title
                 ,@FirstName as  FirstName
	             ,@MiddleName as MiddleName
                 ,@LastName as LastName
				 ,@CountryCode as CountryCode
	             ,@MobileNumber as MobileNumber
	             ,@AlternateMobileNumber as AlternateMobileNumber
	             ,@Email as Email
                 ,@Gender as Gender
                 ,@DateOfBirth as DateOfBirth
	             ,@AddressProofType as AddressProofType
	             ,@AddressProofTypeId as AddressProofTypeId
	             ,@IdentificationNumber as IdentificationNumber
	             ,@MaritalStatus as MaritalStatus
	             ,@OccupationName as OccupationName
	             ,@OccupationId as OccupationId
                 ,@ReligionName as ReligionName
                 ,@ReligionId as ReligionId
                 ,@IncomeGroupName as IncomeGroupName
                 ,@IncomeGroupId as IncomeGroupId
	             ,@EducationName as EducationName
                 ,@EducationId as EducationId
                 ,@BloodGroup as BloodGroup
                 ,@RelationshipType as RelationshipType
                 ,@RelationshipTypeId as RelationshipTypeId
                 ,@RelationName as RelationName
                 ,@MothersMaidenName as MothersMaidenName
                 ,@CityName as CityName
                 ,@CityId as CityId
                 ,@StateName as StateName
                 ,@StateId as StateId
                 ,@Address1 as Address1
	             ,@Address2 as Address2
	             ,@PatientPhotoUrl as PatientPhotoUrl
				 ,@ModifiedName as ModifiedName
				 ,@ModifiedDt as ModifiedDt
				 ,@ModifiedBy as ModifiedBy
				 ,@BranchName as BranchName
		          ) as src
		   ON  
		        trg.Id =@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET				          
                  Title =src.Title
                 ,FirstName =src.FirstName
	             ,MiddleName =src.MiddleName
                 ,LastName =src.LastName
				 ,CountryCode=src.CountryCode
	             ,MobileNumber =src. MobileNumber
	             ,AlternativeMobileNumber =src.AlternateMobileNumber
	             ,Email =src.Email
                 ,Gender =src.Gender
                 ,DateOfBirth =src.DateOfBirth
	             ,AddressProofType =src.AddressProofType
	             ,AddressProofTypeId =src.AddressProofTypeId
	             ,IdentificationNumber =src.IdentificationNumber
	             ,MaritalStatus =src.MaritalStatus
	             ,OccupationName =src.OccupationName
	             ,OccupationId =src.OccupationId
                 ,ReligionName =src.ReligionName
                 ,ReligionId =src.ReligionId
                 ,IncomeGroupName =src.IncomeGroupName
                 ,IncomeGroupId =src.IncomeGroupId
	             ,EducationName =src.EducationName
                 ,EducationId =src.EducationId
                 ,BloodGroup =src.BloodGroup
                 ,RelationshipType =src.RelationshipType
                 ,RelationshipTypeId =src.RelationshipTypeId
                 ,RelationName =src.RelationName
                 ,MothersMaidenName =src.MothersMaidenName
                 ,CityName =src.CityName
                 ,CityId =src.CityId
                 ,StateName =src.StateName
                 ,StateId =src.StateId
                 ,Address1 =src.Address1
	             ,Address2 =src.Address2
	             ,PatientPhotoUrl =src.PatientPhotoUrl
				 ,ModifiedName=@CreatedByFirstName
				 ,ModifiedDt=getDate()
				 ,ModifiedBy=@CreatedByUserId
				 ,BranchName=@BranchName

			WHEN NOT MATCHED THEN
		    INSERT
			     (
				  UserId
		         ,Title 
                 ,FirstName 
	             ,MiddleName
                 ,LastName
				 ,CountryCode
	             ,MobileNumber
	             ,AlternativeMobileNumber
	             ,Email
                 ,Gender
                 ,DateOfBirth
	             ,AddressProofType
	             ,AddressProofTypeId
	             ,IdentificationNumber
	             ,MaritalStatus
	             ,OccupationName
	             ,OccupationId
                 ,ReligionName
                 ,ReligionId
                 ,IncomeGroupName
                 ,IncomeGroupId
	             ,EducationName
                 ,EducationId
                 ,BloodGroup
                 ,RelationshipType
                 ,RelationshipTypeId
                 ,RelationName
                 ,MothersMaidenName
                 ,CityName
                 ,CityId
                 ,StateName
                 ,StateId
                 ,Address1
	             ,Address2
	             ,PatientPhotoUrl
				 ,CreatedByUserId
				 ,CreatedByName
				 ,BranchName
				  )
			values(
			      @UserId
			     ,@Title 
                 ,@FirstName 
	             ,@MiddleName
                 ,@LastName
				 ,@CountryCode
	             ,@MobileNumber
	             ,@AlternateMobileNumber
	             ,@Email
                 ,@Gender
                 ,@DateOfBirth
	             ,@AddressProofType
	             ,@AddressProofTypeId
	             ,@IdentificationNumber
	             ,@MaritalStatus
	             ,@OccupationName
	             ,@OccupationId
                 ,@ReligionName
                 ,@ReligionId
                 ,@IncomeGroupName
                 ,@IncomeGroupId
	             ,@EducationName
                 ,@EducationId
                 ,@BloodGroup
                 ,@RelationshipType
                 ,@RelationshipTypeId
                 ,@RelationName
                 ,@MothersMaidenName
                 ,@CityName
                 ,@CityId
                 ,@StateName
                 ,@StateId
                 ,@Address1
	             ,@Address2
	             ,@PatientPhotoUrl
				 ,@CreatedByUserId
				 ,@CreatedByFirstName
				 ,@BranchName
			);



SET NOCOUNT OFF
END
GO

