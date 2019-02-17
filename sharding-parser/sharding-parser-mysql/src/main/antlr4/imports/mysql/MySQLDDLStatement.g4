grammar MySQLDDLStatement;

import MySQLKeyword, Keyword, Symbol, MySQLDQLStatement, DataType, MySQLBase, BaseRule;

createTable
    : CREATE TEMPORARY? TABLE (IF NOT EXISTS)? tableName (LP_ createDefinitions_ RP_ | createLike_)
    ;

createDefinitions_
    : createDefinition_ (COMMA_ createDefinition_)*
    ;

createDefinition_
    : columnDefinition | constraintDefinition | indexDefinition | checkExpr_
    ;

checkExpr_
    : CHECK expr
    ;

createLike_
    : LIKE tableName | LP_ LIKE tableName RP_
    ;

columnDefinition
    : columnName dataType (dataTypeOption_* | dataTypeGenerated_?)
    ;

dataType
    : typeName_ dataTypeLength_? characterSet_? collateClause_? UNSIGNED? ZEROFILL? | typeName_ LP_ STRING_ (COMMA_ STRING_)* RP_ characterSet_? collateClause_?
    ;

typeName_
    : DOUBLE PRECISION | ID
    ;

dataTypeLength_
    : LP_ NUMBER_ (COMMA_ NUMBER_)? RP_
    ;

characterSet_
    : (CHARACTER | CHAR) SET EQ_? charsetName_ | CHARSET EQ_? charsetName_
    ;

charsetName_
    : ID | BINARY
    ;

collateClause_
    : COLLATE EQ_? collationName_
    ;

collationName_
    : STRING_ | ID
    ;

dataTypeOption_
    : dataTypeGeneratedOption_
    | DEFAULT? defaultValue_
    | AUTO_INCREMENT
    | COLUMN_FORMAT (FIXED | DYNAMIC | DEFAULT)
    | STORAGE (DISK | MEMORY | DEFAULT)
    | referenceDefinition_
    ;

dataTypeGeneratedOption_
    : NULL | NOT NULL | UNIQUE KEY? | primaryKey | COMMENT STRING_
    ;

defaultValue_
    : NULL | NUMBER_ | STRING_ | currentTimestampType_ (ON UPDATE currentTimestampType_)? | ON UPDATE currentTimestampType_
    ;

currentTimestampType_
    : (CURRENT_TIMESTAMP | LOCALTIME | LOCALTIMESTAMP | NOW | NUMBER_) dataTypeLength_?
    ;

referenceDefinition_
    : REFERENCES tableName LP_ keyParts_ RP_ (MATCH FULL | MATCH PARTIAL | MATCH SIMPLE)? referenceType_*
    ;

referenceType_
    : ON (UPDATE | DELETE) referenceOption_
    ;

referenceOption_
    : RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT
    ;

dataTypeGenerated_
    : (GENERATED ALWAYS)? AS expr (VIRTUAL | STORED)? dataTypeGeneratedOption_*
    ;

constraintDefinition
    : (CONSTRAINT symbol?)? (primaryKeyOption_ | uniqueOption_ | foreignKeyOption_)
    ;

primaryKeyOption_
    : primaryKey indexType? columnList indexOption*
    ;

uniqueOption_
    : UNIQUE indexAndKey? indexName? indexType? LP_ keyParts_ RP_ indexOption*
    ;

foreignKeyOption_
    : FOREIGN KEY indexName? columnNamesWithParen referenceDefinition_
    ;

indexDefinition
    : (FULLTEXT | SPATIAL)? indexAndKey? indexName? indexType? LP_ keyParts_ RP_ indexOption*
    ;

keyParts_
    : keyPart_ (COMMA_ keyPart_)*
    ;

keyPart_
    : columnName (LP_ NUMBER_ RP_)? (ASC | DESC)?
    ;

alterTable
    : ALTER TABLE tableName alterSpecifications_?
    ;

alterSpecifications_
    : alterSpecification_ (COMMA_ alterSpecification_)*
    ;

alterSpecification_
    : tableOptions_
    | addColumn
    | addIndex
    | addConstraint
    | ALGORITHM EQ_? (DEFAULT | INPLACE | COPY)
    | ALTER COLUMN? columnName (SET DEFAULT | DROP DEFAULT)
    | changeColumn
    | DEFAULT? characterSet_ collateClause_?
    | CONVERT TO characterSet_ collateClause_?
    | (DISABLE | ENABLE) KEYS
    | (DISCARD | IMPORT_) TABLESPACE
    | dropColumn
    | dropIndexDef
    | dropPrimaryKey
    | DROP FOREIGN KEY fkSymbol
    | FORCE
    | LOCK EQ_? (DEFAULT | NONE | SHARED | EXCLUSIVE)
    | modifyColumn
    | ORDER BY columnName (COMMA_ columnName)*
    | renameIndex
    | renameTable
    | (WITHOUT | WITH) VALIDATION
    | ADD PARTITION partitionDefinitions_
    | DROP PARTITION partitionNames
    | DISCARD PARTITION (partitionNames | ALL) TABLESPACE
    | IMPORT_ PARTITION (partitionNames | ALL) TABLESPACE
    | TRUNCATE PARTITION (partitionNames | ALL)
    | COALESCE PARTITION NUMBER_
    | REORGANIZE PARTITION partitionNames INTO partitionDefinitions_
    | EXCHANGE PARTITION partitionName WITH TABLE tableName ((WITH | WITHOUT) VALIDATION)?
    | ANALYZE PARTITION (partitionNames | ALL)
    | CHECK PARTITION (partitionNames | ALL)
    | OPTIMIZE PARTITION (partitionNames | ALL)
    | REBUILD PARTITION (partitionNames | ALL)
    | REPAIR PARTITION (partitionNames | ALL)
    | REMOVE PARTITIONING
    | UPGRADE PARTITIONING
    ;

