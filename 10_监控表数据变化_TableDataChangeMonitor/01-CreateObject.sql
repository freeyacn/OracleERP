
--创建日志表
create table CUX_TRACE_LOG_T(line_id number , table_name varchar2(64) , action_msg varchar2(2000) , creation_date timestamp DEFAULT systimestamp);
create index CUX_TRACE_LOG_N1 on CUX_TRACE_LOG_T(line_id);


--创建触发器记录表
create table CUX_TRACE_OBJECTS_T(line_id number not null ,table_name varchar2(64) , Trigger_name varchar2(64) not null , status varchar2(16) , creation_date date default sysdate ) ;
create index CUX_TRACE_OBJECTS_N1 on CUX_TRACE_OBJECTS_T (status);
create index CUX_TRACE_OBJECTS_N2 on CUX_TRACE_OBJECTS_T (line_id);



--创建序列
create sequence CUX_TRACE_LINE_S start with 1 increment by 1 nocache;
