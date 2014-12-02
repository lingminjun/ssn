
db 后期 实现 建议

    1、一个干净的database，只负责db打开和关闭已经执行语句，执行语句包含通过反射赋值给对象。
    2、db_pool引入，通过路径取拿当前线程的database，前期先做一个path一个database好了，多线程配置不一定成功
    3、table_description主要组织创建表结构，描述文件可以定义多种形式，xml,json,或者另外的db
    4、table_manager引入，主要负责表的创建和drop，已经升级过程，还有表内容的增删改。背后依赖一个db，维护表状态。
       表升级描述文件加载依赖table_description
    5、model文件不做定义，只要放入table_manager中操作即可（副本模式非常负责，不适合移动客户端实现）

model 副本 模式 优势

    1、懒加载，明确出主键


model 副本 管理，主要抽象传 SSNDBContext来管理
    1、数据版本定义，两个字段：本地opt（操作数），remote_version，
    2、数据副本操作记录opt，（opt + 1）



三点（内存，磁盘，云）同步方案：

重点是model的职责
1、model需要记录版本 
    model (biz_data, cur_tag, pre_tag)
2、model交容易序列，序列 哈希 得 版本号tag（版本号在历史长河中可以重复，一旦重复可以毫不犹豫认为数据回到了原来值）
    hash(serialized(biz_data)) = cur_tag
3、model版本管理表log表，存储序列，必要时可以反序列成数据
    deserialized(serialized(biz_data)) = biz_data
    log_table (cur_tag, pre_tag, serialized(biz_data), biz_data_class)
4、model数据表每次update数据仅仅更新内存修改的部分，其他字段自动忽略（特别重要）
5、多个版本之间的数据可以merge，通过pre_tag倒推到现有版本，一次修改字段，计算需要update的内容

流量、稳定都还行， 性能在赋值受影响



同步协议：

场景一、一次正常的用户操作行为

user---->write db---->hook---->remote rpc---->cloud db---->notice client(biz_type)---->pull update(biz_type, cur_tag)
          ack 200<-------------remote rpc

客户端有状态，故:client_model(biz_data, cur_tag, pre_tag, status)
服务端没状态，故:server_model(biz_data, cur_tag, pre_tag)

客户端记日志，故:clent_log(serialized(biz_data), cur_tag, pre_tag) //serialized(biz_data)用于merge工作（耗时可以接受）

服务端ack时，客户端响应修改status，status变化仅仅通知ui层，不触发rpc，tag不改变