singleColumn
    : columnDefinition firstOrAfterColumn?
    ;

firstOrAfterColumn
    : FIRST | AFTER columnName
    ;

multiColumn
    : LP_ columnDefinition (COMMA_ columnDefinition)* RP_
    ;

addConstraint
    : ADD constraintDefinition
    ;

addIndex
    : ADD indexDefinition
    ;

addColumn
    : ADD COLUMN? (singleColumn | multiColumn)
    ;

changeColumn
    : changeColumnOp columnName columnDefinition firstOrAfterColumn?
    ;

changeColumnOp
    : CHANGE COLUMN?
    ;

dropColumn
    : DROP COLUMN? columnName
    ;

dropIndexDef
    : DROP indexAndKey indexName
    ;

dropPrimaryKey
    : DROP primaryKey
    ;

fkSymbol
    : ID
    ;

modifyColumn
    : MODIFY COLUMN? columnDefinition firstOrAfterColumn?
    ;

renameIndex
    : RENAME indexAndKey indexName TO indexName
    ;

renameTable
    : RENAME (TO | AS)? tableName
    ;

tableOptions_
    : tableOption_ (COMMA_? tableOption_)*
    ;

tableOption_
    : AUTO_INCREMENT EQ_? NUMBER_
    | AVG_ROW_LENGTH EQ_? NUMBER_
    | DEFAULT? (characterSet_ | collateClause_)
    | CHECKSUM EQ_? NUMBER_
    | COMMENT EQ_? STRING_
    | COMPRESSION EQ_? STRING_
    | CONNECTION EQ_? STRING_
    | (DATA | INDEX) DIRECTORY EQ_? STRING_
    | DELAY_KEY_WRITE EQ_? NUMBER_
    | ENCRYPTION EQ_? STRING_
    | ENGINE EQ_? engineName_
    | INSERT_METHOD EQ_? (NO | FIRST | LAST)
    | KEY_BLOCK_SIZE EQ_? NUMBER_
    | MAX_ROWS EQ_? NUMBER_
    | MIN_ROWS EQ_? NUMBER_
    | PACK_KEYS EQ_? (NUMBER_ | DEFAULT)
    | PASSWORD EQ_? STRING_
    | ROW_FORMAT EQ_? (DEFAULT | DYNAMIC | FIXED | COMPRESSED | REDUNDANT | COMPACT)
    | STATS_AUTO_RECALC EQ_? (DEFAULT | NUMBER_)
    | STATS_PERSISTENT EQ_? (DEFAULT | NUMBER_)
    | STATS_SAMPLE_PAGES EQ_? NUMBER_
    | TABLESPACE tablespaceName (STORAGE (DISK | MEMORY | DEFAULT))?
    | UNION EQ_? tableList
    ;

engineName_
    : ID | MEMORY
    ;

partitionOptions_
    : PARTITION BY (linearPartition_ | rangeOrListPartition_) (PARTITIONS NUMBER_)? (SUBPARTITION BY linearPartition_ (SUBPARTITIONS NUMBER_)?)? (LP_ partitionDefinitions_ RP_)?
    ;

linearPartition_
    : LINEAR? (HASH (yearFunctionExpr_ | expr) | KEY (ALGORITHM EQ_ NUMBER_)? columnNamesWithParen)
    ;

yearFunctionExpr_
    : LP_ YEAR expr RP_
    ;

rangeOrListPartition_
    : (RANGE | LIST) (expr | COLUMNS columnNamesWithParen)
    ;

partitionDefinitions_
    : partitionDefinition_ (COMMA_ partitionDefinition_)*
    ;

partitionDefinition_
    : PARTITION partitionName (VALUES (lessThanPartition_ | IN assignmentValueList))? partitionDefinitionOption_* (LP_ subpartitionDefinition_ (COMMA_ subpartitionDefinition_)* RP_)?
    ;

partitionDefinitionOption_
    : STORAGE? ENGINE EQ_? engineName_
    | COMMENT EQ_? STRING_
    | DATA DIRECTORY EQ_? STRING_
    | INDEX DIRECTORY EQ_? STRING_
    | MAX_ROWS EQ_? NUMBER_
    | MIN_ROWS EQ_? NUMBER_
    | TABLESPACE EQ_? tablespaceName
    ;

lessThanPartition_
    : LESS THAN (LP_ (expr | assignmentValues) RP_ | MAXVALUE)
    ;

subpartitionDefinition_
    : SUBPARTITION partitionName partitionDefinitionOption_*
    ;

partitionNames
    : partitionName (COMMA_ partitionName)*
    ;

dropTable
    : DROP TEMPORARY? TABLE (IF EXISTS)? tableNames
    ;

truncateTable
    : TRUNCATE TABLE? tableName
    ;

createIndex
    : CREATE (UNIQUE | FULLTEXT | SPATIAL)? INDEX indexName indexType? ON tableName
    ;

dropIndex
    : DROP INDEX (ONLINE | OFFLINE)? indexName ON tableName
    ;
