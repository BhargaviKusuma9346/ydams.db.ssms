
CREATE procedure [dbo].[spGetEmailTemplates]     
    @Name varchar(200)
AS        
      
/*
 exec [dbo].[spGetEmailTemplates]    'Shortlisted-applicant'
 -------------------------------------------------------------              
    
 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
19/04/2023				RAKESH K		To Get EmailTemplates by Name
 ------------------------------------------------------------------------------      
                Copyright 2021@Hireme
*/        
BEGIN 
  

SET NOCOUNT ON 

		  select 
		  TemplateHtml,
		  ReplaceableVariables 
		  from dbo.EmailTemplates WITH (NOLOCK, READUNCOMMITTED)

where Name=@Name
			
SET NOCOUNT OFF

END
