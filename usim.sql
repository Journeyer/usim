CREATE TABLE usim_list
       ("id" INTEGER PRIMARY KEY NOT NULL,
       "done" BOOLEAN DEFAULT "f",
       "msisdn" VARCHAR(255) DEFAULT "",
       "imei" VARCHAR(255) DEFAULT "",
       "serial" VARCHAR(255) DEFAULT "",
       "operator" VARCHAR(255) DEFAULT "",
       "user_name" VARCHAR(255) DEFAULT "",
       "user_team" VARCHAR(255) DEFAULT "",
       "created_at" DATETIME);
