[#ftl]
[@b.form name="searchForm" action="!search" title="ui.searchForm" target="applyFrame" theme="search"]
    [@b.textfield name="apply.std.code" label="学号" maxlength="15"/]
    [@b.textfield name="apply.std.name" label="姓名" maxlength="10"/]
    [@b.textfield name="apply.std.state.grade" label="年级" maxlength="10"/]
    [@b.textfield name="oldCourse" label="原课程" maxlength="30" placeholder="代码或名称"/]
    [@b.textfield name="newCourse" label="新课程" maxlength="30" placeholder="代码或名称"/]
    <input type="hidden" name="orderBy" value="apply.id desc"/>
    [@b.field label="状态"]
       <select name="apply.approved">
          <option value="">全部</option>
          <option value="null">未审核</option>
          <option value="1">通过</option>
          <option value="0">未通过</option>
       </select>
    [/@]
[/@]
