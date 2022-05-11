
## navicat 数据字典
    SELECT
    	a.TABLE_NAME AS '表名',
    	b.TABLE_COMMENT AS '表备注',
    	a.COLUMN_NAME AS '字段名',
    	a.COLUMN_COMMENT AS '字段备注',
    IF( a.COLUMN_DEFAULT = '', '空字符串', IFNULL( a.COLUMN_DEFAULT, '无' ) ) AS '默认值',
    	a.COLUMN_TYPE AS '数据类型',
    	a.IS_NULLABLE AS '是否可空'
    FROM
    	information_schema.COLUMNS AS a
    	JOIN information_schema.TABLES AS b ON a.TABLE_SCHEMA = b.TABLE_SCHEMA 
    	AND a.TABLE_NAME = b.TABLE_NAME 
    WHERE
    	a.TABLE_SCHEMA = 'vm' # 这里修改为数据库名
    	# 单表时加上下方条件
    	 AND a.TABLE_NAME like 'vm_%' # 这里修改为表名





