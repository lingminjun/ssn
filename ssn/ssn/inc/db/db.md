
db 后期 实现 建议

    1、一个干净的database，只负责db打开和关闭已经执行语句，执行语句包含通过反射赋值给对象。
    2、db_pool引入，通过路径取拿当前线程的database，前期先做一个path一个database好了，多线程配置不一定成功
    3、table_description主要组织创建表结构，描述文件可以定义多种形式，xml,json,或者另外的db
    4、table_manager引入，主要负责表的创建和drop，已经升级过程，还有表内容的增删改。背后依赖一个db，维护表状态。
       表升级描述文件加载依赖table_description
    5、model文件不做定义，只要放入table_manager中操作即可（副本模式非常负责，不是和移动客户端实现）

model 副本 模式 优势

    1、懒加载，明确出主键

