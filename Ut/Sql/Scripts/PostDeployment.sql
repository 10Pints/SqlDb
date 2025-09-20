/*
 Post-Deployment Script Template
 This runs after the main deployment of the ut database.
 Add custom cleanup or configuration logic here (e.g., grant permissions, enable CLR).
Post-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.    
 Use SQLCMD syntax to include a file in the post-deployment script.      
 Example:      :r .\myfile.sql                
 Use SQLCMD syntax to reference a variable in the post-deployment script.    
 Example:      :setvar TableName MyTable              
               SELECT * FROM [$(TableName)]          
--------------------------------------------------------------------------------------


if not exists (select 1 from dbo.Food)
begin
  insert into food(title, [description], price) 
  values ('Cheeseburger Meal', 'A cheeseburger, fries and a drink', 5.95)
  ,('ChiliDog Meal', '2 Chili dogs, fries and a drink', 4.25)
  ,('Vegan Meal', 'A large salad and a glass of water', 1.95)
  ;
end
*/
PRINT 'Executing PreDeployment.sql for ut database';
GO