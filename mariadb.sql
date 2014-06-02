/*
Navicat MariaDB Data Transfer

Source Server         : localhost-mariadb
Source Server Version : 100011
Source Host           : localhost:3306
Source Database       : collaborate

Target Server Type    : MariaDB
Target Server Version : 100011
File Encoding         : 65001

Date: 2014-06-02 17:22:27
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for attachments
-- ----------------------------
DROP TABLE IF EXISTS `attachments`;
CREATE TABLE `attachments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL,
  `size` int(11) unsigned NOT NULL,
  `comment` text NOT NULL,
  `upload_time` datetime NOT NULL,
  `mime_type` varchar(255) NOT NULL,
  `user_id` int(11) unsigned NOT NULL,
  KEY `Index 1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for discussion_forums
-- ----------------------------
DROP TABLE IF EXISTS `discussion_forums`;
CREATE TABLE `discussion_forums` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '0',
  `link_type` varchar(255) NOT NULL DEFAULT '0',
  `link_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Index 1` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for discussion_posts
-- ----------------------------
DROP TABLE IF EXISTS `discussion_posts`;
CREATE TABLE `discussion_posts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `forum_id` int(10) unsigned NOT NULL,
  `thread_id` int(11) NOT NULL,
  `posted` datetime NOT NULL,
  `modified` datetime DEFAULT NULL,
  `posted_by` int(10) unsigned NOT NULL,
  `body` text NOT NULL,
  `preview` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for discussion_threads
-- ----------------------------
DROP TABLE IF EXISTS `discussion_threads`;
CREATE TABLE `discussion_threads` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `forum_id` int(11) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `created_by` int(11) unsigned NOT NULL,
  `last_post` datetime NOT NULL,
  `posts` int(1) unsigned NOT NULL,
  `views` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for menu
-- ----------------------------
DROP TABLE IF EXISTS `menu`;
CREATE TABLE `menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `feature` varchar(255) NOT NULL,
  `tag` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for settings
-- ----------------------------
DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings` (
  `name` varchar(255) NOT NULL,
  `value` text,
  PRIMARY KEY (`name`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `realname` varchar(255) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `token` int(11) unsigned DEFAULT NULL,
  `enabled` bit(1) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `admin` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Index 1` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for wiki_pages
-- ----------------------------
DROP TABLE IF EXISTS `wiki_pages`;
CREATE TABLE `wiki_pages` (
  `id` int(10) unsigned NOT NULL,
  `parent` int(10) unsigned DEFAULT NULL,
  `latest_revision` int(10) unsigned NOT NULL,
  `page_title` varchar(255) NOT NULL,
  `modified` datetime NOT NULL,
  `views` int(10) unsigned NOT NULL,
  `forum` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for wiki_revisions
-- ----------------------------
DROP TABLE IF EXISTS `wiki_revisions`;
CREATE TABLE `wiki_revisions` (
  `id` int(10) unsigned NOT NULL,
  `page_id` int(10) unsigned NOT NULL,
  `body` text NOT NULL,
  `preview` text NOT NULL,
  `modified` datetime NOT NULL,
  `modified_by` int(10) unsigned NOT NULL,
  `comment` text NOT NULL,
  `text_length` int(10) unsigned NOT NULL,
  `redirect` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Procedure structure for authenticate_user
-- ----------------------------
DROP PROCEDURE IF EXISTS `authenticate_user`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `authenticate_user`(IN `i_username` VARCHAR(255), IN `i_password` VARCHAR(255),
	OUT `o_status` VARCHAR(255))
BEGIN
	DECLARE _enabled BIT;
	DECLARE _id INT;
	DECLARE _password VARCHAR(255);
	
	SELECT id, enabled, password FROM users WHERE username = LCASE(i_username) INTO _id, _enabled, _password;
	
	IF _id IS NULL THEN
		SET o_status = 'nouser';
	ELSEIF _password IS NULL THEN
		SET o_status = 'verifyemail';
	ELSEIF _password != PASSWORD(i_password) THEN
		SET o_status = 'badpassword';
	ELSEIF _enabled = 0 THEN
		SET o_status = 'disabled';
	ELSE
		START TRANSACTION;
		UPDATE users SET last_login = NOW() WHERE id = _id;
		COMMIT;
		SET o_status = 'success';
		SELECT _id as id;
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for change_user_password
-- ----------------------------
DROP PROCEDURE IF EXISTS `change_user_password`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `change_user_password`(IN `i_id` INT, IN `i_password` VARCHAR(255))
BEGIN
	START TRANSACTION;
	UPDATE users SET password = PASSWORD(i_password) WHERE id = i_id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for create_attachment
-- ----------------------------
DROP PROCEDURE IF EXISTS `create_attachment`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_attachment`(IN `i_filename` VARCHAR(255), IN `_size` INT, IN `_comment` text, IN `_mime_type` varchar(255), IN `_userid` INT, OUT `_id` INT)
BEGIN
	START TRANSACTION;
   INSERT INTO attachments (filename, size, comment, upload_time, mime_type, user_id)
   VALUES (i_filename, _size, _comment, NOW(), _mime_type, _user_id);
	SET _id = LAST_INSERT_ID();
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for create_discussion_forum
-- ----------------------------
DROP PROCEDURE IF EXISTS `create_discussion_forum`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_discussion_forum`(IN `_title` VARCHAR(255), OUT `_id` INT)
BEGIN
	START TRANSACTION;
	INSERT INTO discussion_forums (title, link_type)
		VALUES (_title, 'discussion');
	SET _id = LAST_INSERT_ID();
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for create_discussion_post
-- ----------------------------
DROP PROCEDURE IF EXISTS `create_discussion_post`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_discussion_post`(IN `i_thread_id` int,IN `i_user_id` int,IN `i_body` text,IN `i_preview` text,OUT `o_id` int, OUT `o_posts` int)
BEGIN
	DECLARE _forum_id INT;

	START TRANSACTION;
		SELECT forum_id FROM discussion_threads WHERE id = i_thread_id INTO _forum_id;

		IF _forum_id IS NULL THEN
			SET o_id = NULL;
			SET o_posts = NULL;
		ELSE
			INSERT INTO discussion_posts
				(forum_id, thread_id, posted, modified, posted_by, body, preview)
			VALUES
				(_forum_id, i_thread_id, NOW(), NULL, user_id, i_body, i_preview);

			SET o_id = LAST_INSERT_ID();

			SELECT COUNT(1) FROM dicussion_posts WHERE thread_id = i_thread_id INTO o_posts;
			
			UPDATE
				discussion_threads
			SET
				posts = o_posts, last_post = NOW()
			WHERE
				id = i_thread_id;

		END IF;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for create_discussion_thread
-- ----------------------------
DROP PROCEDURE IF EXISTS `create_discussion_thread`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_discussion_thread`(IN `i_title` varchar(255),IN `i_forum_id` int,IN `i_user_id` int,IN `i_body` text, IN `i_preview` TEXT, OUT `o_id` int, OUT `o_post_id` int)
BEGIN
	DECLARE forumExists INT;

	START TRANSACTION;
	SELECT count(1) from discussion_forums WHERE id = i_forum_id INTO forumExists;

	IF forumExists = 0 THEN
		SET o_id = NULL;
		SET o_post_id = NULL;
	ELSE
		INSERT INTO discussion_threads
			(forum_id, title, created, created_by, last_post, posts, views)
		VALUES
			(i_forum_id, i_title, NOW(), i_user_id, NOW(), 1, 1);

		SET o_id = LAST_INSERT_ID();

		-- insert initial post
		INSERT INTO discussion_posts
			(forum_id, thread_id, posted, modified, posted_by, body, preview)
		VALUES
			(i_forum_id, o_id, NOW(), NULL, i_user_id, i_body, i_preview);

		SET o_post_id = LAST_INSERT_ID();
	END IF;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for create_menu_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `create_menu_item`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_menu_item`(IN `i_title` varchar(255),IN `i_feature` varchar(255),IN `i_tag` text,OUT `o_id` int)
BEGIN
	START TRANSACTION;
		INSERT INTO menu (title, feature, tag)
		VALUES (i_title, i_feature, i_tag);
		SET o_id = LAST_INSERT_ID();
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for create_user
-- ----------------------------
DROP PROCEDURE IF EXISTS `create_user`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_user`(IN `i_username` VARCHAR(255), IN `i_email` varchar(255), IN `i_realname` varchar(255), OUT `o_status` varchar(255))
BEGIN
	DECLARE userCount INT;
	DECLARE _token INT;
	
	START TRANSACTION;
	SELECT count(1) FROM USERS u WHERE username = lcase(i_username) INTO userCount;
	
	IF userCount > 0 THEN
		SET o_status = 'userexists';
	ELSE
		SET o_status = 'success';
		SET _token = FLOOR(RAND() * 10000000);
		INSERT INTO users (username, realname, password, email, token, enabled, admin)
			VALUES (lcase(i_username), i_realname, NULL, i_email, _token, 1, 0);
		SELECT _token as token;
	END IF;
	COMMIT;
	
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for create_wiki_page
-- ----------------------------
DROP PROCEDURE IF EXISTS `create_wiki_page`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_wiki_page`(IN `i_parent` int,IN `i_title` varchar(255),IN `i_content` text, IN `i_preview` text, IN `i_text_length` int, IN `i_redirect` int, IN `i_comment` varchar(255),IN `i_userid` int,OUT `o_status` varchar(255))
BEGIN
	DECLARE _page_id INT;
	DECLARE _revision_id INT;
	DECLARE _forum_id INT;

	START TRANSACTION;
	-- check if parent exists
	IF i_parent IS NOT NULL AND (SELECT COUNT(1) FROM wiki_pages WHERE id = i_parent) = 0 THEN
		SET o_status = 'badparent';
	ELSE
		-- see if a page with the same name already exists
		IF (SELECT COUNT(1) FROM wiki_pages WHERE parent = i_parent AND title = i_title) > 0 THEN
			SET o_status = 'duplicatename';
		ELSE
			INSERT INTO wiki_pages (parent, latest_revision, page_title, modified, views, forum)
			VALUES (i_parent, 0, i_title, NOW(), 0, 0);

			SET _page_id = LAST_INSERT_ID();

			INSERT INTO wiki_revisions (page_id, body, preview, modified, modified_by, comment, text_length, redirect)
			VALUES (_page_id, i_body, i_preview, NOW(), i_userid, i_comment, i_text_length, i_redirect);

			SET _revision_id = LAST_INSERT_ID();


			-- create a forum for this wiki page
			INSERT INTO discussion_forums (title, link_type, link_id)
			VALUES (page_title, 'wiki', _page_id);

			SET _forum_id = LAST_INSERT_ID();

			UPDATE wiki_pages SET latest_revision = _revision_id, forum = _forum_id WHERE id = _page_id;

		
			SELECT _page_id page_id, _revision_id revision_id;

			SET o_status = 'success';
		END IF;
	END IF;

	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for delete_attachment
-- ----------------------------
DROP PROCEDURE IF EXISTS `delete_attachment`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_attachment`(IN `_id` INT)
BEGIN
	START TRANSACTION;
	DELETE FROM attachments WHERE id = _id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for delete_discussion_forum
-- ----------------------------
DROP PROCEDURE IF EXISTS `delete_discussion_forum`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_discussion_forum`(IN `i_id` int)
BEGIN
	START TRANSACTION;
	DELETE FROM discussion_forums WHERE id = _id;
	DELETE FROM discussion_threads WHERE forum_id = _id;
	DELETE FROM discussion_posts WHERE forum_id = _id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for delete_discussion_post
-- ----------------------------
DROP PROCEDURE IF EXISTS `delete_discussion_post`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_discussion_post`(IN `i_id` int)
BEGIN
	DECLARE _thread_id INT;
	START TRANSACTION;

	SELECT thread_id FROM discussion_posts WHERE id = i_id INTO _thread_id;

	IF _thread_id IS NOT NULL THEN
		DELETE FROM discussion_posts WHERE id = i_id;

		UPDATE discussion_threads
		SET posts = (SELECT COUNT(1) FROM discussion_posts WHERE thread_id = _thread_id)
		WHERE id = _thread_id;
	END IF;

	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for delete_discussion_thread
-- ----------------------------
DROP PROCEDURE IF EXISTS `delete_discussion_thread`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_discussion_thread`(IN `i_id` int)
BEGIN
	START TRANSACTION;
	DELETE FROM discussion_threads WHERE id = i_id;
	DELETE FROM discussion_posts WHERE thread_id = i_id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for delete_menu_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `delete_menu_item`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_menu_item`(IN `i_id` int)
BEGIN
	START TRANSACTION;
	DELETE FROM menu WHERE id = i_id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for edit_discussion_post
-- ----------------------------
DROP PROCEDURE IF EXISTS `edit_discussion_post`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_discussion_post`(IN `i_id` int,IN `i_body` text,IN `i_preview` text)
BEGIN
	START TRANSACTION;
	UPDATE discussion_posts
	SET body = i_body, preview = i_preview, modified = NOW()
	WHERE id = i_id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for edit_wiki_page
-- ----------------------------
DROP PROCEDURE IF EXISTS `edit_wiki_page`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_wiki_page`(IN `i_id` int,IN `i_body` text,IN `i_preview` text,IN `i_text_length` int,IN `i_redirect` int,IN `i_comment` varchar(255),IN `i_userid` int, OUT `o_status` varchar(255))
BEGIN
	DECLARE _latest_revision INT;

	START TRANSACTION;
	-- see if the wiki page EXISTS
	SELECT latest_revision FROM wiki_pages WHERE id = i_id INTO _latest_revision;

	IF _latest_revision IS NULL THEN
		SET o_status = 'nopage';
	ELSE
		INSERT INTO wiki_revisions (page_id, body, preview, modified, modified_by, comment, text_length, redirect)
		VALUES (i_id, i_body, i_preview, NOW(), i_userid, i_comment, i_text_length, i_redirect);

		SET _latest_revision = LAST_INSERT_ID();

		UPDATE wiki_pages SET latest_revision = _latest_revision, modified = NOW() WHERE id = _id;

		SELECT _latest_revision latest_revision;

		SET o_status = 'success';
	END IF;

	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_attachment
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_attachment`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_attachment`(IN `_id` INT, OUT `o_filename` varchar(255), OUT `_size` INT, OUT `_mime_type` varchar(255))
BEGIN
	SELECT filename, size, mime_type FROM attachments WHERE id = _id INTO o_filename, _size, _mime_type;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_discussion_forum
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_discussion_forum`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_discussion_forum`(IN `_id` INT, OUT `_title` VARCHAR(255), OUT `_link_type` VARCHAR(255), OUT `_link_id` INT)
BEGIN
	SELECT title, link_type, link_id FROM discussion_forums WHERE id = _id INTO _title, _link_type, _link_id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_discussion_forums
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_discussion_forums`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_discussion_forums`()
BEGIN
	SELECT id, title FROM discussion_forums WHERE link_type = 'discussion';
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_discussion_posts_in_thread
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_discussion_posts_in_thread`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_discussion_posts_in_thread`(IN `i_id` int,IN `i_offset` int,IN `i_rows` int,OUT `o_count` int)
BEGIN
	SELECT COUNT(1) FROM discussion_posts WHERE thread_id = i_id INTO o_count;

	SELECT
		id, posted, modified, posted_by, body
	FROM
		discussion_posts
	WHERE
		thread_id = i_id
	ORDER BY
		id
	LIMIT i_offset, i_rows;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_discussion_threads_in_forum
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_discussion_threads_in_forum`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_discussion_threads_in_forum`(IN `i_id` int, IN `i_offset` int, IN `i_rows` int, OUT `o_total` int)
BEGIN
	SELECT count(1) FROM discussion_threads WHERE forum_id = i_id INTO o_total;

	SELECT id, title, created, created_by, last_post, posts, views
		FROM discussion_threads
		WHERE forum_id = _id
		ORDER BY last_post DESC
		LIMIT i_offset, i_rows;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_latest_discussion_threads
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_latest_discussion_threads`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_latest_discussion_threads`(IN `i_offset` int,IN `i_rows` int,OUT `o_total` int)
BEGIN
	SELECT count(1) FROM discussion_threads INTO o_total;

	SELECT id, forum_id, title, created, created_by, last_post, posts, views
		FROM discussion_threads
		ORDER BY last_post DESC
		LIMIT i_offset, i_rows;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_menu_items
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_menu_items`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_menu_items`()
BEGIN
	SELECT * FROM menu;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_settings
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_settings`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_settings`()
BEGIN
	SELECT name, value FROM settings;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_user_information
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_user_information`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_information`(IN `i_id` INT)
BEGIN
	SELECT username, realname, email, enabled, last_login, admin FROM users WHERE id = i_id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_user_realname
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_user_realname`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_realname`(IN `i_userid` INT, OUT `o_status` VARCHAR(255))
BEGIN
  DECLARE _realname VARCHAR(255);
	SELECT realname FROM users WHERE id = i_userid INTO _realname;
	IF _realname IS NOT NULL THEN
		SET o_status = 'success';
		SELECT _realname realname;
	ELSE
		SET o_status = 'nouser';
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_wiki_page
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_wiki_page`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_wiki_page`(IN `i_page` int,IN `i_revision` int)
BEGIN
	DECLARE _title VARCHAR(255);
	DECLARE _parent INT;
	DECLARE _revision VARCHAR(255);

	SELECT title, parent, latest_revision FROM wiki_pages WHERE id = i_page INTO _title, _parent, _revision;
	-- test if the page exists
	IF _title IS NOT NULL THEN
		IF i_revision IS NOT NULL THEN
			SET _revision = i_revision; -- use the revision passed in
		END IF;

		START TRANSACTION;
		UPDATE wiki_pages SET views = views + 1 WHERE id = i_page;
		COMMIT;

		SELECT _title title, _parent parent, _revision revision, body, modified, modified_by, redirect, forum
		FROM wiki_revisions WHERE id = _revision;
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_wiki_pages
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_wiki_pages`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_wiki_pages`(IN `i_id` int, IN `i_sort` int, IN `i_offset` int, IN `i_count` int, OUT `o_count` int)
BEGIN
	SELECT COUNT(1) FROM wiki_pages WHERE parent = i_id INTO o_count;

	IF i_sort = 0 THEN -- page title
		SELECT id, page_title, page_touched, views FROM wiki_pages ORDER BY page_title LIMIT i_sort, i_offset;
	ELSEIF i_sort = 0 THEN -- recently modified
		SELECT id, page_title, page_touched, views FROM wiki_pages ORDER BY page_touched LIMIT i_sort, i_offset;
	ELSE -- views
		SELECT id, page_title, page_touched, views FROM wiki_pages ORDER BY views LIMIT i_sort, i_offset;
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_wiki_page_preview
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_wiki_page_preview`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_wiki_page_preview`(IN `i_page` int,IN `i_revision` int)
BEGIN
	DECLARE _title VARCHAR(255);
	DECLARE _parent INT;
	DECLARE _revision VARCHAR(255);

	SELECT title, parent, latest_revision FROM wiki_pages WHERE id = i_page INTO _title, _parent, _revision;
	-- test if the page exists
	IF _title IS NOT NULL THEN
		IF i_revision IS NOT NULL THEN
			SET _revision = i_revision; -- use the revision passed in
		END IF;

		START TRANSACTION;
		UPDATE wiki_pages SET views = views + 1 WHERE id = i_page;
		COMMIT;

		SELECT _title title, _parent parent, _revision revision, preview, modified, modified_by, redirect
		FROM wiki_revisions WHERE id = _revision;
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_wiki_page_revisions
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_wiki_page_revisions`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_wiki_page_revisions`(IN `i_page` int,IN `i_offset` int,IN `i_rows` int,OUT `o_count` int)
BEGIN
	SELECT COUNT(1) FROM wiki_revisions WHERE page_id = i_page INTO o_count;

	SELECT
		id, modified, modified_by, comment, text_length, redirect
	FROM
		wiki_revisions
	WHERE
		page_id = i_page
	ORDER BY
		i_page
	LIMIT
		i_offset, i_rows;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for move_wiki_page
-- ----------------------------
DROP PROCEDURE IF EXISTS `move_wiki_page`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `move_wiki_page`(IN `i_page` int,IN `i_title` varchar(255),IN `i_parent` int,OUT `o_status` varchar(255))
BEGIN
	START TRANSACTION;
	-- check if parent exists
	IF i_parent IS NOT NULL AND (SELECT COUNT(1) FROM wiki_pages WHERE id = i_parent) = 0 THEN
		SET o_status = 'badparent';
	ELSE
		-- see if a page with the same name already exists
		IF (SELECT COUNT(1) FROM wiki_pages WHERE parent = i_parent AND title = i_title) > 0 THEN
			SET o_status = 'duplicatename';
		ELSE
			UPDATE wiki_pages SET parent = i_parent, title = i_title WHERE id = i_id;

			SET o_status = 'success';
		END IF;
	END IF;

	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for reset_user_token
-- ----------------------------
DROP PROCEDURE IF EXISTS `reset_user_token`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reset_user_token`(IN `i_username` VARCHAR(255), OUT `o_status` VARCHAR(255))
BEGIN
	DECLARE _id INT;
	DECLARE _token INT;

	SELECT id FROM users WHERE username = lcase(i_username) INTO _id;
	IF _id IS NOT NULL THEN
		SET _token = FLOOR(RAND() * 10000000);
		START TRANSACTION;
		UPDATE users SET token = _token WHERE id = _id;
		SELECT username, realname, email, token FROM users WHERE id = _id;
		COMMIT;
		SET o_status = 'success';
	ELSE
		SET o_status = 'no_user';
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for set_dicussion_forum_title
-- ----------------------------
DROP PROCEDURE IF EXISTS `set_dicussion_forum_title`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_dicussion_forum_title`(IN `_id` INT, IN `_title` VARCHAR(255))
BEGIN
	START TRANSACTION;
	UPDATE attachments SET title = _title WHERE id = _id AND link_type = 'discussion';
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for set_discussion_thread_title
-- ----------------------------
DROP PROCEDURE IF EXISTS `set_discussion_thread_title`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_discussion_thread_title`(IN `i_id` int,IN `i_title` varchar(255))
BEGIN
	START TRANSACTION;
	UPDATE discussion_threads
		SET title = i_title
	WHERE
		id = i_id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for set_file_attachment_comment
-- ----------------------------
DROP PROCEDURE IF EXISTS `set_file_attachment_comment`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_file_attachment_comment`(IN `_id` INT, IN `_comment` INT)
BEGIN
	START TRANSACTION;
	UPDATE attachments SET comment = _comment WHERE id = _id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for set_menu_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `set_menu_item`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_menu_item`(IN `i_id` int,IN `i_title` varchar(255),IN `i_feature` varchar(255),IN `i_tag` text)
BEGIN
	START TRANSACTION;
	UPDATE menu SET title = i_title, feature = i_feature, tag = i_tag
	WHERE id = i_id;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for set_setting
-- ----------------------------
DROP PROCEDURE IF EXISTS `set_setting`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_setting`(IN `i_setting` varchar(255),IN `i_value` text)
BEGIN
	START TRANSACTION;
	INSERT INTO settings (name, value)
	VALUES (i_setting, i_value)
	ON DUPLICATE KEY UPDATE value = i_value;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for set_user_information
-- ----------------------------
DROP PROCEDURE IF EXISTS `set_user_information`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_user_information`(IN `i_userid` INT, IN `i_realname` VARCHAR(255), IN `i_email` VARCHAR(255), IN `i_enabled` BIT, IN `i_admin` BIT)
BEGIN
	START TRANSACTION;
	UPDATE users SET
		realname = i_realname,
		email = i_email,
		enabled = i_enabled,
		admin = i_admin
	WHERE id = i_userid;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for swap_menu_items
-- ----------------------------
DROP PROCEDURE IF EXISTS `swap_menu_items`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `swap_menu_items`(IN `i_id1` int,IN `i_id2` int)
BEGIN
	START TRANSACTION;
	UPDATE menu	SET id = -1 WHERE id = i_id1;
	UPDATE menu SET id = i_id1 WHERE id = i_id2;
	UPDATE menu SET id = i_id2 WHERE id = -1;
	COMMIT;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for verify_user
-- ----------------------------
DROP PROCEDURE IF EXISTS `verify_user`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `verify_user`(IN `i_username` varchar(255), IN `i_token` INT, OUT `o_status` varchar(255))
BEGIN
	DECLARE userId INT;
	DECLARE userToken INT;
	DECLARE _password VARCHAR(255);

	SELECT id, token FROM users WHERE username = lcase(i_username) INTO userId, userToken;
	SET _password = NULL;
	
	IF userId IS NULL THEN
		SET o_status = 'badtoken';
	ELSEIF userToken IS NULL THEN
		SET o_status = 'badtoken';
	ElSEIF userToken != i_token THEN
		SET o_status = 'badtoken';
	ELSE
		-- generate a new password
		SET _password = CONCAT(SUBSTRING('abcdefghijklmnopqrstuvwxyz0123456789', RAND()*36+1, 1),
              SUBSTRING('abcdefghijklmnopqrstuvwxyz0123456789', RAND()*36+1, 1),
              SUBSTRING('abcdefghijklmnopqrstuvwxyz0123456789', RAND()*36+1, 1),
              SUBSTRING('abcdefghijklmnopqrstuvwxyz0123456789', RAND()*36+1, 1),
              SUBSTRING('abcdefghijklmnopqrstuvwxyz0123456789', RAND()*36+1, 1),
              SUBSTRING('abcdefghijklmnopqrstuvwxyz0123456789', RAND()*36+1, 1),
              SUBSTRING('abcdefghijklmnopqrstuvwxyz0123456789', RAND()*36+1, 1),
              SUBSTRING('abcdefghijklmnopqrstuvwxyz0123456789', RAND()*36+1, 1)
             );
             
      START TRANSACTION;
      UPDATE users SET password = PASSWORD(_password), token = NULL WHERE id = userId;
			SELECT _password password;
      COMMIT;
			SET o_status = 'success'; 
	END IF;
END
;;
DELIMITER ;
