/****** Object:  Table [dbo].[apps]    Script Date: 09/23/2010 09:51:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[shindig_apps](
	[appId] [int] NOT NULL,
	[name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[url] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PersonFilterID] [int] NULL
) ON [PRIMARY]

/****** Object:  Table [dbo].[app_registry]    Script Date: 09/23/2010 09:50:53 ******/
CREATE TABLE [dbo].[shindig_app_registry](
	[appId] [int] NOT NULL,
	[personId] [int] NOT NULL
) ON [PRIMARY]

/****** Object:  Table [dbo].[appdata]    Script Date: 09/23/2010 09:52:24 ******/
CREATE TABLE [dbo].[shindig_appdata](
	[userId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[appId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[keyname] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[value] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

/****** Object:  Table [dbo].[activity]    Script Date: 09/23/2010 09:47:48 ******/
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[shindig_activity](
	[activityId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[appId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[activity] [varbinary](max) NULL,
 CONSTRAINT [PK__activity] PRIMARY KEY CLUSTERED 
(
	[activityId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF

/****** Object:  Table [dbo].[messages]    Script Date: 09/23/2010 09:52:39 ******/
CREATE TABLE [dbo].[shindig_messages](
	[msgId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[senderId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recipientId] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[coll] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[title] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[body] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

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

GO
/****** Object:  StoredProcedure [dbo].[shindig_upsertAppData]    Script Date: 09/23/2010 09:53:03 ******/
CREATE PROCEDURE [dbo].[shindig_upsertAppData](@userid INT,@appId INT, @keyname nvarchar(255),@value nvarchar(255))
As
BEGIN
	SET NOCOUNT ON
		BEGIN TRAN				 
			IF (SELECT COUNT(*) FROM shindig_appdata WHERE userId = @userId AND appId = @appId and keyname = @keyName) > 0
				UPDATE shindig_appdata set [value] = @value WHERE userId = @userId AND appId = @appId and keyname = @keyName
			ELSE
				INSERT shindig_appdata (userId, appId, keyname, [value]) values (@userId, @appId, @keyname, @value)

			-- if keyname is VISIBLE, do more
			IF (@keyname = 'VISIBLE' AND @value = 'Y') 
				EXEC shindig_registerAppPerson @userid, @appId, 1
			ELSE IF (@keyname = 'VISIBLE' ) 
				EXEC shindig_registerAppPerson @userid, @appId, 0
		COMMIT
END								

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

