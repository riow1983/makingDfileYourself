CREATE TABLE dpc_order
(患者番号 INTEGER,
患者氏名 VARCHAR(255),
DPCコード VARCHAR(255),
診断群分類名称 VARCHAR(255),
入院日（転入日） DATE,
退院日（転出日） DATE,
入院期間Ⅰ INTEGER,
入院期間Ⅱ INTEGER,
入院期間Ⅲ INTEGER,
DPC対象外区分 BOOLEAN,
id SERIAL PRIMARY KEY);
