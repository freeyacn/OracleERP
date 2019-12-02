# 数据表变化监控

对Oracle数据库中的表数据操作(Insert/Update/Delete),进行监控,以了解应用产品的操作会对哪些表产生影响

针对Oracle ERP产品, 从业人员都清楚的知道该产品的庞大与复杂，很多顾问仅从事其中的一个或几个模块的相关工作，并无法了解全部，当我们遇到异常情况或需要了解某个功能的底层数据结构时，那么这个数据表监控将会很有用处


### 1.安装对象
使用PL/SQL工具，连接至数据库,并运行以下脚本

    01-createObject.sql
    02-CUX_TRACE_PKG.pck



### 2.入门使用
#### 2.1 为指定表创建触发器
以下举例,为FA用户的FA_BOOK开头的表对象增加触发器

    SQL> set serveroutput on;
    SQL> exec cux_trace_pkg.TRG_CREATE(P_OWNER => 'FA',P_TABLE_NAME => 'FA_BOOK%' );
    
    ---------------------------------------------------------------------
    
    开始创建触发器  
    
    ---------------------------------------------------------------------
    开始时间:2019/11/28 16:27:45
    
        1 成功  FA_ACE_BOOKS	FA_ACE_BOOKS9046_FTRG
        2 成功  FA_ADDITIONS_B	FA_ADDITIONS_B7235_FTRG
        3 成功  FA_ADDITIONS_TL	FA_ADDITIONS_TL3177_FTRG
        4 成功  FA_ADDITION_REP_ITF	FA_ADDITION_REP_ITF3912_FTRG
        5 成功  FA_ADD_WARRANTIES	FA_ADD_WARRANTIES5759_FTRG
        6 成功  FA_ADJUSTMENTS	FA_ADJUSTMENTS8987_FTRG
        7 成功  FA_ADJUSTMENTS_T	FA_ADJUSTMENTS_T3081_FTRG
        8 成功  FA_ADJUST_REP_ITF	FA_ADJUST_REP_ITF6933_FTRG
        9 成功  FA_AMORT_SCHEDULES	FA_AMORT_SCHEDULES2103_FTRG
    ------end-----2019/11/28 16:27:46
    
    PL/SQL procedure successfully completed
#### 2.2 删除表创建的触发器
清理3.1步骤创建的触发器
    SQL> exec cux_trace_pkg.TRG_DROP;
    
    ---------------------------------------------------------------------
    
    开始卸载创建的触发器  
    
    ---------------------------------------------------------------------
    开始时间:2019/11/28 16:27:51
    
    发现触发器个数:0
    
        1  存在  FA_ACE_BOOKS9046_FTRG  删除成功
        2  存在  FA_ADDITIONS_B7235_FTRG  删除成功
        3  存在  FA_ADDITIONS_TL3177_FTRG  删除成功
        4  存在  FA_ADDITION_REP_ITF3912_FTRG  删除成功
        5  存在  FA_ADD_WARRANTIES5759_FTRG  删除成功
        6  存在  FA_ADJUSTMENTS8987_FTRG  删除成功
        7  存在  FA_ADJUSTMENTS_T3081_FTRG  删除成功
        8  存在  FA_ADJUST_REP_ITF6933_FTRG  删除成功
        9  存在  FA_AMORT_SCHEDULES2103_FTRG  删除成功
    ---------------------------------------------------------------------
    结束时间:2019/11/28 16:27:51
    
    PL/SQL procedure successfully completed

#### 2.3 触发器对象创建的记录表
    SQL> select * from cux_trace_objects_t;
    
    LINE_ID TABLE_NAME                    TRIGGER_NAME                         STATUS           CREATION_DATE
    ---------- ---------------------------- ------------------------------------- ---------------- -------------
            11 FA_ACE_BOOKS                 FA_ACE_BOOKS9046_FTRG                 DELETED          2019-11-28 16
            12 FA_ADDITIONS_B               FA_ADDITIONS_B7235_FTRG               DELETED          2019-11-28 16
            13 FA_ADDITIONS_TL              FA_ADDITIONS_TL3177_FTRG              DELETED          2019-11-28 16
            14 FA_ADDITION_REP_ITF          FA_ADDITION_REP_ITF3912_FTRG          DELETED          2019-11-28 16
            15 FA_ADD_WARRANTIES            FA_ADD_WARRANTIES5759_FTRG            DELETED          2019-11-28 16
            16 FA_ADJUSTMENTS               FA_ADJUSTMENTS8987_FTRG               DELETED          2019-11-28 16
            17 FA_ADJUSTMENTS_T             FA_ADJUSTMENTS_T3081_FTRG             DELETED          2019-11-28 16
            18 FA_ADJUST_REP_ITF            FA_ADJUST_REP_ITF6933_FTRG            DELETED          2019-11-28 16
            19 FA_AMORT_SCHEDULES           FA_AMORT_SCHEDULES2103_FTRG           DELETED          2019-11-28 16
    
    18 rows selected
    
    SQL> 

### 3. 正常操作前台业务

### 4. 查看日志
操作完成后，即可通过以下语句查看前台操作对应的后台表的实际增删改查的过程

    SQL> select * from CUX_TRACE_LOG_T order by line_id desc 

### 5.卸载对象
使用PL/SQL工具，连接至数据库,并运行以下脚本

    03-dropObject.sql
