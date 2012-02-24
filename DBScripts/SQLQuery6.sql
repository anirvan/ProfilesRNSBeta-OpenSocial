
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER view [dbo].[vw_person_secondary_affiliations] as
select internalUserName, internalid, internaldapusername, pretty_name title, internaladmintitle, emailaddr, 0 primaryaffiliation, 2 affiliationorder,
null institutionname, null institutionfullname, null institutionabbreviation, 
null departmentname, null departmentfullname, null departmentabbreviation, 0 departmentvisible,
null divisionname, null divisionfullname, null divisionabbreviation, facultyrankcode, facultyrank, facultyrankfullname, facultyrankorder, internalfullparttime, is_visiting
from vw_person_affiliations a join vw_person_secondary_title_codes on a.internalusername = ID where
pretty_name is not null;
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

