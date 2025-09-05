[@b.head/]
[@b.grid id="programList" items=programs var="program"]
    [@b.gridbar]
        bar.addItem("新建",action.add());
        bar.addItem("${b.text("action.modify")}",action.edit());
        bar.addItem("复制",action.single("copyPrompt"));
        bar.addItem("${b.text("action.delete")}",action.remove());
        var m=bar.addMenu("审核通过",action.multi("audit",'确定审核通过，通过后不能修改?',"passed=1"));
        m.addItem("驳回修改",action.multi("audit",'确定驳回修改?',"passed=0"));
        var menu = bar.addMenu("批量操作");
        menu.addItem("生成执行计划", action.multi("gen","如果已经生成计划，则会跳过，确定继续生成?"));
        menu.addItem("统计学分", action.multi("restat"));
        /**menu.addItem("导出课程", "exportData()");
        menu.addItem("批量打印","printPlans()");
        menu.addItem("批量复制", action.multi("batchCopyPrompt"));
        menu.addItem("修改备注", action.multi("batchUpdateRemarkSetting"));**/
    [/@]
    [@b.row]
        [@b.boxcol/]
        [@b.col width="7%" property="grade.code" title="年级"/]
        [@b.col width="6%" property="level.name" title="培养层次"/]
        [#if displayEducationType]
          [@b.col width="6%" property="eduType.name" title="培养类型"/]
        [/#if]
        [@b.col width="16%" property="department.name" title="院系"/]
        [@b.col property="name" title="专业/方向"]
           [@b.a href="!report?program.id=${program.id}" title="点击查看详情" target="_blank"]${(program.name)}[/@]
        [/@]
        [@b.col width="12%" title="学生类别" ]
          <div class="text-ellipsis">[#list program.stdTypes as ty]${ty.name}[#sep],[/#list]</div>
        [/@]
        [@b.col width="5%" property="duration" title="学制"/]
        [@b.col width="5%" property="credits" title="总学分"/]
        [@b.col width="9%" title="审核状态"]${program.status.name}[/@]
    [/@]
[/@]
[@b.foot /]
