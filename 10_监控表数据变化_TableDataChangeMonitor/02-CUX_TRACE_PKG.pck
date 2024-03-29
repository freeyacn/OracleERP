Create Or Replace Package CUX_TRACE_PKG Is

  --===============================================================
  -- Package Name : CUX_TRACE_PKG
  -- Purpose      : 主要工作内容：
  --                  1.面向用户:对Oralce产品功能代码执行顺序的分析,如:Oracle ERP
  --                  2.仅跟踪某项操作的新增/删除/更新,但目前并不记录更新前后的数据变化
  --                
  --                使用流程：
  --                  1.使用install.sql脚本,在数据库中安装所需的对象 
  --                  2.使用该程序包中的trg_create方法批量为表增加触发器
  --                  3.进行某项操作,然后查询日志跟踪表中的执行情况 
  --                  4.当使用完成后,即可执行uninstall.sql,卸载掉
  --
  --                创建对象:
  --                   1.表       :    2个
  --                   2.序列     ：   1个
  --                   3.存储过程 :    1个
  -- Author       : FREEYA
  -- Date         : 2019-11-20 17:45:22
  -- History      : ……
  --
  --===============================================================

  --===============================================================
  -- Package Name : trg_create
  -- Purpose      : 为符合条件的表创建触发器,并记录至客户化表中
  -- Parameter    :  1. p_owner        所有者     如HR
  --                 2. p_table_name   表名,支持%通配符, 如有需要可改为正则表达式
  --                 3. p_max_num      符合以上两个条件的随机取前多少条记录
  -- Author       : FREEYA
  -- Date         : 2019-11-20 17:45:22
  -- History      : ……
  --
  --===============================================================
  Procedure TRG_CREATE(P_OWNER      In Varchar2
                      ,P_TABLE_NAME In Varchar2
                      ,P_MAX_NUM    In Number Default 99999);

  Procedure TRG_DROP;

  --===============================================================
  -- Package Name : LOG
  -- Purpose      : 记录跟踪日志
  -- Parameter    :  1. P_TABLE_NAME        表名
  --                 2. P_ACTION            insert/delete/update 
  -- Author       : FREEYA
  -- Date         : 2019-11-20 17:45:22
  -- History      : ……
  --
  --===============================================================
  Procedure LOG(P_TABLE_NAME In Varchar2
               ,P_ACTION     In Varchar2);

End CUX_TRACE_PKG;
/
create or replace package body CUX_TRACE_PKG is



--===============================================================
  -- Package Name : trg_create
  -- Purpose      : 为符合条件的表创建触发器,并记录至客户化表中
  -- Parameter    :  1. p_owner        所有者     如HR
  --                 2. p_table_name   表名,支持%通配符, 如有需要可改为正则表达式
  --                 3. p_max_num      符合以上两个条件的随机取前多少条记录
  -- Author       : FREEYA
  -- Date         : 2019-11-20 17:45:22
  -- History      : ……
  --
  --===============================================================
 PROCEDURE trg_create(p_owner in varchar2 , p_table_name in varchar2 , p_max_num in number default 99999 ) Is
     l_table_name varchar2(30);
     l_trigger_name varchar2(30);
     l_i number := 0;
     l_cnt number;
     l_random varchar2(10);
 Begin
   
    Dbms_output.put_line('---------------------------------------------------------------------'); 
    Dbms_output.put_line('   '); 
    Dbms_output.put_line(' 开始创建触发器  '); 
    Dbms_output.put_line('   '); 
    Dbms_output.put_line('---------------------------------------------------------------------');
    Dbms_output.put_line('开始时间:'||to_char(sysdate,'yyyy/mm/dd hh24:mi:ss'));  
    Dbms_output.put_line('   ');  
    for c1 in (  select * from all_tables t where t.OWNER = P_OWNER and TABLE_NAME LIKE P_TABLE_NAME ) loop
      
         l_i := l_i + 1 ;
         l_table_name := c1.table_name;
         dbms_random.seed(c1.table_name);
         l_random := round(dbms_random.value(1000 , 9999)); 
         l_trigger_name := substr(l_table_name,1,20)||l_random||'_FTRG';
                 
     
          select count(1) into l_cnt from all_triggers t where t.TABLE_NAME = l_table_name and t.TRIGGER_NAME = l_trigger_name;
          if l_cnt = 1 then 
              Dbms_output.put_line(chr(9)||l_i||'  存在  '||l_table_name ||chr(9)||l_trigger_name); 
          end if;
          
          if l_cnt = 0 then 
         execute immediate 'create or replace trigger '||l_trigger_name||' 
  before INSERT OR UPDATE OR DELETE on '||P_OWNER||'.'||l_table_name ||'
  for each row
declare    
   l_msg varchar2(100);
