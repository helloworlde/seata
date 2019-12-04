-- for AT mode you must to init this sql for you business databese. the seata server not need it.
CREATE TABLE IF NOT EXISTS `undo_log`
(
    `id`            BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT 'increment id',
    `branch_id`     BIGINT(20)   NOT NULL COMMENT 'branch transaction id',
    `xid`           VARCHAR(100) NOT NULL COMMENT 'global transaction id',
    `context`       VARCHAR(128) NOT NULL COMMENT 'undo_log context,such as serialization',
    `rollback_info` LONGBLOB     NOT NULL COMMENT 'rollback info',
    `log_status`    INT(11)      NOT NULL COMMENT '0:normal status,1:defense status',
    `log_created`   DATETIME     NOT NULL COMMENT 'create datetime',
    `log_modified`  DATETIME     NOT NULL COMMENT 'modify datetime',
    `ext`           VARCHAR(100) DEFAULT NULL COMMENT 'reserved field',
    PRIMARY KEY (`id`),
    UNIQUE KEY `ux_undo_log` (`xid`, `branch_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8 COMMENT ='AT transaction mode undo table';



-- -------------------------------- The script used when storeMode is 'db' --------------------------------
-- the table to store GlobalSession data
CREATE TABLE IF NOT EXISTS `global_table`
(
    `xid`                       VARCHAR(128) NOT NULL,
    `transaction_id`            BIGINT,
    `status`                    TINYINT      NOT NULL,
    `application_id`            VARCHAR(32),
    `transaction_service_group` VARCHAR(32),
    `transaction_name`          VARCHAR(128),
    `timeout`                   INT,
    `begin_time`                BIGINT,
    `application_data`          VARCHAR(2000),
    `gmt_create`                DATETIME,
    `gmt_modified`              DATETIME,
    PRIMARY KEY (`xid`),
    KEY `idx_gmt_modified_status` (`gmt_modified`, `status`),
    KEY `idx_transaction_id` (`transaction_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

-- the table to store BranchSession data
CREATE TABLE IF NOT EXISTS `branch_table`
(
    `branch_id`         BIGINT       NOT NULL,
    `xid`               VARCHAR(128) NOT NULL,
    `transaction_id`    BIGINT,
    `resource_group_id` VARCHAR(32),
    `resource_id`       VARCHAR(256),
    `branch_type`       VARCHAR(8),
    `status`            TINYINT,
    `client_id`         VARCHAR(64),
    `application_data`  VARCHAR(2000),
    `gmt_create`        DATETIME,
    `gmt_modified`      DATETIME,
    PRIMARY KEY (`branch_id`),
    KEY `idx_xid` (`xid`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

-- the table to store lock data
CREATE TABLE IF NOT EXISTS `lock_table`
(
    `row_key`        VARCHAR(128) NOT NULL,
    `xid`            VARCHAR(96),
    `transaction_id` BIGINT,
    `branch_id`      BIGINT       NOT NULL,
    `resource_id`    VARCHAR(256),
    `table_name`     VARCHAR(32),
    `pk`             VARCHAR(36),
    `gmt_create`     DATETIME,
    `gmt_modified`   DATETIME,
    PRIMARY KEY (`row_key`),
    KEY `idx_branch_id` (`branch_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;


-- -------------------------------- The script used for sage  --------------------------------
CREATE TABLE IF NOT EXISTS `seata_state_machine_def`
(
    `id`               VARCHAR(32)  NOT NULL COMMENT 'id',
    `name`             VARCHAR(255) NOT NULL COMMENT 'name',
    `tenant_id`        VARCHAR(32)  NOT NULL COMMENT 'tenant id',
    `app_name`         VARCHAR(32)  NOT NULL COMMENT 'application name',
    `type`             VARCHAR(20) COMMENT 'state language type',
    `comment_`         VARCHAR(255) COMMENT 'comment',
    `ver`              VARCHAR(16)  NOT NULL COMMENT 'version',
    `gmt_create`       TIMESTAMP    NOT NULL COMMENT 'create time',
    `status`           VARCHAR(2)   NOT NULL COMMENT 'status(AC:active|IN:inactive)',
    `content`          TEXT COMMENT 'content',
    `recover_strategy` VARCHAR(16) COMMENT 'transaction recover strategy(compensate|retry)',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `seata_state_machine_inst`
(
    `id`                  VARCHAR(32)             NOT NULL COMMENT 'id',
    `machine_id`          VARCHAR(32)             NOT NULL COMMENT 'state machine definition id',
    `tenant_id`           VARCHAR(32)             NOT NULL COMMENT 'tenant id',
    `parent_id`           VARCHAR(46) COMMENT 'parentid',
    `gmt_started`         TIMESTAMP               NOT NULL COMMENT 'start time',
    `business_key`        VARCHAR(48) COMMENT 'business key',
    `start_params`        TEXT COMMENT 'start parameters',
    `gmt_end`             TIMESTAMP DEFAULT now() COMMENT 'end time',
    `excep`               BLOB COMMENT 'exception',
    `end_params`          TEXT COMMENT 'end parameters',
    `status`              VARCHAR(2) COMMENT 'status(SU succeed|FA failed|UN unknown|SK skipped|RU running)',
    `compensation_status` VARCHAR(2) COMMENT 'compensation status(SU succeed|FA failed|UN unknown|SK skipped|RU running)',
    `is_running`          TINYINT(1) COMMENT 'is running(0 no|1 yes)',
    `gmt_updated`         TIMESTAMP DEFAULT now() NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unikey_buz_tenant` (`business_key`, `tenant_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `seata_state_inst`
(
    `id`                       VARCHAR(32)  NOT NULL COMMENT 'id',
    `machine_inst_id`          VARCHAR(32)  NOT NULL COMMENT 'state machine instance id',
    `name`                     VARCHAR(255) NOT NULL COMMENT 'state name',
    `type`                     VARCHAR(20) COMMENT 'state type',
    `service_name`             VARCHAR(255) COMMENT 'service name',
    `service_method`           VARCHAR(255) COMMENT 'method name',
    `service_type`             VARCHAR(16) COMMENT 'service type',
    `business_key`             VARCHAR(48) COMMENT 'business key',
    `state_id_compensated_for` VARCHAR(32) COMMENT 'state compensated for',
    `state_id_retried_for`     VARCHAR(32) COMMENT 'state retried for',
    `gmt_started`              TIMESTAMP    NOT NULL COMMENT 'start time',
    `is_for_update`            TINYINT(1) COMMENT 'is service for update',
    `input_params`             TEXT COMMENT 'input parameters',
    `output_params`            TEXT COMMENT 'output parameters',
    `status`                   VARCHAR(2)   NOT NULL COMMENT 'status(SU succeed|FA failed|UN unknown|SK skipped|RU running)',
    `excep`                    BLOB COMMENT 'exception',
    `gmt_end`                  TIMESTAMP DEFAULT now() COMMENT 'end time',
    PRIMARY KEY (`id`, `machine_inst_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;