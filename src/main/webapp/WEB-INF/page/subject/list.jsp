<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>专业管理</title>
</head>
<body>
<div class="layuimini-container layuimini-page-anim">
    <div class="layuimini-main">
        <div style="margin: 10px">
            <form class="layui-form layui-form-pane">
                <div class="layui-form-item">
                    <div class="layui-inline">
                        <label class="layui-form-label">专业名称</label>
                        <div class="layui-input-inline">
                            <input type="text" name="subjectName" placeholder="请输入专业名称" class="layui-input">
                        </div>
                    </div>
                    <div class="layui-inline">
                        <label class="layui-form-label">所属院系</label>
                        <div class="layui-input-inline">
                            <input type="text" name="college" placeholder="请输入院系名称" class="layui-input">
                        </div>
                    </div>
                    <div class="layui-inline">
                        <button class="layui-btn layui-btn-primary"  lay-submit lay-filter="search-btn"><i class="layui-icon"></i> 搜 索</button>
                    </div>
                </div>
            </form>
        </div>
        <script type="text/html" id="toolbar">
            <div class="layui-btn-container">
                <button class="layui-btn layui-btn-normal layui-btn-sm data-add-btn" lay-event="add">
                    <i class="fa fa-plus"></i>
                    添加
                </button>
                <button class="layui-btn layui-btn-sm layui-btn-normal data-delete-btn" lay-event="update">
                    <i class="fa fa-pencil"></i>
                    修改
                </button>
                <button class="layui-btn layui-btn-sm layui-btn-danger data-delete-btn" lay-event="delete">
                    <i class="fa fa-remove"></i>
                    删除
                </button>
            </div>
        </script>
        <%-- 表格数据--%>
        <table class="layui-hide" id="currentTableId" lay-filter="currentTableFilter"></table>
    </div>
</div>
<script>
    layui.use(['form', 'table'], function () {
        var $ = layui.jquery,
            form = layui.form,
            table = layui.table;

            // 请求后台渲染table表格
            table.render({
                elem: '#currentTableId',
                url: '${basePath}subject/query',
                contentType:'application/json',
                method:"post",
                toolbar: '#toolbar',
                defaultToolbar: ['filter', 'exports', 'print'],
                page: true,
                cols: [[
                    {type: "checkbox", width: 50},
                    {field: 'id', width: 80, title: 'ID'},
                    {field: 'subjectName',  title: '专业名称'},
                    {field: 'college', title: '所属系'},
                    {field: 'remark',title: '备注'}
                ]],
                skin: 'line'
            });

        // 监听搜索操作-data为表单对象，里面的属性json形式
        form.on('submit(search-btn)', function (data) {
            //执行搜索重载
            // 使用的table.reload，绑定的还是当前的table对象，所以请求路径还是之前的。subject/query
            table.reload('currentTableId', {
                contentType:'application/json',
                where: data.field // 查询条件
            }, 'data');
            return false;
        });
        /**
         * toolbar事件监听
         */
        table.on('toolbar(currentTableFilter)', function (obj) {
            if (obj.event === 'add') {   // 监听添加操作
                var index = layer.open({
                    title: '添加专业',
                    type: 2,
                    shade: 0.2, // 阴影的透明度
                    shadeClose: false, // 是否开启-点击阴影部分关闭弹框
                    area: ['50%', '50%'],
                    content: '${basePath}subject/add',
                    end:function(){
                        table.reload('currentTableId');
                    }
                });
            } else if (obj.event === 'update') {  // 监听修改操作
                // table表选中的记录
                var checkStatus = table.checkStatus('currentTableId');
                var data = checkStatus.data;
                // 一次只能修改一条数据
                if(data.length !=1){
                    layer.msg("请选择一行数据修改",{time:1000});
                    return;
                }
                var index = layer.open({
                    title: '修改专业',
                    type: 2,
                    shade: 0.2,
                    shadeClose: false,
                    area: ['50%', '50%'],
                    content: '${basePath}subject/detail/'+data[0].id,
                    end:function(){
                        table.reload('currentTableId');
                    }
                });
            }else if (obj.event === 'delete') { // 监听删除操作
                var checkStatus = table.checkStatus('currentTableId');
                var data = checkStatus.data;
                if(data.length ==0){
                    layer.msg("请选择行数据删除",{time:1000});
                    return;
                }
                var arr = [];
                // index：你选中的行索引
                for(index in data){
                    arr.push(data[index].id);
                }
                layer.confirm('真的删除行吗', function (index) {
                    $.ajax({
                        url:"${basePath}subject/delete",
                        type:"POST",
                        dataType:'json',
                        data:"ids="+arr.join(","),
                        success:function(data){
                            layer.msg(data.msg,{time:500},
                                function(){
                                    table.reload("currentTableId");
                                });
                        },
                        error:function(data){
                            console.log(data);
                        }
                    });
                });
            }
        });
    });
</script>
</body>
</html>