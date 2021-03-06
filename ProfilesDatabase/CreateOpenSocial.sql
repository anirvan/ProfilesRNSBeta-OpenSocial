/****** Object:  Table [dbo].[shindig_apps]    Script Date: 08/31/2011 14:29:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[shindig_apps](
	[appId] [int] NOT NULL,
	[name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[url] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PersonFilterID] [int] NULL,
	[enabled] [bit] NOT NULL CONSTRAINT [DF_shindig_apps_enabled]  DEFAULT ((1)),
	[channels] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK__app] PRIMARY KEY CLUSTERED 
(
	[appId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

/****** Object:  Table [dbo].[shindig_app_views]    Script Date: 08/31/2011 14:30:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[shindig_app_views](
	[appId] [int] NOT NULL,
	[viewer_req] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[owner_req] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[page] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[view] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[closed_width] [int] NULL,
	[open_width] [int] NULL,
	[start_closed] [bit] NULL,
	[chromeId] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[display_order] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[shindig_app_views]  WITH CHECK ADD  CONSTRAINT [FK_shindig_app_views_apps] FOREIGN KEY([appId])
REFERENCES [dbo].[shindig_apps] ([appId])

/****** Object:  Table [dbo].[shindig_app_registry]    Script Date: 08/31/2011 14:31:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[shindig_app_registry](
	[appId] [int] NOT NULL,
	[personId] [int] NOT NULL,
	[createdDT] [datetime] NULL CONSTRAINT [DF_shindig_app_registry_createdDT]  DEFAULT (getdate())
) ON [PRIMARY]

/****** Object:  Table [dbo].[shindig_appdata]    Script Date: 08/31/2011 14:31:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[shindig_appdata](
	[userId] [int] NOT NULL,
	[appId] [int] NOT NULL,
	[keyname] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[value] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[createdDT] [datetime] NULL CONSTRAINT [DF_shindig_appdata_createdDT]  DEFAULT (getdate()),
	[updatedDT] [datetime] NULL CONSTRAINT [DF_shindig_appdata_updatedDT]  DEFAULT (getdate())
) ON [PRIMARY]

/****** Object:  Table [dbo].[shindig_messages]    Script Date: 08/31/2011 14:32:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[shindig_messages](
	[msgId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[senderId] [int] NULL,
	[recipientId] [int] NULL,
	[coll] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[title] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[body] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[createdDT] [datetime] NULL CONSTRAINT [DF_shindig_messages_createdDT]  DEFAULT (getdate())
) ON [PRIMARY]

/****** Object:  Table [dbo].[shindig_activity]    Script Date: 08/31/2011 14:32:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[shindig_activity](
	[activityId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NULL,
	[appId] [int] NULL,
	[createdDT] [datetime] NULL CONSTRAINT [DF_shindig_activity_createdDT]  DEFAULT (getdate()),
	[activity] [xml] NULL,
	[chatterFlagOld] [bit] NOT NULL DEFAULT ((0)),
	[chatterFlag] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[chatterAttempts] [int] NULL,
	[updatedDT] [datetime] NULL,
	[xtraId1Type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[xtraId1Value] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK__activity] PRIMARY KEY CLUSTERED 
(
	[activityId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

/****** Object:  StoredProcedure [dbo].[shindig_registerAppPerson]    Script Date: 08/31/2011 14:34:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[shindig_registerAppPerson]    Script Date: 09/23/2010 09:52:53 ******/
CREATE PROCEDURE [dbo].[shindig_registerAppPerson](@userid INT,@appId INT, @value BIT = 1)
As
BEGIN
	SET NOCOUNT ON
		BEGIN TRAN		
			DECLARE @PERSON_FILTER_ID INT
			SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM shindig_apps WHERE appId = @appId)

			IF (@value = 1 AND (SELECT COUNT(*) FROM shindig_app_registry WHERE appId = @appId AND personId = @userId) = 0)
				BEGIN
					INSERT shindig_app_registry (appId, personId) values (@appId, @userId)
					IF (@PERSON_FILTER_ID IS NOT NULL) 
						INSERT person_filter_relationships(personID, personFilterId) values (@userId, @PERSON_FILTER_ID)
				END
			ELSE IF (@value != 1)
				BEGIN
					DELETE FROM shindig_app_registry where appId = @appID AND personId = @userId
					IF (@PERSON_FILTER_ID IS NOT NULL) 
						DELETE FROM person_filter_relationships WHERE personId = @userId AND personFilterId = @PERSON_FILTER_ID
				END	
		COMMIT
END

