﻿CREATE TABLE dpcmaster_h28
(番号 INTEGER,
診断群分類番号 TEXT,
傷病名 TEXT,
手術名 TEXT,
手術・処置等１ TEXT,
手術・処置等２ TEXT,
定義副傷病 TEXT,
重症度等 TEXT,
入院期間Ⅰ（日） INTEGER,
入院期間Ⅱ（日） INTEGER,
入院期間Ⅲ（日） INTEGER,
入院期間Ⅰ（点） INTEGER,
入院期間Ⅱ（点） INTEGER,
入院期間Ⅲ（点） INTEGER,
変更区分 INTEGER,
開始日 TEXT,
終了日 TEXT,
更新日 TEXT,
id SERIAL PRIMARY KEY);