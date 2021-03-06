
Insert json text into clob column
Dont use reserved words in json attribute names.
Apply validate as json constraint
Query using simple dot notation.


CREATE TABLE "NOWTV2"."MDB_ACCOUNTS"
( "ID" VARCHAR2(1000 BYTE) NOT NULL DISABLE,
"SHARDKEY" VARCHAR2(1000 BYTE),
"FIRSTPLAYOUT" CLOB,
"HASWALLET" VARCHAR2(1000 BYTE),
"PARENTALPIN" CLOB,
"PAYMENTPIN" CLOB,
"RECENTSEARCHES" CLOB,
"CREATED" VARCHAR2(500 BYTE),
"TRACKINGIDS" CLOB,
"PLAYOUTS" CLOB,
"CLASS" CLOB,
"PAYMENTPINHASH" VARCHAR2(2000 BYTE),
"ISSUPERUSER" VARCHAR2(1000 BYTE),
"DATETIME_IMPORTED" TIMESTAMP (6),
CONSTRAINT "VALID_JSON_PLAYOUTS" CHECK (PLAYOUTS IS JSON) DISABLE,
CONSTRAINT "VALID_JSON_TRACKINGIDS" CHECK (TRACKINGIDS IS JSON) DISABLE,
CONSTRAINT "VALID_JSON_RECENTSEARCHES" CHECK (RECENTSEARCHES IS JSON) DISABLE,
CONSTRAINT "VALID_JSON_PAYMENTPIN" CHECK (paymentpin IS JSON) DISABLE,
CONSTRAINT "VALID_JSON_PARENTALPIN" CHECK (parentalpin IS JSON) DISABLE,
CONSTRAINT "VALID_JSON_FIRSTPLAYOUT" CHECK (firstplayout IS JSON) DISABLE,
CONSTRAINT "MDB_ACCOUNTS_PK" PRIMARY KEY ("ID")









SELECT ID,
SHARDKEY,
--FIRSTPLAYOUT,
a.FIRSTPLAYOUT.status firstplayout_status,
HASWALLET,
--PARENTALPIN,
a.parentalpin.certificate parentalPin_certificate,
a.parentalpin.enabled parentalPin_Enabled,
a.parentalpin.hash parentalpin_hash,
--PAYMENTPIN,
a.PAYMENTPIN.enabled paymentPin_Enabled,
RECENTSEARCHES,
CREATED,
--TRACKINGIDS,
a.trackingids.player trackingids_player,
--PLAYOUTS,
a.playouts.version playouts_version,
a.playouts.currentPlayouts current_playouts,
CLASS,
paymentpinhash,
issuperuser
FROM mdb_accounts a