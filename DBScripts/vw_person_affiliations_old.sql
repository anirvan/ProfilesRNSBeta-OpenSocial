
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER view [dbo].[vw_person_affiliations] as
SELECT  j.ID internalUserName, 
   25693078 + cast(SUBSTRING(j.ID, 2, 7) as numeric) [internalid],
   NULL internaldapusername,
   j.title title,
   NULL internaladmintitle,
	j.EMAIL_ADDR emailaddr, 
	1 primaryaffiliation,
	1 affiliationorder,
	CASE d.level_2_dept_title 
		WHEN 'SCHOOL OF MEDICINE' then 'School of Medicine'
		WHEN 'SCHOOL OF DENTISTRY' then 'School of Dentistry'
		WHEN 'SCHOOL OF PHARMACY' then 'School of Pharmacy'
		WHEN 'SCHOOL OF NURSING' then 'School of Nursing'
		ELSE 'Chancellor/EVC/FAS'
	END institutionname,
  coalesce(l2.pretty_name , profiles.dbo.fn_propercase(coalesce(d.level_2_dept_title, 'Chancellor/EVC/FAS'))) institutionfullname,
  coalesce(d.level_2_dept_cd, 'OTHER') institutionabbreviation,
	CASE 
        WHEN j.DEPT = '447546' then d.PRETTY_NAME -- CTSI 
		WHEN l3.dept_cd is null then coalesce(l2.pretty_name , profiles.dbo.fn_propercase(d.level_2_dept_title))
--		WHEN (d.level_2_dept_title = 'SCHOOL OF MEDICINE' OR
--			  d.level_2_dept_title = 'SCHOOL OF DENTISTRY' OR
--			  d.level_2_dept_title = 'SCHOOL OF PHARMACY' OR
--			  d.level_2_dept_title = 'SCHOOL OF NURSING' OR
--			  d.level_2_dept_title = 'EXECUTIVE VICE CHANCELLOR') then 
--			coalesce(l3.pretty_name, profiles.dbo.fn_propercase(coalesce(d.level_3_dept_title, 'Other')))
		ELSE coalesce(l3.pretty_name, profiles.dbo.fn_propercase(coalesce(d.level_3_dept_title, 'Other')))
	END departmentname,
	CASE 
        WHEN j.DEPT = '447546' then d.PRETTY_NAME -- CTSI 
		WHEN l3.dept_cd is null then coalesce(l2.pretty_name , profiles.dbo.fn_propercase(d.level_2_dept_title))
		ELSE coalesce(l3.pretty_name, profiles.dbo.fn_propercase(coalesce(d.level_3_dept_title, 'Other')))
	    -- ELSE coalesce(l3.pretty_name, profiles.dbo.fn_propercase(d.level_3_dept_title), profiles.dbo.fn_propercase(d.dept_title)) 
--	coalesce(d.pretty_name, profiles.dbo.fn_propercase(d.dept_title)) departmentfullname,  -- THIS ONE DOES NOT ROLL UP
	END departmentfullname,
	CASE 
        WHEN j.DEPT = '447546' then j.DEPT -- CTSI 
--		WHEN (d.level_2_dept_title = 'SCHOOL OF MEDICINE' OR
--			  d.level_2_dept_title = 'SCHOOL OF DENTISTRY' OR
--			  d.level_2_dept_title = 'SCHOOL OF PHARMACY' OR
--			  d.level_2_dept_title = 'SCHOOL OF NURSING' OR
--			  d.level_2_dept_title = 'EXECUTIVE VICE CHANCELLOR') then 
--			coalesce(d.level_3_dept_cd, 'Other')
		ELSE coalesce(d.level_3_dept_cd, 'Other')
    END departmentabbreviation,
	CASE 
		WHEN ((d.level_2_dept_title = 'SCHOOL OF MEDICINE' OR
			  d.level_2_dept_title = 'SCHOOL OF DENTISTRY' OR
			  d.level_2_dept_title = 'SCHOOL OF PHARMACY' OR
			  d.level_2_dept_title = 'SCHOOL OF NURSING' OR
			  d.level_2_dept_title = 'EXECUTIVE VICE CHANCELLOR') 
				AND (l3.pretty_name is not null OR d.level_3_dept_title is not null))then 1
		ELSE 0
	END departmentvisible,
  NULL divisionname,
  NULL divisionfullname,
  NULL divisionabbreviation,
  (case 
	when td.title_rank is not null then td.title_rank 
    when charindex(substring(j.[TCI CTO OSC], 1, 1), 'S0123456789') <> 0 then 4 -- Other Academic 
	else 5 -- Other Staff
   end) facultyrankcode,
  (case 
    when td.title_rank is not null then td.title_description 
    when charindex(substring(j.[TCI CTO OSC], 1, 1), 'S0123456789') <> 0 then 'Other Academic' -- Other Academic 
	else 'Other Staff' -- Other Staff
   end) facultyrank,
  (case 
    when td.title_description is not null then td.title_description 
    when charindex(substring(j.[TCI CTO OSC], 1, 1), 'S0123456789') <> 0 then 'Other Academic' -- Other Academic 
	else 'Other Staff' -- Other Staff
   end) facultyrankfullname,
  (case 
	when td.title_rank is not null then td.title_rank 
    when charindex(substring(j.[TCI CTO OSC], 1, 1), 'S0123456789') <> 0 then 4 -- Other Academic 
	else 5 -- Other Staff
   end) facultyrankorder,
  NULL internalfullparttime,
  NULL is_visiting
FROM  ((((vw_joined j left outer join titles_include_rs ti on j.PRIMARY_TITLE = ti.title_code)
left outer join titles_detail td on ti.title_type = td.title_type)
LEFT OUTER JOIN  dept_ctrl_pts d on j.dept = d.dept_cd)
left outer JOIN dept_ctrl_pts l2 on l2.dept_cd = d.level_2_dept_cd)
left outer join dept_ctrl_pts l3 on l3.dept_cd = d.level_3_dept_cd;

-- select p.* from ucsfpro1 p left outer join ucsfpro2 a on p.id = a.[CLS UNIQUE ID]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