begin
     if updating then 
          l_msg := ''updating'';
     end if;
     
     if inserting then 
          l_msg := ''inserting'';
     end if;
     
     if deleting then 
          l_msg := ''deleting'';
     end if;  
     CUX_TRACE_PKG.LOG('||chr(39)||l_table_name||chr(39)||',''>''||l_msg);         
end ;';
    
    
    select count(1) into l_cnt from all_triggers t where t.TABLE_NAME = l_table_name and t.TRIGGER_NAME = l_trigger_name;
    
    if l_cnt >= 1 then 
        insert into CUX_TRACE_OBJECTS_T(LINE_ID,TABLE_NAME,TRIGGER_NAME,STATUS,CREATION_DATE)
        values (CUX_TRACE_LINE_S.Nextval , l_table_name , l_trigger_name , 'CREATED' , sysdate);
        commit;
        Dbms_output.put_line(chr(9)||l_i||' 成功  '||l_table_name ||chr(9)||l_trigger_name); 
    else
        Dbms_output.put_line(chr(9)||l_i||' 失败  '||l_table_name ||chr(9)||l_trigger_name);
    end if;    
    end if;
    
    
    end loop;
 
    Dbms_output.put_line('------end-----'||to_char(sysdate,'yyyy/mm/dd hh24:mi:ss')); 
 
 exception
    when others then
         Dbms_output.put_line('Exception:'||sqlerrm); 
 End trg_create;


 
 PROCEDURE trg_drop  Is
   l_table_name varchar2(30);
   l_trigger_name varchar2(30);
   l_i number := 0;
   l_cnt number;
   l_random varchar2(10);

 Begin 
    Dbms_output.put_line('---------------------------------------------------------------------'); 
    Dbms_output.put_line('   '); 
    Dbms_output.put_line(' 开始卸载创建的触发器  '); 
    Dbms_output.put_line('   '); 
    Dbms_output.put_line('---------------------------------------------------------------------');
    Dbms_output.put_line('开始时间:'||to_char(sysdate,'yyyy/mm/dd hh24:mi:ss')); 
    
    select count(1) into l_cnt from CUX_TRACE_OBJECTS_T ot where ot.status = 'ACTIVE';
    Dbms_output.put_line('   ');
    Dbms_output.put_line('发现触发器个数:'||l_cnt);  
    Dbms_output.put_line('   '); 
    
    --开始循环处理
    for c1 in (  select * from CUX_TRACE_OBJECTS_T ot where ot.status = 'CREATED' order by ot.trigger_name ) loop
      
         l_i := l_i + 1 ;
         l_table_name := c1.table_name;
         dbms_random.seed(c1.table_name);
         l_random := round(dbms_random.value(1000 , 9999)); 
         l_trigger_name := c1.trigger_name;
                   
     
          select count(1) into l_cnt from all_triggers t where t.TABLE_NAME = l_table_name and t.TRIGGER_NAME = l_trigger_name;
          if l_cnt = 1 then 
                            
              execute immediate 'drop trigger '||l_trigger_name;
              
              select count(1) into l_cnt from all_triggers t where t.TABLE_NAME = l_table_name and t.TRIGGER_NAME = l_trigger_name;
              if l_cnt = 0 then 
                  
                  update cux_trace_objects_t ot
                    set ot.status = 'DELETED'
                   where ot.line_id = c1.line_id;
                  commit; 
                  
                  Dbms_output.put_line(chr(9)||l_i||'  存在  '||l_trigger_name ||'  删除成功');  
              else
                  Dbms_output.put_line(chr(9)||l_i||'  存在  '||l_trigger_name ||'  删除失败');
              end if;             
              
          end if;
          
          if l_cnt = 0 then 
              update cux_trace_objects_t ot
                set ot.status = 'DELETED'
               where ot.line_id = c1.line_id;
              commit; 
          end if;
    
    end loop;
    Dbms_output.put_line('---------------------------------------------------------------------');
    Dbms_output.put_line('结束时间:'||to_char(sysdate,'yyyy/mm/dd hh24:mi:ss'));
 
exception
   when others then 
       Dbms_output.put_line('Exception:'||sqlerrm); 
 End trg_drop;

 --===============================================================
  -- Package Name : LOG
  -- Purpose      : 记录跟踪日志
  -- Parameter    :  1. P_TABLE_NAME        表名
  --                 2. P_ACTION            insert/delete/update 
  -- Author       : FREEYA
  -- Date         : 2019-11-20 17:45:22
  -- History      : ……
  --
  --===============================================================
 PROCEDURE LOG( P_TABLE_NAME IN VARCHAR2 , P_ACTION IN VARCHAR2 ) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  insert into CUX_TRACE_LOG_T
     ( line_id , TABLE_NAME, ACTION_msg)
   values
     ( CUX_TRACE_LINE_S.nextval ,  P_TABLE_NAME,P_ACTION);

     COMMIT;
  END;
begin
  NULL;
end CUX_TRACE_PKG;
/