/****** Object:  StoredProcedure [dbo].[shindig_upsertAppData]    Script Date: 08/31/2011 14:35:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[shindig_upsertAppData]    Script Date: 09/23/2010 09:53:03 ******/
CREATE PROCEDURE [dbo].[shindig_upsertAppData](@userid INT,@appId INT, @keyname nvarchar(255),@value nvarchar(4000))
As
BEGIN
	SET NOCOUNT ON
		BEGIN TRAN				 
			IF (SELECT COUNT(*) FROM shindig_appdata WHERE userId = @userId AND appId = @appId and keyname = @keyName) > 0
				UPDATE shindig_appdata set [value] = @value, updatedDT = GETDATE() WHERE userId = @userId AND appId = @appId and keyname = @keyName
			ELSE
				INSERT shindig_appdata (userId, appId, keyname, [value]) values (@userId, @appId, @keyname, @value)

			-- if keyname is VISIBLE, do more
			IF (@keyname = 'VISIBLE' AND @value = 'Y') 
				EXEC shindig_registerAppPerson @userid, @appId, 1
			ELSE IF (@keyname = 'VISIBLE' ) 
				EXEC shindig_registerAppPerson @userid, @appId, 0
		COMMIT
END								

/****** Object:  StoredProcedure [dbo].[shindig_deleteAppData]    Script Date: 08/31/2011 14:35:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[shindig_deleteAppData]    Script Date: 09/23/2010 09:53:12 ******/
CREATE PROCEDURE [dbo].[shindig_deleteAppData](@userid INT,@appId INT, @keyname nvarchar(255))
As
BEGIN
	SET NOCOUNT ON
		BEGIN TRAN				 
			DELETE shindig_appdata WHERE userId = @userId AND appId = @appId and keyname = @keyName
			-- if keyname is VISIBLE, do more
			IF (@keyname = 'VISIBLE' ) 
				EXEC shindig_registerAppPerson @userid, @appId, 0
		COMMIT
END		

/********** Table that is only used by UCSF dev at the moment and OK to have empty.  Will be replaced with Profiles 1.0 ********************/						
/****** Object:  Table [dbo].[RDF]    Script Date: 09/01/2011 11:04:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RDF](
	[personID] [int] NOT NULL,
	[nodeID] [int] NOT NULL,
	[URL] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

/********** Add some gadgets to play with ********************/

--delete from shindig_apps;
insert shindig_apps values (100, 'Google Search', 'http://dev-profiles.ucsf.edu/apps/GoogleSearch.xml', NULL, 'True', NULL);
insert shindig_apps values (101, 'Featured Presentations', 'http://dev-profiles.ucsf.edu/apps/SlideShare.xml', NULL, 'True', NULL);
insert shindig_apps values (102, 'Faculty Mentor', 'http://dev-profiles.ucsf.edu/apps/Mentor.xml', NULL, 'True', NULL);
insert shindig_apps values (103, 'Websites', 'http://dev-profiles.ucsf.edu/apps/Links.xml', NULL, 'True', NULL)
insert shindig_apps values (104, 'Profile List', 'http://dev-profiles.ucsf.edu/apps/ProfileListTool.xml', NULL, 'True', 'JSONPersonIds');
insert shindig_apps values (105, 'Publication Export', 'http://dev-profiles.ucsf.edu/apps/PubExportTool.xml', NULL, 'True', 'JSONPubMedIds');

insert shindig_app_views values (100, NULL, NULL, 'Search.aspx', NULL, 600, 600, 1, 'gadgets-search', NULL);
insert shindig_app_views values (101, NULL, 'R', 'ProfileDetails.aspx', 'profile', 291, 590, 1, 'gadgets-view', 3);
insert shindig_app_views values (101, NULL, NULL, 'ProfileEdit.aspx', 'home', 700,700, 1, 'gadgets-edit', NULL);
insert shindig_app_views values (102, NULL, 'R', 'ProfileDetails.aspx', 'profile', 291, 590, 1, 'gadgets-view', 2);
insert shindig_app_views values (102, NULL, NULL, 'ProfileEdit.aspx', 'home', 700, 700, 1, 'gadgets-edit', NULL);
insert shindig_app_views values (103, NULL, NULL, 'ProfileEdit.aspx', 'home', 700, 700, 1, 'gadgets-edit', NULL);
insert shindig_app_views values (103, NULL, 'R', 'ProfileDetails.aspx', 'profile', 291, 590, 0, 'gadgets-view', 1);
insert shindig_app_views values (104, 'U', NULL, 'Search.aspx', 'small', 160, 160, 0, 'gadgets-tools', NULL);
insert shindig_app_views values (104, 'U', NULL, 'GadgetDetails.aspx', 'canvas', 700, 700, 0, 'gadgets-detail', NULL);
insert shindig_app_views values (104, 'U', NULL, 'SimilarPeople.aspx', 'small', 160, 160, 0, 'gadgets-tools', NULL);
insert shindig_app_views values (104, 'U', NULL, 'ProfileDetails.aspx', 'small', 160, 160, 0, 'gadgets-tools', NULL);
insert shindig_app_views values (104, 'U', NULL, 'CoAuthors.aspx', 'small', 160, 160, 0, 'gadgets-tools', NULL);
insert shindig_app_views values (105, 'U', NULL, 'ProfileDetails.aspx', 'small', 160, 160, 0, 'gadgets-tools', NULL);
insert shindig_app_views values (105, 'U', NULL, 'GadgetDetails.aspx', 'canvas', 700, 700, 0, 'gadgets-detail', NULL);

