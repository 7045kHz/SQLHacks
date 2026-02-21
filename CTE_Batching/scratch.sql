

-- Update deployments to 'Sent' when StartTime is in current hour and status is 'initialized'
-- pretent already sent for current hour
UPDATE dbo.deployments
SET [Status] = 'Sent'
WHERE [Status] = 'initialized'
  AND StartTime >= DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()), 0)
  AND StartTime < DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()) + 1, 0);

 
 update dbo.pending_deployments set Enabled = 0 where ReleaseId=7 and [Order] = 1 

-- Update deployments to 'Disabled' when corresponding pending deployment is not enabled and status is 'initialized'
-- merge should do this but we want to test the update logic separately before running the merge
UPDATE d
SET d.[Status] = 'Disabled'
FROM dbo.deployments d
INNER JOIN dbo.pending_deployments pd
    ON d.ReleaseId = pd.ReleaseId
    AND d.Asset_Name = pd.Asset_Name
    AND d.Job_Name = pd.Job_Name
WHERE pd.[Enabled] <> 1
  AND d.[Status] = 'initialized';



 -- Disable pending deployments for next day (pretend they are disabled before the merge runs to test the merge logic that should disable corresponding deployments) 
update dbo.pending_deployments 
set Enabled = 2
where StartTime >= DATEADD(DAY, DATEDIFF(DAY, 0, GETUTCDATE()) + 1, 0)
  AND StartTime < DATEADD(DAY, DATEDIFF(DAY, 0, GETUTCDATE()) + 2, 0)
  AND Enabled = 1;

-- set to disabled for next day to test the merge logic that should disable corresponding deployments for next day
UPDATE d
SET d.[Status] = 'Disabled'
FROM dbo.deployments d
INNER JOIN dbo.pending_deployments pd
    ON d.ReleaseId = pd.ReleaseId
    AND d.Asset_Name = pd.Asset_Name
    AND d.Job_Name = pd.Job_Name
WHERE pd.[Enabled] <> 1
  AND d.[Status] = 'initialized';

   select * FROM dbo.deployments d
  select * FROM dbo.pending_deployments pd
