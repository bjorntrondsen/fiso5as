CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE TABLE "managers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "fpl_id" integer, "team_id" integer, "fpl_name" varchar(255), "fiso_name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "matches" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "game_week" integer, "home_team_id" integer, "away_team_id" integer, "starts_at" datetime, "ends_at" datetime, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "teams" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "fpl_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "h2h_matches" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "match_id" integer, "match_order" integer, "home_manager_id" integer, "away_manager_id" integer, "home_score" integer, "away_score" integer, "info" text, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "players" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "h2h_match_id" integer, "manager_id" integer, "name" varchar(255), "games_left" integer, "captain" boolean, "vice_captain" boolean, "bench" boolean, "position" varchar(255), "points" integer, "minutes_played" integer, "match_over" boolean, "created_at" datetime, "updated_at" datetime, "match_status" varchar(255) DEFAULT 'over');
INSERT INTO schema_migrations (version) VALUES ('20130825124819');

INSERT INTO schema_migrations (version) VALUES ('20130825125254');

INSERT INTO schema_migrations (version) VALUES ('20130825132201');

INSERT INTO schema_migrations (version) VALUES ('20130825132433');

INSERT INTO schema_migrations (version) VALUES ('20130825132813');

INSERT INTO schema_migrations (version) VALUES ('20131019145313');
